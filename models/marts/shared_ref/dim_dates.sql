/* Calendar dimension, 2000-2099. One row per day. Passed through from staging; all attributes are computed there. */

with
    dates as (
        select * from {{ ref('stg_revenue_emea__dates') }}
    )

select
    date_key,
    date_day,
    first_day_of_month,
    last_day_of_month,
    year_number,
    quarter_number,
    month_number,
    week_of_year,
    day_of_year,
    day_of_month,
    day_of_week,
    year_month_number,
    date_sort_key,
    month_name,
    day_name,
    month_year_label,
    is_weekday,
    is_first_day_of_month
from dates
