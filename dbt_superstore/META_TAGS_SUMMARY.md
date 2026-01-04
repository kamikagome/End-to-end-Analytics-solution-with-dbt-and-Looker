# Meta Tags Summary

## What We Added

### 📁 Project-Level (dbt_project.yml)

**Bronze Layer:**
```yaml
+meta:
  layer: bronze
  owner: data_engineering_team
  purpose: staging_layer
  data_quality_tier: raw
```

**Examples Folder:**
```yaml
+meta:
  layer: examples
  owner: data_engineering_team
  purpose: documentation
  data_quality_tier: example
```

---

### 📋 Model-Level (models/bronze/schema.yml)

**All models include:**

| Model | Critical | PII | Refresh | Domain |
|-------|----------|-----|---------|--------|
| stg_orders | ✅ true | ✅ true | daily | sales |
| stg_managers | ❌ false | ✅ true | weekly | people |
| stg_returned_orders | ✅ true | ❌ false | daily | sales |

**Full structure for each:**
```yaml
meta:
  owner: data_engineering_team
  critical: true/false
  contains_pii: true/false
  refresh_frequency: daily/weekly
  business_domain: sales/people
  upstream_dependencies:
    - source_table
```

---

## Benefits

✅ **Documentation** - Visible in `dbt docs`
✅ **Governance** - Track PII, ownership, criticality
✅ **Programmatic** - Query from manifest.json
✅ **Operational** - Alert routing, SLA prioritization

---

## View in dbt Docs

```bash
cd /Users/genkisudo/Documents/end-to-end/dbt_superstore
dbt docs generate
dbt docs serve
```

Navigate to any model → "Details" section shows all meta tags

---

## Query Programmatically

```bash
# View meta for stg_orders
dbt compile
cat target/manifest.json | jq '.nodes[] | select(.name == "stg_orders") | .meta'
```

Output:
```json
{
  "owner": "data_engineering_team",
  "critical": true,
  "contains_pii": true,
  "refresh_frequency": "daily",
  "business_domain": "sales"
}
```

---

## Files Modified

- ✅ **dbt_project.yml** - Folder-level meta tags
- ✅ **models/bronze/schema.yml** - Model-level meta tags

**Documentation:**
- 📚 [META_TAGS_GUIDE.md](META_TAGS_GUIDE.md) - Complete guide
- 📝 [META_TAGS_SUMMARY.md](META_TAGS_SUMMARY.md) - This file
