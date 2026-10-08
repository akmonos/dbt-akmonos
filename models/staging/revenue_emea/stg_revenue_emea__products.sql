with source as (
	select * from {{ source('revenue_emea', 'dim_product') }}
),

renamed as (
	select
		-- ids
		product_key

	from source
)

select * from renamed