{{ config(
  materialized='view',
  alias='orders_enriched'
) }}

WITH base_orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

calendar AS (
    SELECT * FROM {{ ref('calendar_2025') }}
),

managers AS (
    SELECT * FROM {{ ref('stg_managers') }}
),

returns AS (
    SELECT * FROM {{ ref('stg_returned_orders') }}
)

SELECT
    -- Unique key for silver layer
    base_orders.dwh_id AS unique_key,

    -- All columns from base orders
    base_orders.dwh_id AS order_line_id,
    base_orders.order_id,
    base_orders.order_date,
    base_orders.ship_date,
    base_orders.ship_mode,
    base_orders.customer_id,
    base_orders.customer_name,
    base_orders.segment,
    base_orders.country_region,
    base_orders.city,
    base_orders.state,
    base_orders.postal_code,
    base_orders.region,
    base_orders.product_id,
    base_orders.category,
    base_orders.sub_category,
    base_orders.product_name,
    base_orders.sales,
    base_orders.quantity,
    base_orders.discount,
    base_orders.profit,

    -- Calendar enrichment
    calendar.year AS order_year,
    calendar.month AS order_month,
    calendar.month_name AS order_month_name,
    calendar.day_of_week AS order_day_of_week,
    calendar.is_weekend AS calendar_is_weekend,

    -- Manager enrichment
    managers.manager_name AS regional_manager,

    -- Returns enrichment
    returns.returned,

    -- Derived columns using CASE statements
    (returns.returned = 'Yes') AS is_returned,
    COALESCE(calendar.is_weekend, FALSE) AS is_weekend,

    -- ETL timestamp
    CURRENT_TIMESTAMP AS etl_timestamp

FROM base_orders

LEFT JOIN calendar
    ON base_orders.order_date = calendar.date_day

LEFT JOIN managers
    ON base_orders.region = managers.region

LEFT JOIN returns
    ON base_orders.order_id = returns.order_id
