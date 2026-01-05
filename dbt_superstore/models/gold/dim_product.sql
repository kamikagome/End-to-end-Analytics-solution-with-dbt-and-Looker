{{
    config(
        materialized='table',
        alias='dim_product'
    )
}}

WITH distinct_products AS (
    SELECT
        product_id,
        -- Use MAX to handle duplicates - take the first product name alphabetically
        MAX(product_name) AS product_name,
        MAX(category) AS category,
        MAX(sub_category) AS sub_category
    FROM {{ ref('int_orders_enriched') }}
    GROUP BY product_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_sk,
    product_id,
    product_name,
    category,
    sub_category,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_products
