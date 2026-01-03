# Data Engineering project
# Azure PostgreSQL & dbt Core: Dimensional Modeling Pipeline

## 📖 Overview
This repository showcases an end-to-end data engineering solution focused on **Dimensional Modeling**. The project implements a Star Schema on a remote **Azure PostgreSQL** database to facilitate efficient Business Intelligence and Analytics.

The pipeline utilizes **dbt Core** for T-ELT (Transform) workflows, ensuring modular and testable data models, while the data warehouse is hosted on Azure.

## 📋 Table of Contents
- [Prerequisites & Tech Stack](#-prerequisites--tech-stack)
- [Project Roadmap](#-project-roadmap)
- [Phase 1: Environment Setup](#phase-1-environment-setup)
- [Phase 2: Data Ingestion](#phase-2-data-ingestion)
- [Phase 3: Data Modeling with dbt](#phase-3-data-modeling-with-dbt)
- [Phase 4: Quality Assurance & Optimization](#phase-4-quality-assurance--optimization)

---

## 🛠 Prerequisites & Tech Stack
Ensure your local development environment is configured with the following tools before proceeding:

* **Cloud/Database:** Azure Account (PostgreSQL instance).
* **Transformation:** Python 3.x & dbt Core.
* **IDE/Version Control:** VS Code & Git.
* **SQL Client:** DBeaver or standard PostgreSQL client.

---

## 🚀 Project Roadmap

| Week | Focus Area | Description |
| :--- | :--- | :--- |
| **01** | **Setup** | Repository cloning and environment configuration. |
| **02** | **Ingestion** | Setting up the database schema and preparing Staging (STG) and Dimensions (DWH). |
| **03** | **Modeling** | Implementing dbt Core, configuring profiles, and building the Medallion Architecture (Bronze/Silver/Gold). |
| **04** | **CI/CD** | Implementing pre-commit hooks, GitHub Actions, and comparing incremental refresh strategies. |

---

## Phase 1: Environment Setup
**Objective:** Clone the repository and prepare the workspace.

1.  Launch your terminal in VS Code (`Ctrl + \``).
2.  Clone the repository to your local machine:

```bash
git clone [https://github.com/aizhannna/data-projects.git](https://github.com/aizhannna/data-projects.git)