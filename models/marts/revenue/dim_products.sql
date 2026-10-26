/* Product dimension. One row per product. Passed through from staging. */

with
    products as (
        select * from {{ ref('stg_revenue_emea__products') }}
    )

select product_key
from products
