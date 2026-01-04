# dbt Doc Blocks - Quick Guide

## What We Created

**File:** [models/docs.md](models/docs.md) - Centralized documentation for all models and columns

**Usage:** Referenced in [models/bronze/schema.yml](models/bronze/schema.yml) using `{{ doc("block_name") }}`

---

## How It Works

### 1. Define Doc Blocks (models/docs.md)

```markdown
{% docs stg_orders %}
This staging model contains raw orders data...
{% enddocs %}

{% docs dwh_id %}
**Data Warehouse ID** - The primary key...
{% enddocs %}
```

### 2. Reference in Schema (models/bronze/schema.yml)

```yaml
models:
  - name: stg_orders
    description: '{{ doc("stg_orders") }}'
    columns:
      - name: dwh_id
        description: '{{ doc("dwh_id") }}'
```

---

## Benefits

✅ **Write once, use everywhere** - `dwh_id` description used in 3 models
✅ **Rich formatting** - Markdown, tables, lists
✅ **Easy updates** - Change once, updates all references
✅ **Better documentation** - More detailed and consistent

---

## View Documentation

```bash
cd /Users/genkisudo/Documents/end-to-end/dbt_superstore

# Generate docs
dbt docs generate

# View in browser
dbt docs serve
```

This opens interactive documentation with:
- Model descriptions
- Column details
- Lineage DAG
- Test coverage

---

## Doc Blocks Created

| Doc Block | Type | Used In |
|-----------|------|---------|
| `stg_orders` | Model | stg_orders |
| `stg_managers` | Model | stg_managers |
| `stg_returned_orders` | Model | stg_returned_orders |
| `dwh_id` | Column | All 3 models (reused!) |
| `etl_timestamp` | Column | All 3 models (reused!) |
| `sales_column` | Column | stg_orders |
| `quantity_column` | Column | stg_orders |
| `order_id_column` | Column | stg_returned_orders |

---

## Syntax

**Define:**
```markdown
{% docs block_name %}
Your description with **markdown**
{% enddocs %}
```

**Reference:**
```yaml
description: '{{ doc("block_name") }}'
```

**Important:** Use single quotes!

---

## Resources

- Full guide: [DOC_BLOCKS_GUIDE.md](DOC_BLOCKS_GUIDE.md)
- dbt docs: https://docs.getdbt.com/reference/resource-properties/description#use-a-docs-block-in-a-description
