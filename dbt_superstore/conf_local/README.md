# Development Profile Configuration

This folder contains the **development** profile for dbt_superstore.

## Usage

To run dbt commands using this dev profile:

```bash
# Run a specific model
dbt run --select model_name --profiles-dir ./conf_local/

# Run all models
dbt run --profiles-dir ./conf_local/

# Test models
dbt test --profiles-dir ./conf_local/

# Build (run + test)
dbt build --profiles-dir ./conf_local/
```

## Configuration

- **Target**: dev
- **Schema**: dev_bronze
- **Database**: surfalytics_dw_kamil
- **Threads**: 4

✅ Safe for development and testing
