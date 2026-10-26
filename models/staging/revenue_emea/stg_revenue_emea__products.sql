with
    source as (
        select * from {{ source('revenue_emea', 'dim_product') }}
    ),

    renamed as (
        select product_key
        -- ids

        from source
    )

select * from renamed
