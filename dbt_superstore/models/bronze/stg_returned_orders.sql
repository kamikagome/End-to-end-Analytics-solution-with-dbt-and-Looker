{{ config(
  materialized='view',
  alias='returned_orders'
) }}

SELECT
    order_id,
    returned,
    ROW_NUMBER() OVER (ORDER BY order_id) AS dwh_id,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM {{ source('superstore', 'returns') }}
