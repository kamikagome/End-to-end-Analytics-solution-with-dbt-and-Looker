{{
    config(
        materialized='view',
        alias='dim_product'
    )
}}

-- SCD Type 2 Product Dimension
-- Sources from snapshot to track historical changes to product attributes
-- dbt_valid_from/dbt_valid_to define the validity period for each record version

SELECT
    dbt_scd_id AS product_sk,
    product_id,
    product_name,
    category,
    sub_category,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current,
    dbt_updated_at AS etl_timestamp
FROM {{ ref('snp_product') }}
