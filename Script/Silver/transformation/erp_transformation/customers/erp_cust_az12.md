# ERP Customer Information Transformation

## Transformation Overview
This script transforms raw customer data from the ERP system (`Bronze.erp_cust_az12`) into a cleaned and standardized format in the Silver layer (`Silver.erp_cust_az12`).

- **Source Table:** `Bronze.erp_cust_az12`
- **Target Table:** `Silver.erp_cust_az12`
- **Primary Key:** `cid`

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **cust_key** | Kept as the original `cid` from source. |
| **cid** | If `cid` contains 'NASA', the 'NAS' prefix is removed (starts from 4th character). Otherwise, it is trimmed and converted to uppercase. |
| **bdate** | Converted to `DATE` using `TRY_CONVERT`. Invalid dates are set to `NULL`. |
| **gen** | Standardized after removing carriage returns and line feeds: 'm', 'male' -> 'Male'; 'f', 'female' -> 'Female'. Empty or others -> 'Unknown'. |

## Key Logic
- **NASA Prefix Handling:** Specific logic to handle legacy or system-specific prefixes in the customer ID.
- **Gender Normalization:** Robust cleaning of the gender field to handle multiple input formats and hidden characters (CR/LF).
- **Deduplication:** Uses `ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC)` to handle any duplicates in the source data.
