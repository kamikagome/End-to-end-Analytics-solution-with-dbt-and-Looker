{% snapshot snp_product %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['product_name', 'category', 'sub_category'],
        invalidate_hard_deletes=True
    )
}}

-- Source: Extract distinct products from orders
-- SCD Type 2: Tracks changes to product_name, category, sub_category
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
    product_id,
    product_name,
    category,
    sub_category
FROM distinct_products

{% endsnapshot %}
