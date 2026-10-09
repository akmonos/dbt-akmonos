# ************** #
# General        #
# ************** #

{% docs revenue__general %}
Revenue mart: star schema for anonymized SaaS distributor revenue. Dims plus one monthly transactions fact.
{% enddocs %}

# ************** #
# Tables         #
# ************** #

{% docs revenue__dim_partners %}
Partner dimension, one row per partner, with country name and sales region joined from the regions reference. Two US partners fall outside the EMEA region mapping and carry null region by design.
{% enddocs %}

{% docs revenue__dim_vendors %}
Vendor dimension, one row per software vendor.
{% enddocs %}

{% docs revenue__dim_cams %}
Channel account manager dimension, one row per CAM.
{% enddocs %}

{% docs revenue__dim_products %}
Product dimension, one row per product.
{% enddocs %}

{% docs revenue__fct_transactions_monthly %}
Monthly transactions fact, one row per subscription line per charge month. Carries the surrogate key, dim keys, and GMRR/NMRR in source currency plus EUR, GBP, and USD at a fixed snapshot rate per currency, matching the original Power BI logic.
{% enddocs %}