# Production Profile Configuration

This folder contains the **production** profile for dbt_superstore.

## Usage

To run dbt commands using this production profile:

```bash
# Run a specific model
dbt run --select model_name --profiles-dir ./conf/

# Run all models
dbt run --profiles-dir ./conf/

# Test models
dbt test --profiles-dir ./conf/

# Build (run + test)
dbt build --profiles-dir ./conf/
```

## Configuration

- **Target**: prod
- **Schema**: bronze
- **Database**: surfalytics_dw_kamil
- **Threads**: 4

⚠️ **WARNING**: This profile connects to production. Use with caution!
