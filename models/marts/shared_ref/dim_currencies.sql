/* Currency dimension. One row per currency. Passed through from staging. */
-- slim ci test
with currencies as (
    select * from {{ ref('stg_revenue_emea__currencies') }}
)

select * from currencies
