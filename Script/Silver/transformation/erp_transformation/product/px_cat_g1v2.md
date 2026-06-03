# ERP Product Category Transformation

## Transformation Overview
This script transforms raw product category data from the ERP system (`Bronze.erp_px_cat_g1v2`) into a cleaned and standardized format in the Silver layer (`Silver.erp_px_cat_g1v2`).

- **Source Table:** `Bronze.erp_px_cat_g1v2`
- **Target Table:** `Silver.erp_px_cat_g1v2`
- **Primary Key:** `id`

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **id** | Kept as is from source. |
| **cat** | Trimmed. If null or empty, it is set to 'Unknown'. |
| **subcat** | Trimmed. If null or empty, it is set to 'Unknown'. |
| **maintenance** | Standardized to 'Yes' or 'No'. Values like '1', 'y', 'yes', 'true' map to 'Yes'. Values like '0', 'n', 'no', 'false' map to 'No'. Others map to 'Unknown'. |

## Key Logic
- **Boolean Standardazation:** Converts various representations of boolean flags (numeric, single-character, and text) into a consistent 'Yes'/'No' format.
- **Categorical Cleaning:** Ensures that category and subcategory names are trimmed of whitespace and handle missing values gracefully.
- **Deduplication:** Uses `ROW_NUMBER() OVER(PARTITION BY id ORDER BY id DESC)` to ensure a unique set of categories in the Silver layer.
