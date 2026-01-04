# dbt-postgres Incremental Strategies Comparison

## Overview
This document compares the three incremental strategies supported by dbt-postgres: `append`, `merge`, and `delete+insert`.

---

## Strategy Comparison Table

| Feature | append | merge | delete+insert |
|---------|--------|-------|---------------|
| **SQL Operation** | INSERT | MERGE (or INSERT + UPDATE) | DELETE + INSERT |
| **Handles Updates** | ❌ No | ✅ Yes | ✅ Yes |
| **Prevents Duplicates** | ❌ No | ✅ Yes (with unique_key) | ✅ Yes (with unique_key) |
| **Requires unique_key** | No | Recommended | Required |
| **Performance (Small Data)** | ⚡ Fastest | 🐌 Slowest | 🏃 Medium |
| **Performance (Large Data)** | ⚡ Fast | 🐌 Very Slow | 🏃 Medium |
| **Use Case** | Immutable events | SCD Type 1, Dimensions | Complex updates, late arrivals |

---

## SQL Implementation Details

### 1. APPEND Strategy

**Configuration:**
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='dwh_id'
) }}
```

**Generated SQL (Incremental Run):**
```sql
-- Step 1: Create temporary table with new data
CREATE TEMPORARY TABLE "my_schema"."orders_incremental_append__dbt_tmp" AS (
  SELECT
    row_id AS dwh_id,
    order_id,
    order_date,
    -- ... other columns
    current_timestamp AS etl_timestamp
  FROM "raw"."orders"
  WHERE order_date > (SELECT MAX(order_date) FROM "my_schema"."orders_incremental_append")
);

-- Step 2: Simple INSERT - just append new rows
INSERT INTO "my_schema"."orders_incremental_append" (
  dwh_id, order_id, order_date, ship_date, -- ... all columns
)
SELECT
  dwh_id, order_id, order_date, ship_date, -- ... all columns
FROM "my_schema"."orders_incremental_append__dbt_tmp";
```

**Key Characteristics:**
- ✅ Fastest execution
- ✅ Lowest resource usage
- ❌ No duplicate checking
- ❌ No updates to existing records
- ⚠️ If source has duplicate keys, table will have duplicates

---

### 2. MERGE Strategy

**Configuration:**
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='dwh_id'
) }}
```

**Generated SQL (Incremental Run):**
```sql
-- Step 1: Create temporary table with new/updated data
CREATE TEMPORARY TABLE "my_schema"."orders_incremental_merge__dbt_tmp" AS (
  SELECT
    row_id AS dwh_id,
    order_id,
    order_date,
    -- ... other columns
    current_timestamp AS etl_timestamp
  FROM "raw"."orders"
  WHERE order_date >= (SELECT MAX(order_date) - INTERVAL '7 days'
                       FROM "my_schema"."orders_incremental_merge")
);

-- Step 2: MERGE operation (Postgres doesn't have native MERGE until v15+)
-- For Postgres < 15, dbt uses a combination of UPDATE and INSERT:

-- Update existing records
UPDATE "my_schema"."orders_incremental_merge" AS target
SET
  order_id = source.order_id,
  order_date = source.order_date,
  ship_date = source.ship_date,
  -- ... update all columns
  etl_timestamp = source.etl_timestamp
FROM "my_schema"."orders_incremental_merge__dbt_tmp" AS source
WHERE target.dwh_id = source.dwh_id;

-- Insert new records (those that weren't updated)
INSERT INTO "my_schema"."orders_incremental_merge" (
  dwh_id, order_id, order_date, ship_date, -- ... all columns
)
SELECT
  dwh_id, order_id, order_date, ship_date, -- ... all columns
FROM "my_schema"."orders_incremental_merge__dbt_tmp" AS source
WHERE NOT EXISTS (
  SELECT 1
  FROM "my_schema"."orders_incremental_merge" AS target
  WHERE target.dwh_id = source.dwh_id
);
```

**For Postgres 15+ with native MERGE:**
```sql
MERGE INTO "my_schema"."orders_incremental_merge" AS target
USING "my_schema"."orders_incremental_merge__dbt_tmp" AS source
ON target.dwh_id = source.dwh_id
WHEN MATCHED THEN
  UPDATE SET
    order_id = source.order_id,
    order_date = source.order_date,
    -- ... all columns
    etl_timestamp = source.etl_timestamp
WHEN NOT MATCHED THEN
  INSERT (dwh_id, order_id, order_date, -- ... all columns)
  VALUES (source.dwh_id, source.order_id, source.order_date, -- ... all values);
```

**Key Characteristics:**
- ✅ Handles both inserts and updates (UPSERT)
- ✅ Prevents duplicates
- ✅ Ideal for SCD Type 1 (overwrite with latest)
- ❌ Expensive: full table scan to find matches
- ⚠️ Can be slow for large destination tables

---

### 3. DELETE+INSERT Strategy

**Configuration:**
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='dwh_id'
) }}
```

**Generated SQL (Incremental Run):**
```sql
-- Step 1: Create temporary table with new/updated data
CREATE TEMPORARY TABLE "my_schema"."orders_incremental_delete_insert__dbt_tmp" AS (
  SELECT
    row_id AS dwh_id,
    order_id,
    order_date,
    -- ... other columns
    current_timestamp AS etl_timestamp
  FROM "raw"."orders"
  WHERE order_date >= (SELECT MAX(order_date) - INTERVAL '7 days'
                       FROM "my_schema"."orders_incremental_delete_insert")
);

-- Step 2: DELETE matching records
DELETE FROM "my_schema"."orders_incremental_delete_insert" AS target
WHERE EXISTS (
  SELECT 1
  FROM "my_schema"."orders_incremental_delete_insert__dbt_tmp" AS source
  WHERE target.dwh_id = source.dwh_id
);

-- Step 3: INSERT fresh records
INSERT INTO "my_schema"."orders_incremental_delete_insert" (
  dwh_id, order_id, order_date, ship_date, -- ... all columns
)
SELECT
  dwh_id, order_id, order_date, ship_date, -- ... all columns
FROM "my_schema"."orders_incremental_delete_insert__dbt_tmp";
```

**Key Characteristics:**
- ✅ Complete record replacement (all columns refreshed)
- ✅ Prevents duplicates
- ✅ Better performance than merge for moderate datasets
- ❌ Requires DELETE permission
- ⚠️ No partial column updates (entire row replaced)
- ⚠️ May impact referential integrity during execution

---

## Detailed Comparison: SQL Execution Plans

### Scenario: 1 million existing rows, 1000 new rows, 100 updates

| Strategy | SQL Steps | Table Scans | Writes | Relative Cost |
|----------|-----------|-------------|--------|---------------|
| **append** | 1. CREATE TEMP<br>2. INSERT | 0 | 1,000 INSERTs | 1x (baseline) |
| **merge** | 1. CREATE TEMP<br>2. UPDATE (full scan)<br>3. INSERT (with NOT EXISTS) | 2 full scans | 100 UPDATEs<br>900 INSERTs | 10-50x |
| **delete+insert** | 1. CREATE TEMP<br>2. DELETE (with EXISTS)<br>3. INSERT | 1 scan (for DELETE) | 1,000 DELETEs<br>1,000 INSERTs | 3-5x |

---

## When to Use Each Strategy

### Use APPEND when:
- ✅ Data is immutable (events, logs, transactions)
- ✅ No updates to historical records
- ✅ Source guarantees no duplicates
- ✅ Maximum performance needed
- ✅ Late-arriving data is impossible

**Example Use Cases:**
- Web clickstream events
- Application logs
- IoT sensor readings
- Financial transactions (append-only ledger)

---

### Use MERGE when:
- ✅ Need to handle both inserts and updates
- ✅ Implementing SCD Type 1 (overwrite)
- ✅ Destination table is small/medium (<10M rows)
- ✅ Source may have duplicates to deduplicate
- ✅ Only specific columns need updating (`merge_update_columns`)

**Example Use Cases:**
- Customer dimension tables
- Product catalogs
- Reference data (countries, categories)
- User profiles

**Advanced Config (Partial Updates):**
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='customer_id',
    merge_update_columns=['email', 'phone', 'updated_at']
    -- Only updates these columns, keeps others unchanged
) }}
```

---

### Use DELETE+INSERT when:
- ✅ Need complete record replacement
- ✅ All columns must be refreshed
- ✅ Handling late-arriving data
- ✅ Destination table is medium/large
- ✅ More efficient than merge for your data volume
- ✅ Merge is unavailable or underperforming

**Example Use Cases:**
- Daily snapshots with corrections
- Data quality fixes (reprocess last N days)
- Complex transformations where partial updates are risky
- Fact tables with late-arriving dimensions

---

## Materialization Strategy Decision Tree

```
Is your data immutable (never updates)?
│
├─ YES → Use APPEND
│
└─ NO → Do you need to update existing records?
    │
    ├─ NO → Use APPEND
    │
    └─ YES → How large is your destination table?
        │
        ├─ Small (<1M rows) → Use MERGE
        │
        └─ Large (>1M rows) → Do you need partial column updates?
            │
            ├─ YES → Use MERGE with merge_update_columns
            │
            └─ NO (full record replacement) → Use DELETE+INSERT
```

---

## Performance Benchmarks (Example)

Based on a typical Postgres setup with 10M row destination table:

| Operation | append | merge | delete+insert |
|-----------|--------|-------|---------------|
| Insert 1K new rows | 0.5s | 45s | 2s |
| Update 1K rows | N/A | 47s | 3s |
| Insert 100K rows | 5s | 380s | 25s |
| Update 100K rows | N/A | 420s | 35s |

*Note: Actual performance depends on hardware, indexes, data distribution, and Postgres configuration.*

---

## Best Practices

### For APPEND:
```sql
-- Always filter to only new data
{% if is_incremental() %}
  WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}
```

### For MERGE:
```sql
-- Include a lookback window to handle late arrivals
{% if is_incremental() %}
  WHERE updated_at >= (SELECT MAX(updated_at) - INTERVAL '3 days' FROM {{ this }})
{% endif %}

-- Use partial updates for efficiency
{{ config(
    merge_update_columns=['status', 'updated_at']
) }}
```

### For DELETE+INSERT:
```sql
-- Process bounded date ranges to limit deletes
{% if is_incremental() %}
  WHERE order_date >= (SELECT MAX(order_date) - INTERVAL '7 days' FROM {{ this }})
{% endif %}

-- Consider partitioning for very large tables
{{ config(
    incremental_strategy='delete+insert',
    unique_key='dwh_id',
    partition_by={'field': 'order_date', 'data_type': 'date'}
) }}
```

---

## Testing Your Strategy

Run this test to validate behavior:

```bash
# 1. Initial full refresh (creates table)
dbt run --select orders_incremental_append --full-refresh

# 2. First incremental run
dbt run --select orders_incremental_append

# 3. Check for duplicates
# In your database:
SELECT dwh_id, COUNT(*)
FROM examples.orders_incremental_append
GROUP BY dwh_id
HAVING COUNT(*) > 1;

# 4. Test update behavior
# Modify source data, then:
dbt run --select orders_incremental_merge

# 5. Verify updates
SELECT * FROM examples.orders_incremental_merge
WHERE dwh_id = <test_id>
ORDER BY etl_timestamp DESC;
```

---

## Migration Between Strategies

If you need to change strategies:

```bash
# Option 1: Full refresh (rebuilds entire table)
dbt run --select orders_incremental_merge --full-refresh

# Option 2: Drop and recreate
DROP TABLE IF EXISTS examples.orders_incremental_merge;
dbt run --select orders_incremental_merge
```

---

## Summary

| Strategy | Best For | SQL Operations | Performance | Complexity |
|----------|----------|----------------|-------------|------------|
| **append** | Immutable data | INSERT | ⚡⚡⚡ Fastest | ⭐ Simple |
| **merge** | SCD Type 1, small dims | UPDATE + INSERT | 🐌 Slowest | ⭐⭐⭐ Complex |
| **delete+insert** | Full replacement, fact tables | DELETE + INSERT | 🏃 Medium | ⭐⭐ Medium |

**Rule of Thumb:**
- Start with `append` if data never changes
- Use `merge` for dimension tables < 10M rows
- Use `delete+insert` for fact tables or when merge is too slow
- Always benchmark with your actual data!

---

## Additional Resources

- [dbt-postgres Documentation](https://docs.getdbt.com/reference/resource-configs/postgres-configs#incremental-materialization-strategies)
- [dbt Incremental Models Guide](https://docs.getdbt.com/docs/build/incremental-models)
- [Postgres MERGE Command (v15+)](https://www.postgresql.org/docs/15/sql-merge.html)
