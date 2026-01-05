{{
    config(
        materialized='table',
        alias='fct_sales'
    )
}}

WITH order_facts AS (
    SELECT
        -- Source keys for joining to dimensions
        order_line_id,
        order_id,
        order_date,
        product_id,
        customer_id,
        ship_mode,
        country_region,
        state,
        city,
        COALESCE(postal_code, 'UNKNOWN') AS postal_code,

        -- Metrics
        sales,
        quantity,
        discount,
        profit
    FROM {{ ref('int_orders_enriched') }}
),

-- Join to dimension tables to get surrogate keys
enriched_facts AS (
    SELECT
        f.order_line_id,
        f.order_id,

        -- Foreign Keys (Surrogate Keys from Dimension Tables)
        dp.product_sk,
        dc.customer_sk,
        ds.shipping_sk,
        dg.geo_sk,
        f.order_date AS date_id,

        -- Category for window function ranking
        dp.category,

        -- Metrics
        f.sales AS sales_amt,
        f.quantity AS items_number,
        f.profit,
        f.discount,

        -- Derived metric: estimated shipping cost
        -- Note: This is an approximation (10% of sales) as actual shipping data is not available
        CASE
            WHEN f.sales > 0 THEN ROUND(f.sales * 0.1, 2)
            ELSE 0
        END AS shipping_cost

    FROM order_facts f

    LEFT JOIN {{ ref('dim_product') }} dp
        ON f.product_id = dp.product_id

    LEFT JOIN {{ ref('dim_customer') }} dc
        ON f.customer_id = dc.customer_id

    LEFT JOIN {{ ref('dim_shipping') }} ds
        ON f.ship_mode = ds.ship_mode

    LEFT JOIN {{ ref('dim_geo') }} dg
        ON f.country_region = dg.country_region
        AND f.state = dg.state
        AND f.city = dg.city
        AND f.postal_code = dg.postal_code
),

final AS (
    SELECT
        -- Foreign Keys
        product_sk,
        customer_sk,
        shipping_sk,
        geo_sk,
        date_id,

        -- Transactional identifiers (for traceability)
        order_line_id,
        order_id,

        -- Metrics
        sales_amt,
        items_number,
        profit,
        discount,
        shipping_cost,

        -- Aggregated metric: order count (always 1 at this grain)
        1 AS orders_number,

        -- Window function: Cumulative sales by customer (deterministic with tie-breaker)
        SUM(sales_amt) OVER (
            PARTITION BY customer_sk
            ORDER BY date_id, order_line_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_sales_by_customer,

        -- Window function: Rank sales transactions by amount within each product category
        RANK() OVER (
            PARTITION BY category
            ORDER BY sales_amt DESC
        ) AS category_sales_rank,

        -- Metadata
        CURRENT_TIMESTAMP AS etl_timestamp,

        -- Add row number to ensure uniqueness
        ROW_NUMBER() OVER (ORDER BY order_line_id, order_id) AS row_num

    FROM enriched_facts
)

SELECT
    -- Generate fact table surrogate key using composite key including row_num to ensure uniqueness
    {{ dbt_utils.generate_surrogate_key(['order_line_id', 'order_id', 'row_num']) }} AS sales_sk,

    product_sk,
    customer_sk,
    shipping_sk,
    geo_sk,
    date_id,
    order_line_id,
    order_id,
    sales_amt,
    items_number,
    profit,
    discount,
    shipping_cost,
    orders_number,
    cumulative_sales_by_customer,
    category_sales_rank,
    etl_timestamp

FROM final
