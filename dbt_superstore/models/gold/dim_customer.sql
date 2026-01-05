{{
    config(
        materialized='table',
        alias='dim_customer'
    )
}}

WITH distinct_customers AS (
    SELECT DISTINCT
        customer_id,
        customer_name,
        segment
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_sk,
    customer_id,
    customer_name,
    segment,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_customers
