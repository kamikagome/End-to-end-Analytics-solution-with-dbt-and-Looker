{{ config(
  materialized='view',
  alias='returned_orders'
) }}

SELECT
    row_number() OVER () AS dwh_id,
    order_id,
    returned,
    current_timestamp AS etl_timestamp
FROM {{ source('superstore', 'returns') }}
