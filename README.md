# Azure PostgreSQL & dbt Core: Dimensional Modeling Pipeline

![Python](https://img.shields.io/badge/Python-3.x-blue?style=flat&logo=python)
![dbt](https://img.shields.io/badge/dbt-Core-orange?style=flat&logo=dbt)
![Azure](https://img.shields.io/badge/Azure-PostgreSQL-0078D4?style=flat&logo=microsoftazure)
![Status](https://img.shields.io/badge/Status-Active-success)

## Overview

This repository showcases an end-to-end data engineering solution focused on **Dimensional Modeling**. The project implements a Star Schema on a remote **Azure PostgreSQL** database to facilitate efficient Business Intelligence and Analytics.

The pipeline utilizes **dbt Core** for T-ELT (Transform) workflows, ensuring modular and testable data models, while the data warehouse is hosted on Azure.

![Project Architecture](IMG/architecture_diagram.png)

---

## Table of Contents

- [Prerequisites & Tech Stack](#prerequisites--tech-stack)
- [Project Roadmap](#project-roadmap)
- [Phase 1: Environment Setup & Ingestion](#phase-1-environment-setup--ingestion)
- [References](#references)

---

## Prerequisites & Tech Stack

Ensure your local development environment is configured with the following tools:

| Tool | Purpose |
| :--- | :--- |
| Azure Account | PostgreSQL instance hosting |
| Python 3.x | Data ingestion scripts |
| dbt Core | Data transformation |
| VS Code & Git | IDE and version control |
| DBeaver | SQL client for database access |

---

## Project Roadmap

| Week | Focus Area | Description |
| :--- | :--- | :--- |
| **01** | **Setup** | Repository cloning, environment configuration, and initialization |
| **02** | **Ingestion** | Database schema creation and data ingestion (Excel to PostgreSQL) |
| **03** | **Modeling** | Implementing dbt Core and building the Medallion Architecture |
| **04** | **CI/CD** | Pre-commit hooks, GitHub Actions, and incremental refresh strategies |

---

## Phase 1: Environment Setup & Ingestion

**Objective:** Initialize the database and ingest raw Excel data into Azure PostgreSQL staging tables.

### 1. Database Initialization

Connect to your Azure PostgreSQL instance using **DBeaver** and create the necessary schemas:

```sql
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dwh;
```

### 2. Python Environment Setup

Set up a local Python environment for data extraction and loading.

**Create and activate a virtual environment:**

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

**Install dependencies:**

```bash
pip install pandas psycopg2-binary python-dotenv xlrd
```

**Configure environment variables:**

Create a `.env` file in the project root:

```ini
AZURE_PG_HOST=yourserver.postgres.database.azure.com
AZURE_PG_DATABASE=your_database
AZURE_PG_USER=username@yourserver
AZURE_PG_PASSWORD=your_password
```

### 3. Data Ingestion

The project ingests the following raw data files from the `Data/` directory:

| File | Target Table | Description |
| :--- | :--- | :--- |
| `Orders.xls` | `stg.orders` | Sales order data (9,994 rows) |
| `People.xls` | `stg.people` | Regional manager assignments |
| `Returns.xls` | `stg.returns` | Order return records |

**Execute the ingestion script:**

```bash
python ingest_data.py
```

The script performs the following:

- Connects to Azure PostgreSQL via SSL
- Truncates existing data in target tables
- Batch inserts data from Excel files
- Converts date columns to PostgreSQL DATE format

### 4. Validation

Verify the data load by running:

```sql
SELECT COUNT(*) FROM stg.orders;
-- Expected: 9994
```

**Schema Diagrams:**

| Staging Layer | Dimensional Model |
| :---: | :---: |
| ![Staging Schema](img/stg.png) | ![Dimensional Schema](img/dim.png) |

---

## References

- [Surfalytics - End to End Analytics](https://github.com/surfalytics/end-to-end-analytics)
