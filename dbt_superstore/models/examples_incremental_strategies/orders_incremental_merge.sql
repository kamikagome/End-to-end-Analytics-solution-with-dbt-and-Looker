{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='dwh_id',
    schema='examples'
  )
}}

-- MERGE STRATEGY:
-- Updates existing records and inserts new ones (UPSERT)
-- Best for: SCD Type 1, dimension tables, data that needs updates
-- Note: Scans entire table to find matches - can be expensive for large tables

SELECT
    row_id AS dwh_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country_region,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit,
    current_timestamp AS etl_timestamp
FROM {{ source('superstore', 'orders') }}

{% if is_incremental() %}
    -- Only process records that might have changed
    WHERE
        order_date
        >= (SELECT max(order_date) - INTERVAL '7 days' FROM {{ this }})
{% endif %}
