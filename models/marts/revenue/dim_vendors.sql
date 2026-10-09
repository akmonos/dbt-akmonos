/* Vendor dimension. One row per software vendor. Passed through from staging. */

with vendors as (
	select * from {{ ref('stg_revenue_emea__vendors') }}
)

select * from vendors