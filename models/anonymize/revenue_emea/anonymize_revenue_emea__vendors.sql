with source as (
	select * from {{ source('revenue_emea_pii', 'dim_vendor') }}
),

renamed as (
	select
		vendor_key,
		regexp_replace(vendor_name, '{{ env_var("ANONYMIZE_BRAND", "ANONYMIZE_BRAND_NOT_SET") }}', 'Distributor', 'gi') as vendor_name
	from source
)

select * from renamed