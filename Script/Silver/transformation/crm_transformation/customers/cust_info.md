# CRM Customer Information Transformation

## Transformation Overview
This script transforms raw customer data from the Bronze layer (`Bronze.crm_cust_info`) into a cleaned and standardized format in the Silver layer (`Silver.crm_cust_info`).

- **Source Table:** `Bronze.crm_cust_info`
- **Target Table:** `Silver.crm_cust_info`
- **Primary Key:** `cst_id`

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **cst_id** | Only the most recent record for each `cst_id` is kept (using `ROW_NUMBER()` ordered by `cst_create_date` descending). |
| **cst_key** | Trimmed. If null, empty, or length is not 10, it is set to 'Unknown'. |
| **cst_firstname** | Trimmed. If null, empty, or length is less than 2, it is set to 'Unknown'. |
| **cst_lastname** | Trimmed. If null, empty, or length is less than 2, it is set to 'Unknown'. |
| **cst_marital_status** | Standardized: 'S' -> 'Single', 'M' -> 'Married'. Null or empty -> 'Unknown'. Others -> 'Other'. |
| **cst_gndr** | Standardized: 'M' -> 'Male', 'F' -> 'Female'. Empty -> 'Unknown'. Others kept as is. |
| **cst_create_date** | Converted to `DATE` using `TRY_CONVERT`. Invalid dates are set to `NULL`. |

## Deduplication Logic
The transformation uses a Common Table Expression (CTE) or subquery with `ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC)` to ensure that only the latest information for each customer ID is loaded into the Silver layer.
