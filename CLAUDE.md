# CLAUDE.md

## Environment
macOS | VS Code | Claude Code | Staff Data/Analytics Engineer

## Critical Don'ts
- No `DROP`/`DELETE` without `WHERE` + backup
- No secrets in git (`git secrets --scan`)
- No `SELECT *` in prod
- No untested migrations on prod
- No breaking schema changes (add-only)

## dbt Best Practices
```yaml
# models/staging/stg_orders.yml
version: 2
models:
  - name: stg_orders
    columns:
      - name: order_id
        tests: [unique, not_null]
```

```sql
-- Staging: 1:1 source, rename, cast, no joins
-- Intermediate: business logic, joins
-- Marts: final aggregates, wide tables

{{ config(materialized='incremental', unique_key='id') }}
SELECT * FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

**Structure**: `staging/` → `intermediate/` → `marts/`
**Naming**: `stg_`, `int_`, `fct_`, `dim_`
**Always**: `{{ ref() }}` over hardcoded tables

## Quick Commands
```bash
dbt run -s model+          # model + downstream
dbt test -s model          # test specific model
dbt build --full-refresh   # rebuild incremental
dbt source freshness       # check source data freshness
sqlfluff fix --dialect snowflake .
```
