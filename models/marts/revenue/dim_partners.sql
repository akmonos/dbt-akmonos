/* Partner dimension. One row per partner, with country name and sales region joined from regions. Partners billed outside the EMEA region list get sales region Outside EMEA. */

with
    partners as (
        select * from {{ ref('stg_revenue_emea__partners') }}
    ),

    regions as (
        select * from {{ ref('stg_revenue_emea__regions') }}
    ),

    joined as (
        select
            partners.partner_key,
            partners.partner_id,
            partners.partner_sf_account_hash,
            partners.partner_name,
            partners.partner_billing_country,
            partners.partner_account_segmentation,
            partners.partner_created_at,
            partners.partner_first_transaction_at,
            coalesce(regions.country, partners.partner_billing_country) as partner_billing_country_name,
            coalesce(regions.region, 'Outside EMEA') as partner_sales_region
        from partners
        left join regions
            on partners.partner_billing_country = regions.country_code
    )

select
    partner_key,
    partner_id,
    partner_sf_account_hash,
    partner_name,
    partner_billing_country,
    partner_account_segmentation,
    partner_created_at,
    partner_first_transaction_at,
    partner_billing_country_name,
    partner_sales_region
from joined
