# Akmonos dbt

Akmonos is a dbt and Snowflake data platform built to serve governed, AI-ready data marts. This repository holds the SQL logic, tests, and metadata for the platform. Changes merge through CI and deploy to production automatically through GitHub Actions.

The first mart in production is `revenue_star_emea`: a Kimball star schema over an anonymized EMEA subscription revenue dataset. Privacy is designed in from the first step: data is anonymized before it ever reaches the cloud, and sensitive columns are classified in metadata for masking in Snowflake.

## Architecture

Data flows through four layers, each a folder under `models/`:

| Layer | Folder | Materialization | Purpose |
|---|---|---|---|
| Anonymize | `models/anonymize/` | table (Postgres only) | Strips PII and brand identifiers from source extracts before anything leaves the local environment. Enabled only on the `anonymize` target; never built in Snowflake. |
| Staging | `models/staging/` | view | One model per source table. Renaming, typing, light cleanup. |
| Intermediate | `models/intermediate/` | table | Business logic: surrogate keys, multi-currency conversion. |
| Marts | `models/marts/` | table | Dimensional models served to BI and AI consumers. |

Source data is anonymized locally in Postgres, landed in S3, and loaded into Snowflake `PROD_RAW`. All dbt models read from `PROD_RAW` and build into the environment they target.

### Environments

One codebase, three destinations, controlled by the target and a custom `generate_schema_name` macro:

| Environment | Database | Schema pattern | Built by |
|---|---|---|---|
| Development | `DEV` | `DBT_<USERNAME>_<LAYER>` | Each developer, locally |
| CI | `DEV` | `CI_<LAYER>` | GitHub Actions, on every pull request |
| Production | `PROD_TRANSFORMED` | clean layer names | GitHub Actions, on merge to `main` |

Developers never write to production. Code travels through the pipeline; data is rebuilt in each environment from `PROD_RAW`.

## Data marts

### revenue_star_emea

A star schema covering monthly subscription revenue across the EMEA region.

| Schema | Models |
|---|---|
| `SHARED_REF` | `dim_dates`, `dim_currencies`, `dim_regions` |
| `REVENUE` | `dim_partners`, `dim_vendors`, `dim_cams`, `dim_products`, `fct_transactions_monthly` |

Shared reference dimensions live in `SHARED_REF` so future marts can conform to them. The fact table carries gross and net MRR converted into EUR, GBP, and USD at the row level. Output totals are reconciled to the cent against the source dataset, verifying the pipeline loses and distorts nothing.

Further marts will be added here as the platform grows.

## Installation

1. Install Python 3 and create a virtual environment:

   ```powershell
   # Windows PowerShell
   python -m venv ..\dbt_venv
   ..\dbt_venv\Scripts\activate
   pip install dbt-core dbt-snowflake dbt-postgres
   ```

2. Verify with `dbt --version`, then install package dependencies:

   ```
   dbt deps
   ```

3. Create `~/.dbt/profiles.yml`. Credentials are read from environment variables so no secret ever sits in a file:

   ```yaml
   dbt_akmonos:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
         user: "{{ env_var('SNOWFLAKE_USER') }}"
         password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
         role: <role>
         warehouse: dbt_xs_wh
         database: dev
         schema: dbt_<username>
         threads: 4
   ```

4. Set `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, and `SNOWFLAKE_PASSWORD` as user environment variables, restart your terminal, and confirm the connection:

   ```
   dbt debug
   ```

## Development workflow

1. Branch from an up-to-date `main`:

   ```
   git checkout main
   git pull
   git checkout -b <branch-name>
   ```

2. Develop and build locally. Everything you build lands in your own `DBT_<USERNAME>_*` schemas in `DEV`:

   ```
   dbt build -s <selection>
   ```

3. Push the branch and open a pull request. CI compares the branch against the latest production manifest and builds only modified models and everything downstream of them, into isolated `CI_*` schemas, deferring unchanged models to production. It must pass before merge.

4. Merge to `main`. The deploy workflow builds the project into `PROD_TRANSFORMED` automatically. No manual release step.

GitHub Actions authenticates to Snowflake through repository secrets injected as environment variables into `ci/profiles.yml`.

## Testing and data quality

Tests are defined in each model's yml and run both locally and in CI as part of `dbt build`, so a model that fails its tests never reaches merge. Every model carries uniqueness and not-null tests on its key, and fact tables carry relationship tests against their dimensions.

## Documentation

Every model has a yml file referencing shared doc blocks, so each description is written once and reused everywhere it applies:

- `_<folder>__docs.md` in each model folder holds the doc blocks for that layer.
- `dbt docs generate && dbt docs serve` builds and serves the documentation site locally.

Every deploy regenerates the dbt docs site and stores it as a build artifact. Publishing to GitHub Pages is enabled when the repository goes public.

## Conventions

- One yml file per model (`model.sql` + `model.yml` pairs); descriptions reference doc blocks rather than repeating text.
- Staging models: `stg_<source>__<entity>`. Intermediate: `int_<source>__<description>`. Marts: `dim_`/`fct_` prefixes.
- Sources are defined once per source system in a `_<source>__sources.yml` file.

## Governance

Sensitive columns are classified in model yml under `meta.data_classification`, and commercially sensitive measures also carry a `meta.masking_policy` tag. On every build, a hook creates the masking policy in Snowflake and attaches it to every tagged column, so masking survives each rebuild and ships through the same CI/CD path as the models.

Access is role based, following the dbt Labs loader/transformer/reporter pattern: privileged roles see real values, while the `reporter` role used by BI and AI consumers sees NULL in masked columns. Enforcement lives in Snowflake itself, so it applies to every client that queries the warehouse.

PII never reaches the cloud at all: it is removed in the anonymize layer before load.

| ACCOUNTADMIN | REPORTER |
|---|---|
| ![Real values as ACCOUNTADMIN](docs/images/masking_snowsight_admin.png) | ![Masked values as REPORTER](docs/images/masking_snowsight_reporter.png) |

## AI access through MCP

The `mcp-server/` folder holds a Python MCP server that lets AI clients such as the Claude desktop app query the marts. It exposes three read-only tools:

| Tool | What it does |
|---|---|
| `list_tables` | Lists the mart tables with row counts |
| `describe_table` | Returns a table's columns, data types, and documentation |
| `run_query` | Runs a SELECT and returns up to 50 rows |

The server signs in to Snowflake with key-pair authentication, so no password is stored anywhere. It connects as the `reporter` role by default, so masking applies to the AI exactly as it does to any other client: revenue columns come back as NULL unless a privileged role is set on purpose.

| As REPORTER (default) | As ACCOUNTADMIN |
|---|---|
| ![AI query masked](docs/images/mcp_reporter_masked.png) | ![AI query unmasked](docs/images/mcp_admin_unmasked.png) |

## Maintenance

Deleting or renaming a dbt model does not delete the old table in Snowflake; the leftover object stays behind. Today those leftovers are dropped by hand.

Planned: cleanup macros that find and drop them automatically, including stale developer schemas in `DEV`.

## Roadmap

- SQLFluff linting enforced through pre-commit
- Branch protection and a production approval gate
- Snowflake object tags generated from classification metadata
- Infrastructure as code with Terraform
- Cleanup macros for orphaned relations and developer schemas
- Snowflake Cortex Search over the marts
- Hosted MCP server over HTTP with authentication

## About

Built and maintained by Ibby Nosiru. Connect on [LinkedIn](https://www.linkedin.com/in/ibrahim-ibby-n-b6803577/)