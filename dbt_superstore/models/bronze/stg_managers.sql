{{ config(
  materialized='view',
  alias='reg_managers'
) }}

SELECT
    {{
        dbt_utils.generate_surrogate_key([
            'regional_manager',
            'region'
        ])
    }} AS dwh_id,
    regional_manager AS manager_name,
    region,
    CURRENT_TIMESTAMP AS etl_timestamp
FROM {{ source('superstore', 'people') }}
