{% macro create_masking_policy_mp__restricted__commercially_sensitive__numeric_v1(node_database, node_schema) %}

create masking policy if not exists {{ node_database }}.{{ node_schema }}.mp__restricted__commercially_sensitive__numeric_v1 as (val numeric)
    returns numeric ->
    case
        when current_role() in ('ACCOUNTADMIN') then val
        else null
    end

{% endmacro %}