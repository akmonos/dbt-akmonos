# streamlit dashboard over the akmonos revenue marts, read-only

import os
from pathlib import Path

import pandas as pd
import snowflake.connector
import streamlit as st

ROLE = os.environ.get("SNOWFLAKE_STREAMLIT_ROLE", "reporter")
KEY_FILE = Path(__file__).resolve().parent.parent / "mcp-server" / "rsa_key.p8"

# currency label -> (gross column, net column) in fct_transactions_monthly
CURRENCIES = {
    "EUR": ("gmrr_eur", "nmrr_eur"),
    "GBP": ("gmrr_gbp", "nmrr_gbp"),
    "USD": ("gmrr_usd", "nmrr_usd"),
}

ALL_REGIONS = "All regions"


def get_connection():
    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        private_key_file=str(KEY_FILE),
        role=ROLE,
        warehouse="dbt_xs_wh",
        database="prod_transformed",
    )


@st.cache_data(ttl=600)
def run_query(sql, params=None):
    """Run one select and return a dataframe. Results are cached for 10 minutes."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        columns = [col[0].lower() for col in cur.description]
        return pd.DataFrame(cur.fetchall(), columns=columns)
    finally:
        conn.close()


def to_numbers(df, columns):
    for column in columns:
        df[column] = pd.to_numeric(df[column])
    return df


def region_filter(region):
    """Return the where clause and its parameters for the chosen region."""
    if region == ALL_REGIONS:
        return "", None
    return "where partners.partner_sales_region = %s", (region,)


def load_regions():
    df = run_query("""
        select distinct partner_sales_region
        from revenue.dim_partners
        order by partner_sales_region
    """)
    return df["partner_sales_region"].tolist()


def load_monthly(gross, net, region):
    where, params = region_filter(region)
    df = run_query(f"""
        select
            transactions.charge_month,
            sum(transactions.{gross}) as gmrr,
            sum(transactions.{net}) as nmrr,
            count(distinct transactions.partner_key) as partners,
            count(distinct transactions.partner_key || '-' || transactions.vendor_key) as partner_vendor_pairs
        from revenue.fct_transactions_monthly as transactions
        inner join revenue.dim_partners as partners
            on transactions.partner_key = partners.partner_key
        {where}
        group by transactions.charge_month
        order by transactions.charge_month
    """, params)
    df = to_numbers(df, ["gmrr", "nmrr", "partners", "partner_vendor_pairs"])
    df["vendors_per_partner"] = df["partner_vendor_pairs"] / df["partners"]
    return df


def load_totals(gross, net, region):
    where, params = region_filter(region)
    df = run_query(f"""
        select
            sum(transactions.{gross}) as gmrr,
            sum(transactions.{net}) as nmrr,
            count(distinct transactions.partner_key) as partners,
            count(distinct transactions.partner_key || '-' || transactions.vendor_key) as partner_vendor_pairs
        from revenue.fct_transactions_monthly as transactions
        inner join revenue.dim_partners as partners
            on transactions.partner_key = partners.partner_key
        {where}
    """, params)
    return to_numbers(df, ["gmrr", "nmrr", "partners", "partner_vendor_pairs"]).iloc[0]


def load_by_region(gross, region):
    """All regions selected: one bar per region. One region selected: one bar per country in it."""
    where, params = region_filter(region)
    group_column = "partner_sales_region" if region == ALL_REGIONS else "partner_billing_country_name"
    df = run_query(f"""
        select
            partners.{group_column} as area,
            sum(transactions.{gross}) as gmrr,
            count(distinct transactions.partner_key) as partners
        from revenue.fct_transactions_monthly as transactions
        inner join revenue.dim_partners as partners
            on transactions.partner_key = partners.partner_key
        {where}
        group by partners.{group_column}
        order by partners.{group_column}
    """, params)
    return to_numbers(df, ["gmrr", "partners"])


def load_top_vendors(gross, region, masked):
    where, params = region_filter(region)
    order_by = "partners" if masked else "gmrr"
    df = run_query(f"""
        select
            vendors.vendor_name,
            sum(transactions.{gross}) as gmrr,
            count(distinct transactions.partner_key) as partners
        from revenue.fct_transactions_monthly as transactions
        inner join revenue.dim_partners as partners
            on transactions.partner_key = partners.partner_key
        inner join revenue.dim_vendors as vendors
            on transactions.vendor_key = vendors.vendor_key
        {where}
        group by vendors.vendor_name
        order by {order_by} desc nulls last
        limit 10
    """, params)
    return to_numbers(df, ["gmrr", "partners"])


st.set_page_config(page_title="Akmonos revenue", layout="wide")
st.title("EMEA subscription revenue")
st.caption(f"Source: PROD_TRANSFORMED marts built by dbt. Connected as role {ROLE.upper()}.")

with st.sidebar:
    st.header("Filters")
    currency = st.selectbox("Currency", list(CURRENCIES))
    region = st.selectbox("Partner sales region", [ALL_REGIONS] + load_regions())

gross, net = CURRENCIES[currency]

totals = load_totals(gross, net, region)
monthly = load_monthly(gross, net, region)

# revenue columns carry a Snowflake masking policy, so they come back empty for roles without access
masked = pd.isna(totals["gmrr"])

if masked:
    st.info(
        f"Revenue is hidden on purpose, to demonstrate column-level data governance. "
        f"This dashboard connects as the read-only {ROLE.upper()} role, "
        "and a Snowflake masking policy shows revenue values to administrators only. "
        "Partner and vendor counts are not covered by the policy, so they are shown below."
    )

kpi_1, kpi_2, kpi_3, kpi_4 = st.columns(4)
kpi_1.metric(f"Gross MRR ({currency})", "Masked" if masked else f"{totals['gmrr']:,.0f}")
kpi_2.metric(f"Net MRR ({currency})", "Masked" if masked else f"{totals['nmrr']:,.0f}")
kpi_3.metric("Partners", f"{int(totals['partners']):,}")
kpi_4.metric("Vendors per partner", f"{totals['partner_vendor_pairs'] / totals['partners']:.2f}")

if not masked:
    st.subheader(f"Monthly recurring revenue ({currency})")
    st.line_chart(
        monthly.rename(columns={"gmrr": "Gross MRR", "nmrr": "Net MRR"}),
        x="charge_month",
        y=["Gross MRR", "Net MRR"],
        x_label="Charge month",
        y_label=currency,
    )

left, right = st.columns(2)

with left:
    st.subheader("Active partners by month")
    st.line_chart(monthly, x="charge_month", y="partners", x_label="Charge month", y_label="Partners")

with right:
    st.subheader("Vendors per partner by month")
    st.line_chart(
        monthly, x="charge_month", y="vendors_per_partner", x_label="Charge month", y_label="Vendors per partner"
    )

left, right = st.columns(2)

with left:
    by_region = load_by_region(gross, region)
    area = "sales region" if region == ALL_REGIONS else f"country in {region}"
    if masked:
        st.subheader(f"Partners by {area}")
        st.bar_chart(by_region, x="area", y="partners", x_label="", y_label="Partners", horizontal=True)
    else:
        st.subheader(f"Gross MRR by {area} ({currency})")
        st.bar_chart(by_region, x="area", y="gmrr", x_label="", y_label=currency, horizontal=True)

with right:
    top_vendors = load_top_vendors(gross, region, masked)
    if masked:
        st.subheader("Top 10 vendors by partner count")
        st.bar_chart(top_vendors, x="vendor_name", y="partners", x_label="", y_label="Partners", horizontal=True)
    else:
        st.subheader(f"Top 10 vendors by gross MRR ({currency})")
        st.bar_chart(top_vendors, x="vendor_name", y="gmrr", x_label="", y_label=currency, horizontal=True)
