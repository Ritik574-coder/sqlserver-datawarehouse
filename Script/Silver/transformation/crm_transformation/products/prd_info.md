# CRM Product Information Transformation

## Transformation Overview
This script transforms raw product data from the Bronze layer (`Bronze.crm_prd_info`) into a cleaned and standardized format in the Silver layer (`Silver.crm_prd_info`).

- **Source Table:** `Bronze.crm_prd_info`
- **Target Table:** `Silver.crm_prd_info`
- **Primary Key:** `prd_id`

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **prd_id** | Kept as is from source. |
| **cat_id** | Derived from the first 5 characters of `prd_key`, with '-' replaced by '_'. |
| **prd_key** | Extracted from source `prd_key` starting from character 7. Trimmed and converted to uppercase. If null, set to 'Unknown'. |
| **prd_nm** | Trimmed. If null, empty, or length is less than 2, it is set to 'Unknown'. |
| **prd_cost** | If null, set to 0. If negative, converted to absolute value. |
| **prd_line** | Standardized: 'R' -> 'Road', 'M' -> 'Mountain', 'S' -> 'Sport', 'T' -> 'Touring'. Others -> 'Unknown'. |
| **prd_start_dt** | Converted to `DATE` using `TRY_CONVERT`. |
| **prd_end_dt** | Calculated using `LEAD()` function to determine the day before the next product version starts. If no next version, set to `NULL`. |

## Key Logic
- **Category Extraction:** Uses `SUBSTRING` on `prd_key` to identify the category.
- **SCD Type 2 Support:** The `prd_end_dt` calculation using `LEAD()` allows for historical tracking of product changes by defining validity periods for each record.
