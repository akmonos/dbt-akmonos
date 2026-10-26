# ************* #
# General       #
# ************* #

{% docs stg_revenue_emea__anonymized_note %}
Partner names, CAM names, and Salesforce account IDs were replaced in Postgres before loading to Snowflake. The original names and Salesforce IDs are not stored in Snowflake. Revenue figures, countries, dates, and keys are unchanged.
{% enddocs %}

# ************* #
# Tables        #
# ************* #

{% docs stg_revenue_emea__partners %}
One row per partner (reseller) in the EMEA revenue dataset. Names and Salesforce account IDs are anonymized.
{% enddocs %}

{% docs stg_revenue_emea__cams %}
One row per channel account manager. Names are anonymized.
{% enddocs %}

{% docs stg_revenue_emea__vendors %}
One row per software vendor sold through the distributor. The distributor's own services were renamed to a generic label.
{% enddocs %}

{% docs stg_revenue_emea__products %}
One row per product key. The source carries keys only, no product attributes.
{% enddocs %}

{% docs stg_revenue_emea__currencies %}
One row per billing currency.
{% enddocs %}

{% docs stg_revenue_emea__regions %}
One row per country, mapped to a sales region.
{% enddocs %}

{% docs stg_revenue_emea__dates %}
One row per calendar day across a 100-year range. Columns the source report computed at refresh time (this_month, today, current_month) were dropped.
{% enddocs %}

{% docs stg_revenue_emea__transactions_monthly %}
One row per subscription line per charge month. Rows that look alike differ by end date, cancellation status, or amount. The source has no line ID; a surrogate key is added in intermediate.
{% enddocs %}

{% docs stg_revenue_emea__exchange_rates %}
Conversion rates from each source currency to the base currency. Three tables exist, one each for EUR, GBP, and USD as the base. Each holds a single snapshot: one effective date and one rate per source currency, not a daily rate history.
{% enddocs %}

# ************** #
# Columns        #
# ************** #

# shared keys

{% docs stg_revenue_emea__partner_key %}
Surrogate key for a partner. Stable across staging, intermediate, and marts.
{% enddocs %}

{% docs stg_revenue_emea__cam_key %}
Surrogate key for a channel account manager.
{% enddocs %}

{% docs stg_revenue_emea__vendor_key %}
Surrogate key for a software vendor.
{% enddocs %}

{% docs stg_revenue_emea__product_key %}
Surrogate key for a product.
{% enddocs %}

{% docs stg_revenue_emea__currency_key %}
Surrogate key for a billing currency.
{% enddocs %}

{% docs stg_revenue_emea__currency_api_code %}
Three-letter ISO currency code (EUR, GBP, USD...).
{% enddocs %}

# partners

{% docs stg_revenue_emea__partner_id %}
Numeric identifier for the partner from the source system.
{% enddocs %}

{% docs stg_revenue_emea__partner_sf_account_hash %}
One-way hash of the Salesforce account ID. Cannot be reversed.
{% enddocs %}

{% docs stg_revenue_emea__partner_name %}
Anonymized partner label (Partner 1, Partner 2...).
{% enddocs %}

{% docs stg_revenue_emea__partner_billing_country %}
Two-letter country code of the partner's billing address.
{% enddocs %}

{% docs stg_revenue_emea__partner_account_segmentation %}
Account segment code assigned to the partner (for example A6).
{% enddocs %}

{% docs stg_revenue_emea__partner_created_at %}
Timestamp the partner account was created.
{% enddocs %}

{% docs stg_revenue_emea__partner_first_transaction_at %}
Timestamp of the partner's first transaction. Null if the partner has never transacted.
{% enddocs %}

# cams

{% docs stg_revenue_emea__cam_name %}
Anonymized channel account manager label (CAM 1, CAM 2...).
{% enddocs %}

# vendors

{% docs stg_revenue_emea__vendor_name %}
Vendor name. Public software brands are unchanged; the distributor's own services carry a generic label.
{% enddocs %}

# regions

{% docs stg_revenue_emea__country_code %}
ISO two-letter country code.
{% enddocs %}

{% docs stg_revenue_emea__country %}
Country name.
{% enddocs %}

{% docs stg_revenue_emea__region %}
Sales region the country belongs to.
{% enddocs %}

# dates

{% docs stg_revenue_emea__date_key %}
Calendar date as a number in yyyymmdd form.
{% enddocs %}

{% docs stg_revenue_emea__date_day %}
The calendar date.
{% enddocs %}

{% docs stg_revenue_emea__first_day_of_month %}
First day of the month the date falls in.
{% enddocs %}

{% docs stg_revenue_emea__last_day_of_month %}
Last day of the month the date falls in.
{% enddocs %}

{% docs stg_revenue_emea__year_number %}
Four-digit year.
{% enddocs %}

{% docs stg_revenue_emea__quarter_number %}
Quarter of the year, 1 to 4.
{% enddocs %}

{% docs stg_revenue_emea__month_number %}
Month of the year, 1 to 12.
{% enddocs %}

{% docs stg_revenue_emea__week_of_year %}
Week number within the year.
{% enddocs %}

{% docs stg_revenue_emea__day_of_year %}
Day number within the year, 1 to 366.
{% enddocs %}

{% docs stg_revenue_emea__day_of_month %}
Day number within the month, 1 to 31.
{% enddocs %}

{% docs stg_revenue_emea__day_of_week %}
Day number within the week.
{% enddocs %}

{% docs stg_revenue_emea__year_month_number %}
Year and month as a number in yyyymm form.
{% enddocs %}

{% docs stg_revenue_emea__date_sort_key %}
Sequential integer for ordering dates.
{% enddocs %}

{% docs stg_revenue_emea__month_name %}
Full month name (January, February...).
{% enddocs %}

{% docs stg_revenue_emea__day_name %}
Full day name (Monday, Tuesday...).
{% enddocs %}

{% docs stg_revenue_emea__month_year_label %}
Short month and year label (for example Dec-24).
{% enddocs %}

{% docs stg_revenue_emea__is_weekday %}
True if the date is Monday to Friday.
{% enddocs %}

{% docs stg_revenue_emea__is_first_day_of_month %}
True if the date is the first day of its month.
{% enddocs %}

# transactions_monthly

{% docs stg_revenue_emea__charge_month %}
First day of the month the recurring charge applies to.
{% enddocs %}

{% docs stg_revenue_emea__gmrr %}
Gross monthly recurring revenue in the billing currency, before adjustments.
{% enddocs %}

{% docs stg_revenue_emea__nmrr %}
Net monthly recurring revenue in the billing currency, after adjustments.
{% enddocs %}

{% docs stg_revenue_emea__quantity %}
Number of licenses or units on the charge.
{% enddocs %}

{% docs stg_revenue_emea__eur_conversion_rate %}
Rate to convert the billing currency to EUR at the time of the charge.
{% enddocs %}

{% docs stg_revenue_emea__gbp_conversion_rate %}
Rate to convert the billing currency to GBP at the time of the charge.
{% enddocs %}

{% docs stg_revenue_emea__usd_conversion_rate %}
Rate to convert the billing currency to USD at the time of the charge.
{% enddocs %}

{% docs stg_revenue_emea__is_cancelled %}
True if the subscription behind the charge was cancelled.
{% enddocs %}

{% docs stg_revenue_emea__started_at %}
Timestamp the subscription started.
{% enddocs %}

{% docs stg_revenue_emea__ended_at %}
Timestamp the subscription ended. Null if still active.
{% enddocs %}

# exchange_rates

{% docs stg_revenue_emea__effective_date %}
Date the exchange rate takes effect.
{% enddocs %}

{% docs stg_revenue_emea__base_currency_code %}
Currency being converted to (EUR, GBP, or USD depending on the table).
{% enddocs %}

{% docs stg_revenue_emea__source_currency_code %}
Currency being converted from.
{% enddocs %}

{% docs stg_revenue_emea__conversion_rate %}
Multiplier to convert one unit of the source currency into the base currency.
{% enddocs %}
