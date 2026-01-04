{{ config(
  materialized='view',
  alias='returned_orders'
) }}

SELECT
    order_id,
    returned,
    row_number() OVER () AS dwh_id,
    current_timestamp AS etl_timestamp
FROM {{ source('superstore', 'returns') }}
