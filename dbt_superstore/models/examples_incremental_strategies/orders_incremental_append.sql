{{
  config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='dwh_id',
    schema='examples'
  )
}}

-- APPEND STRATEGY:
-- Simply inserts new records without checking for duplicates
-- Best for: Event logs, immutable data, append-only scenarios
-- Warning: Can create duplicates if source has duplicate keys

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
    -- Only select new records based on order_date
    WHERE order_date > (SELECT max(order_date) FROM {{ this }})
{% endif %}
