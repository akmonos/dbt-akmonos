/* Monthly transactions fact. One row per subscription line per charge month. Reads the converted intermediate; joins to dims via the key columns. Built by the transformer role. */

with
    transactions as (
        select * from {{ ref('int_revenue_emea__transactions_converted') }}
    )

select
    transaction_monthly_sk,
    partner_key,
    cam_key,
    vendor_key,
    product_key,
    currency_key,
    currency_api_code,
    gmrr,
    nmrr,
    quantity,
    eur_conversion_rate,
    gbp_conversion_rate,
    usd_conversion_rate,
    is_cancelled,
    charge_month,
    started_at,
    ended_at,
    gmrr_eur,
    gmrr_gbp,
    gmrr_usd,
    nmrr_eur,
    nmrr_gbp,
    nmrr_usd
from transactions
