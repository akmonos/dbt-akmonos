with source as (
	select * from {{ source('revenue_emea', 'fact_transaction_monthly') }}
),

renamed as (
	select
		-- keys
		transaction_monthly_partner_key as partner_key,
		transaction_monthly_cam_key as cam_key,
		transaction_monthly_vendor_key as vendor_key,
		transaction_monthly_product_key as product_key,
		transaction_monthly_currency_key as currency_key,

		-- attributes
		currency_api_code,

		-- numerics
		transaction_monthly_gmrr::number(18, 4) as gmrr,
		transaction_monthly_nmrr::number(18, 4) as nmrr,
		transaction_monthly_quantity::number(18, 4) as quantity,
		euros_conversion_rate::number(18, 8) as eur_conversion_rate,
		gbp_conversion_rate::number(18, 8) as gbp_conversion_rate,
		usd_conversion_rate::number(18, 8) as usd_conversion_rate,

		-- booleans
		transaction_monthly_is_cancelled::boolean as is_cancelled,

		-- dates
		transaction_monthly_charge_created_date::timestamp_ntz::date as charge_month,
		transaction_monthly_start_date::timestamp_ntz as started_at,
		transaction_monthly_end_date::timestamp_ntz as ended_at
	from source
)

select * from renamed