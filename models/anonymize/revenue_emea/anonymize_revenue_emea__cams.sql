with source as (
	select * from {{ source('revenue_emea_pii', 'dim_cam') }}
),

renamed as (
	select
		cam_key,
		'CAM ' || dense_rank() over (order by cam_key) as cam_name
	from source
)

select * from renamed
