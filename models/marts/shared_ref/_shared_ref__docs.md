# ************** #
# General        #
# ************** #

{% docs shared_ref__general %}
Shared reference dimensions usable by any mart, not tied to one business subject.
{% enddocs %}

# ************** #
# Tables         #
# ************** #

{% docs shared_ref__dim_dates %}
Calendar dimension, 2000-2099, one row per day. All attributes are computed in staging; this mart materializes them as a table for BI use.
{% enddocs %}

{% docs shared_ref__dim_currencies %}
Currency dimension, one row per currency.
{% enddocs %}

{% docs shared_ref__dim_regions %}
Country to sales region mapping, one row per country. Covers EMEA countries only.
{% enddocs %}