# mcp server exposing the akmonos revenue marts to AI clients, read-only

import os
import snowflake.connector
from mcp.server.mcpserver import MCPServer
from pathlib import Path

def load_env_file():
    env_path = Path(__file__).with_name(".env")
    if env_path.exists():
        for line in env_path.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

load_env_file()

mcp = MCPServer("akmonos_marts")

def get_connection():
    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        private_key_file=str(Path(__file__).with_name("rsa_key.p8")),
        role=os.environ.get("SNOWFLAKE_MCP_ROLE", "reporter"),
        warehouse="dbt_xs_wh",
        database="prod_transformed",
    )

@mcp.tool()
def list_tables() -> str:
    """List all tables in the revenue marts with their schema and row count."""
    try:
        conn = get_connection()
        try:
            cur = conn.cursor()
            cur.execute("""
                select table_schema, table_name, row_count
                from prod_transformed.information_schema.tables
                where table_schema in ('SHARED_REF', 'REVENUE')
                  and table_type = 'BASE TABLE'
                order by table_schema, table_name
            """)
            rows = cur.fetchall()
            return "\n".join(f"{s}.{t} ({r} rows)" for s, t, r in rows)
        finally:
            conn.close()
    except Exception as e:
        return f"Tool error: {type(e).__name__}: {e}"

@mcp.tool()
def describe_table(table_name: str) -> str:
    """Describe one mart table: its columns, data types, and documentation.
    table_name is the bare name, e.g. 'fct_transactions_monthly' or 'dim_partners'."""
    try:
        conn = get_connection()
        try:
            cur = conn.cursor()
            cur.execute(
                """
                select table_schema, column_name, data_type, comment
                from prod_transformed.information_schema.columns
                where table_name = upper(%s)
                  and table_schema in ('SHARED_REF', 'REVENUE')
                order by ordinal_position
                """,
                (table_name,),
            )
            rows = cur.fetchall()
            if not rows:
                return f"No table named {table_name} in the revenue marts. Use list_tables to see what exists."
            lines = [f"{col}: {dtype}" + (f" -- {com}" if com else "") for _, col, dtype, com in rows]
            return f"{rows[0][0]}.{table_name.upper()}\n" + "\n".join(lines)
        finally:
            conn.close()
    except Exception as e:
        return f"Tool error: {type(e).__name__}: {e}"


@mcp.tool()
def run_query(sql: str) -> str:
    """Run a read-only SELECT against the revenue marts, returning up to 50 rows.
    Only SELECT is allowed. Example:
    select charge_month, sum(gmrr_eur) from revenue.fct_transactions_monthly group by 1 order by 1
    """
    cleaned = sql.strip().rstrip(";").strip()
    if not cleaned.lower().startswith("select"):
        return "Only SELECT queries are allowed by this tool."
    try:
        conn = get_connection()
        try:
            cur = conn.cursor()
            cur.execute(cleaned)
            rows = cur.fetchmany(50)
            cols = [d[0] for d in cur.description]
            lines = [" | ".join(cols)]
            lines += [" | ".join(str(v) for v in r) for r in rows]
            return "\n".join(lines)
        finally:
            conn.close()
    except Exception as e:
        return f"Tool error: {type(e).__name__}: {e}"

if __name__ == "__main__":
    mcp.run(transport="stdio")
