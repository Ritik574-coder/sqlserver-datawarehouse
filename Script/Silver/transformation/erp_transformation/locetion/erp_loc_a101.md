# ERP Location Information Transformation

## Transformation Overview
This script transforms raw location data from the ERP system (`Bronze.erp_loc_a101`) into a cleaned and standardized format in the Silver layer (`Silver.erp_loc_a101`).

- **Source Table:** `Bronze.erp_loc_a101`
- **Target Table:** `Silver.erp_loc_a101`
- **Primary Key:** `cid`

## Data Cleaning & Transformation Rules

| Column | Transformation Logic |
| :--- | :--- |
| **cid** | If `cid` contains a hyphen '-', it is removed. Otherwise, it is trimmed and converted to uppercase. |
| **cntry** | Standardized to proper names: 'usa', 'us', 'united states' -> 'United States'; 'uk', 'united kingdom', 'england', 'great britain' -> 'United Kingdom'; 'de', 'germany' -> 'Germany'; 'france', 'canada', 'australia' kept as proper case. Null or others -> 'Unknown'. |

## Key Logic
- **ID Cleaning:** Normalizes location IDs by removing special characters like hyphens to ensure consistency for joining with other tables.
- **Geographical Standardization:** Maps various abbreviations and alternate names for countries to a single standard value.
- **Deduplication:** Uses `ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC)` to ensure only one record per unique `cid` is loaded.
