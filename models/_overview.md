{% docs __overview__ %}

# Akmonos data platform

Akmonos is a dbt and Snowflake data platform built to serve governed, AI-ready data marts. This site is regenerated from the code on every production deploy, so what you read here always matches what is running in `PROD_TRANSFORMED`.

Source code, setup guide, and architecture: [github.com/akmonos/dbt-akmonos](https://github.com/akmonos/dbt-akmonos)

## Start here

`revenue_star_emea` is the first mart in production: a Kimball star schema over an anonymized EMEA subscription revenue dataset. Output totals reconcile to the cent against the source.

| Table | Schema | What it holds |
|---|---|---|
| `fct_transactions_monthly` | `REVENUE` | Monthly gross and net MRR per partner, vendor, and product, converted into EUR, GBP, and USD at the row level |
| `dim_partners` | `REVENUE` | Partners, billing country, and sales region |
| `dim_vendors` | `REVENUE` | Vendors whose products are resold |
| `dim_cams` | `REVENUE` | Channel account managers |
| `dim_products` | `REVENUE` | One row per product, identified by its product key |
| `dim_dates`, `dim_currencies`, `dim_regions` | `SHARED_REF` | Reference dimensions, conformed so future marts can share them |

Open any table to see its columns, descriptions, tests, and lineage. The lineage graph is the icon in the bottom-right corner of every page.

## How the project is laid out

| Folder | Layer | What happens there |
|---|---|---|
| `anonymize` | Anonymize | Strips PII and brand identifiers locally in Postgres before anything leaves the local environment. Never built in Snowflake. |
| `staging` | Staging | One view per source table. Renaming, typing, light cleanup. |
| `intermediate` | Intermediate | Surrogate keys and multi-currency conversion. |
| `marts` | Marts | Dimensional models served to BI and AI consumers. |

## Metrics

Business metrics are defined once in the semantic layer (MetricFlow) and listed under **Metrics** in the left menu. Every consumer, whether a dashboard, the MCP server, or an analyst at the command line, gets the same number from the same definition.

| Metric | Type | Definition |
|---|---|---|
| `total_gmrr_eur`, `total_gmrr_gbp`, `total_gmrr_usd` | simple | Gross monthly recurring revenue, summed in each currency |
| `total_nmrr_eur`, `total_nmrr_gbp`, `total_nmrr_usd` | simple | Net monthly recurring revenue, summed in each currency |
| `vendors_per_partner` | ratio | VPP: average number of distinct vendors each partner buys from |

`dim_dates` is the time spine, so any metric can be grouped by day, week, month, quarter, or year.

## How code reaches production

Every change goes through a pull request. CI builds only the modified models and everything downstream of them into isolated `CI_*` schemas, deferring the rest to production. `main` is protected: a passing CI check and an approval are required to merge. The deploy workflow then pauses at a manual approval gate before building into `PROD_TRANSFORMED`, and publishes this site when it finishes.

CI and deploy run as the least-privilege `transformer` role, signed in with key-pair authentication. No password exists anywhere in the pipeline.

## Governance

Commercially sensitive measures are classified in metadata and masked in Snowflake by policy. On every build, a hook creates the masking policy and attaches it to every tagged column, so masking survives each rebuild. The `reporter` role, used by BI tools and the MCP server, sees NULL in those columns. PII never reaches the cloud: it is removed in the anonymize layer before load.

## AI access through MCP

The repository ships a Python MCP server that lets AI clients such as the Claude desktop app list, describe, and query the marts, read-only. It connects as `reporter` by default, so masking applies to the AI exactly as it does to any other client.

## Conventions

- Staging: `stg_<source>__<entity>`. Intermediate: `int_<source>__<description>`. Marts: `dim_` and `fct_` prefixes.
- Every model has its own yml file, and every description comes from a shared doc block.
- Every model names its output columns explicitly. No `select *`.
- Lowercase SQL, four-space indents, trailing commas, enforced by SQLFluff on every commit.

Built and maintained by Ibby Nosiru. [LinkedIn](https://www.linkedin.com/in/ibrahim-ibby-n-b6803577/)

{% enddocs %}
