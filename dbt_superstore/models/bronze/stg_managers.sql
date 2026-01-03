{{ config(
  materialized='view',
  alias='reg_managers'
) }}

SELECT
    row_number() OVER () AS dwh_id,
    regional_manager AS manager_name,
    region,
    current_timestamp AS etl_timestamp
FROM {{ source('superstore', 'people') }}
