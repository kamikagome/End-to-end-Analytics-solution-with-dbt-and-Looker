# dbt Meta Tags Guide

## Overview

Meta tags provide additional metadata about your dbt models that don't fit into standard properties. They appear in the generated documentation and can be queried programmatically.

---

## Where Meta Tags Are Defined

### 1. Project-Level (dbt_project.yml)

Applied to all models in a folder:

```yaml
models:
  dbt_superstore:
    bronze:
      +materialized: view
      +meta:
        layer: bronze
        owner: data_engineering_team
        purpose: staging_layer
        data_quality_tier: raw
```

### 2. Model-Level (schema.yml)

Applied to specific models:

```yaml
models:
  - name: stg_orders
    meta:
      owner: data_engineering_team
      critical: true
      contains_pii: true
      refresh_frequency: daily
      business_domain: sales
```

---

## Meta Tags We Added

### Project-Level Tags (dbt_project.yml)

**Bronze Layer:**
- `layer: bronze` - Data layer classification
- `owner: data_engineering_team` - Team responsible
- `purpose: staging_layer` - Purpose of these models
- `data_quality_tier: raw` - Quality tier
- `description` - Layer description

**Examples Folder:**
- `layer: examples` - Example/documentation layer
- `purpose: documentation` - Educational purpose
- `data_quality_tier: example` - Not production data

---

### Model-Level Tags (schema.yml)

**stg_orders:**
```yaml
meta:
  owner: data_engineering_team
  critical: true                    # Business-critical model
  contains_pii: true                # Contains customer data
  refresh_frequency: daily          # How often to refresh
  business_domain: sales            # Business area
  upstream_dependencies:
    - superstore.orders
```

**stg_managers:**
```yaml
meta:
  owner: data_engineering_team
  critical: false                   # Not business-critical
  contains_pii: true                # Contains manager names
  refresh_frequency: weekly         # Refreshed weekly
  business_domain: people
  upstream_dependencies:
    - superstore.people
```

**stg_returned_orders:**
```yaml
meta:
  owner: data_engineering_team
  critical: true                    # Important for analytics
  contains_pii: false               # No personal data
  refresh_frequency: daily
  business_domain: sales
  upstream_dependencies:
    - superstore.returns
```

---

## Meta Tag Descriptions

| Tag | Purpose | Example Values |
|-----|---------|----------------|
| `owner` | Team/person responsible | `data_engineering_team`, `analytics_team` |
| `layer` | Data layer (medallion) | `bronze`, `silver`, `gold`, `examples` |
| `critical` | Business criticality | `true`, `false` |
| `contains_pii` | Has personal data | `true`, `false` |
| `refresh_frequency` | Update cadence | `hourly`, `daily`, `weekly` |
| `business_domain` | Business area | `sales`, `people`, `finance` |
| `purpose` | Model purpose | `staging_layer`, `documentation`, `reporting` |
| `data_quality_tier` | Quality level | `raw`, `validated`, `trusted`, `example` |
| `upstream_dependencies` | Source tables | List of source tables |

---

## Benefits of Meta Tags

### ✅ 1. Enhanced Documentation

Meta tags appear in `dbt docs`:
- Model details page shows all meta fields
- Searchable and filterable
- Provides context beyond descriptions

### ✅ 2. Data Governance

Track important attributes:
- **PII identification** for compliance (GDPR, CCPA)
- **Ownership** for accountability
- **Criticality** for SLA prioritization

### ✅ 3. Programmatic Access

Query meta tags using dbt artifacts:

```python
import json

# Read manifest.json
with open('target/manifest.json') as f:
    manifest = json.load(f)

# Find PII models
pii_models = [
    node['name']
    for node in manifest['nodes'].values()
    if node.get('meta', {}).get('contains_pii')
]
```

### ✅ 4. Operational Insights

Use for:
- Alert routing (owner)
- Refresh scheduling (refresh_frequency)
- Impact analysis (critical)
- Compliance auditing (contains_pii)

---

## How to View Meta Tags

### In dbt Docs

```bash
cd /Users/genkisudo/Documents/end-to-end/dbt_superstore

# Generate docs
dbt docs generate

# View in browser
dbt docs serve
```

Navigate to any model → See "Details" section with all meta tags

---

### In manifest.json

```bash
# Generate manifest
dbt compile

# View meta for specific model
cat target/manifest.json | jq '.nodes[] | select(.name == "stg_orders") | .meta'
```

Output:
```json
{
  "owner": "data_engineering_team",
  "critical": true,
  "contains_pii": true,
  "refresh_frequency": "daily",
  "business_domain": "sales",
  "upstream_dependencies": [
    "superstore.orders"
  ]
}
```

---

## Common Meta Tag Patterns

### Data Governance Tags
```yaml
meta:
  contains_pii: true
  data_classification: confidential  # public, internal, confidential, restricted
  retention_period: 7_years
  compliance_frameworks:
    - GDPR
    - CCPA
```

### Operational Tags
```yaml
meta:
  owner: data_engineering_team
  on_call: john.doe@company.com
  slack_channel: "#data-engineering"
  critical: true
  sla_hours: 4
```

### Business Tags
```yaml
meta:
  business_domain: sales
  product_area: e-commerce
  stakeholders:
    - sales_team
    - finance_team
  kpis:
    - revenue
    - conversion_rate
```

### Technical Tags
```yaml
meta:
  layer: silver
  refresh_frequency: hourly
  data_quality_tier: validated
  upstream_dependencies:
    - bronze.stg_orders
  performance_tier: high  # high, medium, low
```

---

## Best Practices

### ✅ Do's

1. **Use Consistent Naming**
   ```yaml
   # Good
   owner: data_engineering_team

   # Avoid
   Owner: Data Engineering Team
   ```

2. **Document at Right Level**
   - Project-level: Common attributes (layer, owner)
   - Model-level: Specific attributes (critical, contains_pii)

3. **Keep Values Simple**
   ```yaml
   # Good
   critical: true

   # Avoid
   critical: "yes, very important"
   ```

4. **Use Lists for Multiple Values**
   ```yaml
   upstream_dependencies:
     - source1
     - source2
   ```

### ❌ Don'ts

1. **Don't Overuse**
   - Only add tags that provide value
   - Not every attribute needs a meta tag

2. **Don't Duplicate Documentation**
   ```yaml
   # Bad - already in description
   meta:
     description: "This is an orders table"
   ```

3. **Don't Use for Configurations**
   ```yaml
   # Bad - use config instead
   meta:
     materialized: table

   # Good
   config:
     materialized: table
   ```

---

## Querying Meta Tags

### Python Script Example

```python
import json

def get_pii_models(manifest_path='target/manifest.json'):
    """Get all models containing PII"""
    with open(manifest_path) as f:
        manifest = json.load(f)

    pii_models = []
    for node_id, node in manifest['nodes'].items():
        if node['resource_type'] == 'model':
            meta = node.get('meta', {})
            if meta.get('contains_pii'):
                pii_models.append({
                    'name': node['name'],
                    'owner': meta.get('owner'),
                    'critical': meta.get('critical'),
                    'domain': meta.get('business_domain')
                })

    return pii_models

# Usage
pii_models = get_pii_models()
for model in pii_models:
    print(f"{model['name']}: {model['owner']} - Critical: {model['critical']}")
```

### SQL Query in Warehouse

If you expose manifest metadata:

```sql
SELECT
    model_name,
    meta_owner,
    meta_critical,
    meta_contains_pii,
    meta_business_domain
FROM dbt_metadata.models
WHERE meta_contains_pii = true
ORDER BY meta_critical DESC;
```

---

## Integration Examples

### 1. Alert Routing

```python
# Send alerts to model owner
def send_failure_alert(model_name):
    meta = get_model_meta(model_name)
    owner = meta.get('owner', 'default_team')
    slack_channel = f"#{owner}"
    send_slack(slack_channel, f"Model {model_name} failed!")
```

### 2. Prioritized Monitoring

```python
# Monitor critical models more frequently
def get_monitoring_schedule():
    critical_models = get_models_by_meta('critical', True)
    return {
        'critical': {'interval': '5m', 'models': critical_models},
        'normal': {'interval': '1h', 'models': get_other_models()}
    }
```

### 3. Compliance Reporting

```python
# Generate PII inventory
def generate_pii_report():
    pii_models = get_pii_models()
    report = []
    for model in pii_models:
        report.append({
            'table': model['name'],
            'contains_pii': True,
            'owner': model['owner'],
            'compliance': 'GDPR applicable'
        })
    return report
```

---

## Summary

**What we added:**

| Location | Meta Tags | Purpose |
|----------|-----------|---------|
| **dbt_project.yml** | layer, owner, purpose, data_quality_tier | Folder-level classification |
| **schema.yml (stg_orders)** | owner, critical, contains_pii, refresh_frequency, business_domain, upstream_dependencies | Model-specific metadata |
| **schema.yml (stg_managers)** | Same structure | Model-specific metadata |
| **schema.yml (stg_returned_orders)** | Same structure | Model-specific metadata |

**Benefits:**
- 📚 Better documentation
- 🔒 Data governance
- 🤖 Programmatic access
- 📊 Operational insights

**View:**
```bash
dbt docs generate && dbt docs serve
```

Meta tags appear in model details and can be queried from manifest.json!
