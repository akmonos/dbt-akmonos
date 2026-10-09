/* Partner dimension. One row per partner, with country name and sales region joined from regions. */

with partners as (
	select * from {{ ref('stg_revenue_emea__partners') }}
),

regions as (
	select * from {{ ref('stg_revenue_emea__regions') }}
),

joined as (
	select
		partners.*,
		regions.country as partner_billing_country_name,
		regions.region as partner_sales_region
	from partners
	left join regions
		on partners.partner_billing_country = regions.country_code
)

select * from joined