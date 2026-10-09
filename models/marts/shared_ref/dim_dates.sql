/* Calendar dimension, 2000-2099. One row per day. Passed through from staging; all attributes are computed there. */

with dates as (
    select * from {{ ref('stg_revenue_emea__dates') }}
)

select * from dates