with source as (
	select * from {{ source('revenue_emea_pii', 'dim_partner') }}
),

renamed as (
	select
		-- ids
		partner_key,
		partner_id::bigint  as partner_id,

		-- anonymized (PII: sfdc account id, partner name; partnerlink dropped)
		{{ dbt_utils.generate_surrogate_key(['partner_sf_account_id']) }} as partner_sf_account_hash,
		'Partner ' || dense_rank() over (order by partner_key) as partner_name,

		-- attributes
		partner_billing_country,
		partner_account_segmentation,

		-- timestamps
		partner_created_date::timestamp as partner_created_at,
		partner_first_transaction_date::timestamp as partner_first_transaction_at
	from source
)

select * from renamed