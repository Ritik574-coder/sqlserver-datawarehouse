/*=====================================================================================
View Name: Gold.dim_products

Description:
This dimension view contains product-related master data including product
category, subcategory, product line, maintenance information, and product cost.
It provides standardized and business-friendly product attributes for reporting,
analytics, and dimensional modeling purposes.
=====================================================================================*/

CREATE VIEW Gold.dim_products AS 
SELECT
    cp.prd_id           AS product_id,
    cp.cat_id           AS category_id,
    cp.prd_key          AS product_key,
    ep.cat              AS category,
    ep.subcat           AS subcategory,
    cp.prd_line         AS product_line,
    cp.prd_nm           AS product_name,
    ep.maintenance      AS maintenance,
    cp.prd_cost         AS product_cost,
    cp.prd_start_dt     AS product_start_date,
    cp.prd_end_dt       AS product_end_date
FROM Silver.crm_prd_info cp
LEFT JOIN Silver.erp_px_cat_g1v2 ep
    ON cp.cat_id = ep.id;
