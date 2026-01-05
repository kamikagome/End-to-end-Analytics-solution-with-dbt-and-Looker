{{
    config(
        materialized='table',
        alias='dim_geo'
    )
}}

WITH distinct_geo AS (
    SELECT DISTINCT
        country_region,
        city,
        state,
        COALESCE(postal_code, 'UNKNOWN') AS postal_code,
        region
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['country_region', 'state', 'city', 'postal_code']) }} AS geo_sk,
    country_region,
    city,
    state,
    postal_code,
    region,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_geo
