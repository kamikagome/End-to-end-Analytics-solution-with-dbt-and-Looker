{{ config(
  materialized='view',
  alias='reg_managers'
) }}

SELECT
    regional_manager AS manager_name,
    region,
    row_number() OVER () AS dwh_id,
    current_timestamp AS etl_timestamp
FROM {{ source('superstore', 'people') }}
