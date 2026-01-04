# dbt Unit Test Guide

## Unit Test Created

### `test_stg_orders_row_id_to_dwh_id`

**Location:** [models/bronze/schema.yml](models/bronze/schema.yml)

**What it tests:** Verifies that `row_id` is correctly renamed to `dwh_id` in the stg_orders model

**Configuration:**
```yaml
unit_tests:
  - name: test_stg_orders_row_id_to_dwh_id
    model: stg_orders
    given:
      - input: source('superstore', 'orders')
        rows:
          - {row_id: 1}
    expect:
      rows:
        - {dwh_id: 1}
```

---

## How It Works

1. **given:** Mock input data (source table with `row_id: 1`)
2. **expect:** Expected output (model with `dwh_id: 1`)
3. dbt runs the transformation and compares actual vs expected

---

## How to Run

```bash
cd /Users/genkisudo/Documents/end-to-end/dbt_superstore

# Run the unit test
dbt test --select test_stg_orders_row_id_to_dwh_id

# Or run all unit tests
dbt test --select test_type:unit
```

---

## Important Notes

⚠️ **Before running unit tests, create the source table:**

```bash
# Create empty source table (saves cost)
dbt run --select source:superstore.orders --empty
```

Or use `dbt build` which handles the order automatically:
```bash
dbt build --select stg_orders
```

---

## Output Example

**Success:**
```
1 of 1 START unit_test stg_orders::test_stg_orders_row_id_to_dwh_id ... [RUN]
1 of 1 PASS stg_orders::test_stg_orders_row_id_to_dwh_id ............. [PASS in 0.15s]

Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
```

**Failure:**
```
1 of 1 FAIL 1 stg_orders::test_stg_orders_row_id_to_dwh_id ........... [FAIL 1 in 0.18s]

actual differs from expected:
@@ ,dwh_id
→  ,2
   ,1
```

---

## Difference: Unit Tests vs Data Tests

| Feature | Unit Tests | Data Tests |
|---------|-----------|------------|
| **When** | Before building model | After building model |
| **Data** | Static mock data | Real data in warehouse |
| **Purpose** | Test SQL logic | Test data quality |
| **Speed** | Fast (small data) | Slower (real data) |
| **Use Case** | Complex transformations | Business rules |

---

## Resources

- Full documentation: [tests/README.md](tests/README.md)
- Unit test reference: CLAUDE.md line #92+
