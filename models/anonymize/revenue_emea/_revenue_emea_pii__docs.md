# ************** #
# General        #
# ************** #

{% docs anonymize_revenue_emea__general %}
Postgres-only anonymization models. Read raw PII tables and output anonymized versions for export to Snowflake. Enabled only on the anonymize target; never built in Snowflake.
{% enddocs %}

# ************** #
# Tables         #
# ************** #

{% docs anonymize_revenue_emea__partners %}
Partners with PII removed: fake partner names, one-way hashed SFDC account ids, portal URLs dropped.
{% enddocs %}

{% docs anonymize_revenue_emea__vendors %}
Vendors with the distributor's own service names replaced by a generic label. The brand string comes from the ANONYMIZE_BRAND environment variable and never appears in the repo.
{% enddocs %}

{% docs anonymize_revenue_emea__cams %}
Channel account managers with real names replaced by anonymized labels.
{% enddocs %}