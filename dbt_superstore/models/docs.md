# dbt Documentation Blocks

{# ========================================
   MODEL-LEVEL DESCRIPTIONS
   ======================================== #}

{% docs stg_orders %}

This staging model contains raw orders data from the Superstore dataset.

It performs basic transformations:
- Renames `row_id` to `dwh_id` (data warehouse ID)
- Adds `etl_timestamp` to track when data was loaded
- Maintains 1:1 relationship with source data

**Business Use:**
- Foundation for all order-related analytics
- Contains sales, profit, and customer information
- Links to products and geographic data

{% enddocs %}

{% docs stg_managers %}

This staging model contains information about regional managers.

**Data Source:** People table from Superstore
**Purpose:** Maps regions to their responsible managers

{% enddocs %}

{% docs stg_returned_orders %}

This staging model tracks orders that were returned by customers.

**Key Information:**
- Links to orders via `order_id`
- Indicates which orders resulted in returns
- Used for return rate analysis

{% enddocs %}

{# ========================================
   COMMON COLUMN DESCRIPTIONS
   ======================================== #}

{% docs dwh_id %}

**Data Warehouse ID** - The primary key for this table in the data warehouse.

This is a transformed version of the source `row_id` column, providing a unique identifier for each record.

{% enddocs %}

{% docs etl_timestamp %}

**ETL Timestamp** - The datetime when this record was loaded into the data warehouse.

Generated using `CURRENT_TIMESTAMP` during data ingestion.

**Usage:**
- Track data freshness
- Audit data loads
- Debug data pipeline issues

{% enddocs %}

{# ========================================
   SPECIFIC COLUMN DESCRIPTIONS
   ======================================== #}

{% docs sales_column %}

**Sales Amount** - The total revenue from this order in USD.

**Business Rules:**
- Must be positive (validated by `is_positive` test)
- Does not include discounts (discounts are tracked separately)
- Before any returns are processed

{% enddocs %}

{% docs quantity_column %}

**Quantity Ordered** - The number of units ordered.

**Validation:**
- Must be positive (> 0)
- Integer values only

{% enddocs %}

{% docs order_id_column %}

**Order ID** - Unique identifier for each order.

**Format:** String/varchar
**Uniqueness:** Should be unique at the order level (may have multiple rows per order if multiple products)

{% enddocs %}
