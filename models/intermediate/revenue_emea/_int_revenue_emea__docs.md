# ************** #
# General        #
# ************** #

{% docs int_revenue_emea__general %}
Intermediate models for anonymized SaaS distributor revenue data. Prepares staging models for the revenue marts.
{% enddocs %}

# ************** #
# Tables         #
# ************** #

{% docs int_revenue_emea__transactions_converted %}
One row per subscription line per charge month, with a surrogate key and GMRR/NMRR converted to EUR, GBP, and USD. Amounts are converted at a single fixed rate per currency, not the rate in effect at the time of the charge, because the source exchange tables hold one snapshot. This matches the original Power BI report logic.
{% enddocs %}

# ************** #
# Columns        #
# ************** #

{% docs int_revenue_emea__transaction_monthly_sk %}
Surrogate key built from all 16 source columns. The source has no line ID and no smaller combination of columns is unique.
{% enddocs %}

{% docs int_revenue_emea__gmrr_converted %}
Gross monthly recurring revenue converted to the named currency at the fixed snapshot rate.
{% enddocs %}

{% docs int_revenue_emea__nmrr_converted %}
Net monthly recurring revenue converted to the named currency at the fixed snapshot rate.
{% enddocs %}