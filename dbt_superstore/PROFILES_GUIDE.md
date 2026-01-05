# dbt Profile Configuration Guide

## Overview

Profiles are now split into separate folders:
- **[conf/](conf/)** - Production profile
- **[conf_local/](conf_local/)** - Development profile

## Usage Examples

### Development (Default)
```bash
# Use dev profile
dbt run --select model_name --profiles-dir ./conf_local/
dbt test --profiles-dir ./conf_local/
dbt build --profiles-dir ./conf_local/

# With downstream dependencies
dbt run --select model_name+ --profiles-dir ./conf_local/
```

### Production
```bash
# Use prod profile
dbt run --select model_name --profiles-dir ./conf/
dbt test --profiles-dir ./conf/
dbt build --profiles-dir ./conf/

# Full refresh for incremental models
dbt build --full-refresh --profiles-dir ./conf/
```

## Profile Details

| Profile | Target | Schema | Database | Threads |
|---------|--------|--------|----------|---------|
| conf_local | dev | dev_bronze | surfalytics_dw_kamil | 4 |
| conf | prod | bronze | surfalytics_dw_kamil | 4 |

## Shortcuts (Optional)

Add to your shell profile (~/.zshrc or ~/.bashrc):

```bash
# dbt shortcuts
alias dbt-dev='dbt --profiles-dir ./conf_local/'
alias dbt-prod='dbt --profiles-dir ./conf/'
```

Then use:
```bash
dbt-dev run --select my_model
dbt-prod run --select my_model
```

## Safety Checks

✅ **Before running on prod**:
1. Test on dev first: `dbt build --profiles-dir ./conf_local/`
2. Review SQL: `dbt compile --profiles-dir ./conf/`
3. Use `--select` for targeted runs
4. Never use `DROP`/`DELETE` without `WHERE`

## Migration from Old Setup

The old `~/.dbt/profiles.yml` is still intact and can be used with:
```bash
dbt run --profile dbt_superstore --target dev
dbt run --profile dbt_superstore --target prod
```

New approach is recommended for better organization and project portability.
