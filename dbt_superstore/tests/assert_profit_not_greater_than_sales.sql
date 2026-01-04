-- Singular Data Test: Profit should never exceed sales
-- Returns records where profit > sales to fail the test

SELECT
    dwh_id,
    order_id,
    sales,
    profit
FROM {{ ref('stg_orders') }}
WHERE profit > sales
