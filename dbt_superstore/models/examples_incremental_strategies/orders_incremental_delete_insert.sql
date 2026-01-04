{{
  config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='dwh_id',
    schema='examples'
  )
}}

-- DELETE+INSERT STRATEGY:
-- Deletes records matching unique_key, then inserts fresh data
-- Best for: When updates are common, ensuring complete record replacement
-- Note: Less efficient than merge for large datasets due to delete operation

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
    -- Process records from the last 7 days to handle late-arriving data
    WHERE
        order_date
        >= (SELECT max(order_date) - INTERVAL '7 days' FROM {{ this }})
{% endif %}
