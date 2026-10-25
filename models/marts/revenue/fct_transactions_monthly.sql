/* Monthly transactions fact. One row per subscription line per charge month. Reads the converted intermediate; joins to dims via the key columns. Built by the transformer role. */

with transactions as (
	select * from {{ ref('int_revenue_emea__transactions_converted') }}
)

select * from transactions