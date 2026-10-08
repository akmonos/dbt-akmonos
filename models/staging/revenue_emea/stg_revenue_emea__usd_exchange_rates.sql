with source as (
	select * from {{ source('revenue_emea', 'usd_exchange') }}
),

renamed as (
	select
		-- dates
		effective_date::timestamp_ntz::date as effective_date,

		-- attributes
		exchange_rate_base_currency_code as base_currency_code,
		exchange_rate_source_currency_code as source_currency_code,

		-- numerics
		exchange_rate_conversion_rate::number(18, 8) as conversion_rate
	from source
)

select * from renamed