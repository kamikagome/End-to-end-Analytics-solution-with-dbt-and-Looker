{{
    config(
        materialized='table',
        alias='dim_shipping'
    )
}}

WITH distinct_shipping AS (
    SELECT DISTINCT
        ship_mode
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY ship_mode) AS shipping_sk,
    ship_mode,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_shipping
