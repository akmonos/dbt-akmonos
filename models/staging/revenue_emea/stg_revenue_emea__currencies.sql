with source as (
	select * from {{ source('revenue_emea', 'dim_currency') }}
),

renamed as (
	select
		-- ids
		currency_key,

		-- attributes
		currency_api_code
	from source
)

select * from renamed