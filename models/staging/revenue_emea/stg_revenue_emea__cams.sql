with source as (
	select * from {{ source('revenue_emea', 'dim_cam') }}
),

renamed as (
	select
		-- ids
		cam_key,

		-- attributes
		cam_name
	from source
)

select * from renamed