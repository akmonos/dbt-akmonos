with source as (
	select * from {{ source('revenue_emea', 'dim_vendor') }}
),

renamed as (
	select
		-- ids
		vendor_key,

		-- attributes
		vendor_name
	from source
)

select * from renamed