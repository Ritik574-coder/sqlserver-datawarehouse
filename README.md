# 🏛️ BusinessDW — Business Data Warehouse

> A production-grade **SQL Server Data Warehouse** built using the **Medallion Architecture (Bronze → Silver → Gold)**, integrating multi-source enterprise data into analytics-ready dimensional models.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#️-architecture)
- [Data Sources](#-data-sources)
- [Data Layers](#-data-layers)
- [Data Flow & Lineage](#-data-flow--lineage)
- [ETL Workflow](#-etl-workflow)
- [Gold Layer Outputs](#-gold-layer-outputs)
- [Tech Stack](#️-tech-stack)
- [Author](#-author)

---

## 🧭 Project Overview

**BusinessDW** is a comprehensive Business Data Warehouse built on **SQL Server** that integrates data from two enterprise source systems — **CRM** and **ERP** — and transforms raw operational data into structured, analytics-ready information.

The project follows the **Medallion Architecture** — a layered data design pattern that ensures traceability, data quality, and business-readiness at each stage of the pipeline.

**Key Goals:**
- Integrate multi-source enterprise data (CRM + ERP)
- Build a reliable, auditable ingestion pipeline
- Apply data cleansing, standardization, and business rules
- Deliver dimensional models ready for BI, reporting, and analytics

---

## 🏗️ Architecture

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Sources │────▶│    BRONZE    │────▶│    SILVER    │────▶│     GOLD     │────▶│    Consumers    │
│ CRM / ERP│     │   Raw Data   │     │ Clean & Std  │     │Business-Ready│     │ BI / Analytics  │
└──────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └─────────────────┘
```
---
## Visual_architeture

![Alt text](/home/ritik/data-ecosystem-platform/Data Warehouse/BusinessDW/Docs/data_architecture.png)


The data warehouse is structured as a **SQL Server** database with three schema layers, each serving a distinct purpose in the data pipeline.

---

## 📂 Data Sources

Data is ingested from two enterprise systems via **CSV file extracts** (batch ingestion):

### 🔵 CRM System

| File | Description |
|------|-------------|
| `cust_info.csv` | Customer master information |
| `prd_info.csv` | Product details |
| `sales_details.csv` | Transactional sales / order records |

### 🟢 ERP System

| File | Description |
|------|-------------|
| `cust_az12.csv` | Customer demographics — birth date, gender |
| `loc_a101.csv` | Customer geography — country mapping via customer ID |
| `px_cst_g1v2.csv` | Product classification — category, subcategory, maintenance indicator, product line |

---

## 📊 Data Layers

### 🟤 Bronze Layer — Raw Ingestion

| Property | Detail |
|----------|--------|
| **Definition** | Raw, unprocessed data — as-is from source systems |
| **Objective** | Traceability & Debugging |
| **Object Type** | Tables |
| **Load Method** | Full Load (Truncate & Insert) |
| **Transformations** | None (as-is) |
| **Data Modeling** | None (as-is) |
| **Target Audience** | Data Engineers |

The Bronze layer preserves the exact source data to enable full auditability and root-cause analysis for any downstream data issues.

---

### ⚪ Silver Layer — Cleansed & Standardized

| Property | Detail |
|----------|--------|
| **Definition** | Cleaned & standardized data |
| **Objective** | Intermediate layer — prepare data for analysis |
| **Object Type** | Tables |
| **Load Method** | Full Load (Truncate & Insert) |
| **Target Audience** | Data Analysts, Data Engineers |

**Transformations applied:**
- Data Cleansing
- Data Standardization
- Data Normalization
- Derived Columns
- Data Enrichment

**Key business rules:**
- Deduplicate customers
- Standardize product IDs and names
- Conform customer IDs across ERP and CRM
- Map country codes
- Enrich products with classification attributes
- Validate date and gender values
- Cleanse sales transactions

---

### 🟡 Gold Layer — Business-Ready

| Property | Detail |
|----------|--------|
| **Definition** | Business-Ready data |
| **Objective** | Provide data for reporting & analytics consumption |
| **Object Type** | Views |
| **Load Method** | None (derived from Silver) |
| **Target Audience** | Data Analysts, Business Users |

**Transformations applied:**
- Data Integration (joining across domains)
- Data Aggregation
- Business Logic & Rules

**Data Modeling patterns:**
- Star Schema
- Aggregated Objects
- Flat Tables

---

## 🔀 Data Flow & Lineage

![Alt text](/home/ritik/data-ecosystem-platform/Data Warehouse/BusinessDW/Docs/data_architecture.png)

Each Bronze table maps 1:1 to a Silver table. Silver tables are then integrated and aggregated into Gold views using business logic and dimensional modeling.

---

## ⚙️ ETL Workflow

<embed src="path/to/document.pdf" width="800" height="600" type="application/pdf">

Each layer follows a consistent 4-phase development workflow:

### 🟤 Bronze Layer
```
Analyse               Code                  Validate               Document
─────────────────    ─────────────────    ──────────────────    ──────────────────
Interview source  ──▶ Data Ingestion    ──▶ Completeness &    ──▶ Documenting
system experts        (Stored Proc)          Schema Checks          Versioning in GIT
```

### ⚪ Silver Layer
```
Analyse               Code                  Validate               Document
─────────────────    ─────────────────    ──────────────────    ──────────────────
Explore &         ──▶ Data Cleansing    ──▶ Data Correctness  ──▶ Documenting
Understand Data       (Stored Proc)          Checks                 Versioning in GIT
                                                                     + Data Flow
                                                                     + Data Integration
```

### 🟡 Gold Layer
```
Analyse               Code                  Validate               Document
─────────────────    ─────────────────    ──────────────────    ──────────────────
Explore &         ──▶ Data             ──▶ Data Integration  ──▶ Documenting
Understand            Integration           Checks                 Versioning in GIT
Business Objects      (Stored Proc)                                + Data Model
                                                                     + Data Catalog
                                                                     + Data Flow
```

---

## 🥇 Gold Layer Outputs

The following analytics-ready objects are produced in the Gold layer:

| Object | Type | Description |
|--------|------|-------------|
| `dim_customers` | View | Unified customer dimension — integrates CRM + ERP demographics and geography |
| `dim_products` | View | Enriched product dimension — integrates product details with classification data |
| `dim_location` | View | Geographic dimension for location-based analytics |
| `fact_sales` | View | Central sales fact table — transactional order records |

These objects form a **Star Schema** optimized for BI tools, ad-hoc SQL queries, and machine learning pipelines.

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Database** | SQL Server |
| **ETL / Transformation** | T-SQL Stored Procedures |
| **Load Strategy** | Batch Processing — Full Load (Truncate & Insert) |
| **Source Interface** | CSV files (folder-based ingestion) |
| **Version Control** | Git |
| **Consumers** | BI & Reporting, Ad-Hoc SQL, Machine Learning |

---

## 👤 Author

**Ritik**
Aspiring Data Engineer | Focused on building production-grade data systems

---

## ⭐ Conclusion

This project is a complete **end-to-end Business Data Warehouse** implementation — from raw data ingestion to business-ready analytical datasets. It demonstrates real-world data engineering practices including multi-source integration, layered ETL design, data quality management, and dimensional modeling using industry-standard Medallion Architecture principles.

---

*Built with SQL Server · Medallion Architecture · CRM & ERP Integration*