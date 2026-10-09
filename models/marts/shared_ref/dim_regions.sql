/* Region dimension. One row per region. Passed through from staging. */

with regions as (
    select * from {{ ref('stg_revenue_emea__regions') }}
)

select * from regions