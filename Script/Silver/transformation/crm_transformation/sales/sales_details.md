# CRM Sales Details Transformation

## Transformation Overview
This script transforms raw sales transaction data from the Bronze layer (`Bronze.crm_sales_details`) into a cleaned and standardized format in the Silver layer (`Silver.crm_sales_details`).

- **Source Table:** `Bronze.crm_sales_details`
- **Target Table:** `Silver.crm_sales_details`
- **Primary Key:** N/A (Composite of `sls_ord_num` and `sls_prd_key`)

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **sls_ord_num** | Kept as is. |
| **sls_prd_key** | Kept as is. |
| **sls_cust_id** | Kept as is. |
| **sls_order_dt** | Converted from `YYYYMMDD` integer format to `DATE`. Invalid dates (outside 1900-2050) are set to `NULL`. |
| **sls_ship_dt** | Converted from `YYYYMMDD` integer format to `DATE`. Invalid dates are set to `NULL`. |
| **sls_due_dt** | Converted from `YYYYMMDD` integer format to `DATE`. Invalid dates are set to `NULL`. |
| **sls_quantity** | If null or less than or equal to 0, it is set to `NULL`. |
| **sls_price** | If null or less than or equal to 0, it is calculated as `ABS(sls_sales) / ABS(sls_quantity)`. Otherwise, the absolute value of `sls_price` is used. |
| **sls_sales** | If null, less than or equal to 0, or does not match `quantity * price`, it is recalculated as `sls_quantity * ABS(sls_price)`. |

## Key Logic
- **Date Conversion:** Uses `TRY_CONVERT(DATE, CAST(date_col AS NVARCHAR), 112)` to handle integer-based dates.
- **Data Integrity:** The script includes logic to ensure that sales, quantity, and price are mathematically consistent.
