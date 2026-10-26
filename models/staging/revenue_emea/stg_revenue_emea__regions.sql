with
    source as (
        select * from {{ source('revenue_emea', 'regions') }}
    ),

    renamed as (
        select
            -- ids
            country_code,

            -- attributes
            country,
            region
        from source
    )

select * from renamed
