with source as (
	select * from {{ source('revenue_emea', 'dim_date') }}
),

renamed as (
	select
		-- ids
		date_key::number as date_key,

		-- dates
		full_date::timestamp_ntz::date as date_day,
		first_day_of_month::timestamp_ntz::date as first_day_of_month,
		last_day_of_month::timestamp_ntz::date as last_day_of_month,

		-- numbers
		year_number::number as year_number,
		qtr_number::number as quarter_number,
		month_number::number as month_number,
		year_week_number::number as week_of_year,
		year_day_number::number as day_of_year,
		month_day_number::number as day_of_month,
		week_day_number::number as day_of_week,
		year_month_num::number as year_month_number,
		date_sort_key::number as date_sort_key,

		-- labels
		month_name,
		day_name,
		month_year as month_year_label,

		-- booleans
		is_weekday::boolean as is_weekday,
		is_first_day::boolean as is_first_day_of_month
	from source
)

select * from renamed