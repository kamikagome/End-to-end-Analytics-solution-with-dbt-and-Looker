{{
    config(
        materialized='table',
        alias='dim_product'
    )
}}

WITH distinct_products AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        product_name,
        category,
        sub_category
    FROM {{ ref('int_orders_enriched') }}
    ORDER BY product_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_sk,
    product_id,
    product_name,
    category,
    sub_category,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_products
