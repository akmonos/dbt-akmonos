with source as (
	select * from {{ source('revenue_emea', 'dim_partner') }}
),

renamed as (
	select
		-- ids
		partner_key,
		partner_id::number as partner_id,
		partner_sf_account_hash,

		-- attributes
		partner_name,
		partner_billing_country,
		partner_account_segmentation,

		-- timestamps
		partner_created_at::timestamp_ntz as partner_created_at,
		partner_first_transaction_at::timestamp_ntz as partner_first_transaction_at
	from source
)

select * from renamed