/* Monthly subscription charges with a surrogate key and GMRR/NMRR converted to EUR, GBP, and USD. Grain: one row per subscription line per charge month. */

with
    transactions as (
        select * from {{ ref('stg_revenue_emea__transactions_monthly') }}
    ),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key([
                'partner_key', 'cam_key', 'vendor_key', 'product_key', 'currency_key',
                'currency_api_code', 'gmrr', 'nmrr', 'quantity',
                'eur_conversion_rate', 'gbp_conversion_rate', 'usd_conversion_rate',
                'is_cancelled', 'charge_month', 'started_at', 'ended_at'
            ]) }} as transaction_monthly_sk,
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
            gmrr * eur_conversion_rate as gmrr_eur,
            gmrr * gbp_conversion_rate as gmrr_gbp,
            gmrr * usd_conversion_rate as gmrr_usd,
            nmrr * eur_conversion_rate as nmrr_eur,
            nmrr * gbp_conversion_rate as nmrr_gbp,
            nmrr * usd_conversion_rate as nmrr_usd
        from transactions
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
from final
