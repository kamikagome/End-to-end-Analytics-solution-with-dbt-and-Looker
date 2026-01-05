{{
    config(
        materialized='table',
        alias='dim_customer'
    )
}}

WITH distinct_customers AS (
    SELECT
        customer_id,
        -- Use MAX to handle potential duplicates deterministically
        MAX(customer_name) AS customer_name,
        MAX(segment) AS segment
    FROM {{ ref('int_orders_enriched') }}
    GROUP BY customer_id
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_sk,
    customer_id,
    customer_name,
    segment,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM distinct_customers
