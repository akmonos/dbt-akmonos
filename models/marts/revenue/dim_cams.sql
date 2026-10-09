/* Channel account manager dimension. One row per CAM. Passed through from staging. */

with cams as (
	select * from {{ ref('stg_revenue_emea__cams') }}
)

select * from cams