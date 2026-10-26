/* Currency dimension. One row per currency. Passed through from staging. */

with
    currencies as (
        select * from {{ ref('stg_revenue_emea__currencies') }}
    )

select
    currency_key,
    currency_api_code
from currencies
