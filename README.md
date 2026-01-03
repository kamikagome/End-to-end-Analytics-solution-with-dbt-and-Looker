# Data Engineering project

# Azure PostgreSQL & dbt Core: Dimensional Modeling Pipeline

![Status](https://img.shields.io/badge/Status-Active-success)
![Stack](https://img.shields.io/badge/Stack-dbt%20%7C%20Postgres%20%7C%20Azure%20%7C%20Pentaho-blue)

## 📖 Overview
This repository showcases an end-to-end data engineering solution focused on **Dimensional Modeling**. The project implements a Star Schema on a remote **Azure PostgreSQL** database to facilitate efficient Business Intelligence and Analytics.

The pipeline utilizes **Pentaho Data Integration (PDI)** for the initial ETL (Extract, Transform, Load) processes and **dbt Core** for T-ELT (Transform) workflows, ensuring modular and testable data models.

## 📋 Table of Contents
- [Prerequisites & Tech Stack](#-prerequisites--tech-stack)
- [Project Roadmap](#-project-roadmap)
- [Phase 1: Environment Setup](#phase-1-environment-setup)
- [Phase 2: Data Ingestion & ETL](#phase-2-data-ingestion--etl)
- [Phase 3: Data Modeling with dbt](#phase-3-data-modeling-with-dbt)
- [Phase 4: Quality Assurance & Optimization](#phase-4-quality-assurance--optimization)

---

## 🛠 Prerequisites & Tech Stack
Ensure your local development environment is configured with the following tools before proceeding:

* **Cloud/Database:** Azure Account (PostgreSQL instance).
* **ETL Engine:** Pentaho Data Integration (PDI) or equivalent tool.
* **Transformation:** Python 3.x & dbt Core.
* **IDE/Version Control:** VS Code & Git.
* **SQL Client:** DBeaver or standard PostgreSQL client.

---

## 🚀 Project Roadmap

| Week | Focus Area | Description |
| :--- | :--- | :--- |
| **01** | **Setup** | Repository cloning and environment configuration. |
| **02** | **Ingestion** | Building ETL pipelines with Pentaho to load raw data into Staging (STG) and Dimensions into the Data Warehouse (DWH). |
| **03** | **Modeling** | Implementing dbt Core, configuring profiles, and building the Medallion Architecture (Bronze/Silver/Gold). |
| **04** | **CI/CD** | Implementing pre-commit hooks, GitHub Actions, and comparing incremental refresh strategies. |

---

## Phase 1: Environment Setup
**Objective:** Clone the repository and prepare the workspace.

1.  Launch your terminal in VS Code (`Ctrl + \``).
2.  Clone the repository to your local machine:

```bash
git clone [https://github.com/aizhannna/data-projects.git](https://github.com/aizhannna/data-projects.git)
```

---

## Phase 2: Data Ingestion & ETL
**Objective:** Load raw data into the Azure PostgreSQL instance using Pentaho.

### 1. Database Connection
Use a SQL client (e.g., [DBeaver](https://dbeaver.io/download/)) to connect to your Azure instance.
* **Driver:** PostgreSQL
* **Host:** `<your-db-host>`
* **Port:** `5432`
* **Database:** `<your-db-name>`
* **Auth:** Enter your username and password.

> ![Connection Screenshot](./img/image.png)

### 2. Schema Initialization
Run the provided SQL scripts within your SQL client to initialize the required schemas and tables:
* **Staging Area:** Run [`create_tables.sql`](./SQL/create_tables.sql) to build tables for raw data.
* **Data Warehouse:** Run [`create_dim_tables.sql`](./SQL/create_dim_tables.sql) to build dimension tables.

### 3. Execution of ETL Workflows
Data loading is handled via Pentaho Data Integration (PDI). The source data (Excel) is transformed and loaded into the database.

1.  Launch PDI.
2.  Open the job file: [`ETL/superstore_workflow_job.kjb`](./ETL/superstore_workflow_job.kjb).
3.  Configure your **Database Connection** in PDI to match your Azure credentials.
4.  Execute the job.

> ![Workflow Screenshot 1](./img/image-2.png)
> ![Workflow Screenshot 2](./img/image-3.png)

### 4. Verification
Verify the data load by running the following counts in DBeaver:

```sql
-- Check Staging Tables
SELECT count(*) FROM stg.orders;
SELECT count(*) FROM stg.people;
SELECT count(*) FROM stg.returns;

-- Check Dimension Tables
SELECT count(*) FROM dwh.dim_customer;
SELECT count(*) FROM dwh.dim_geo;
SELECT count(*) FROM dwh.dim_shipping;
```

---

## Phase 3: Data Modeling with dbt
**Objective:** Configure dbt Core and construct the transformation layer using the Medallion Architecture.

### 1. Installation & Initialization
It is recommended to use a virtual environment for Python dependencies.

```bash
# Create and activate virtual environment
python3 -m venv venvs/dbt_env
source venvs/dbt_env/bin/activate
