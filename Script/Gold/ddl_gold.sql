/*=====================================================================================
View Name: Gold.dim_customers

Description:
This dimension view contains customer-related master data including customer
names, gender, marital status, birth date, country, and account creation date.
It provides cleansed and enriched customer attributes for customer analytics,
segmentation, and reporting purposes.
=====================================================================================*/

CREATE VIEW Gold.dim_customers AS 
SELECT
    ROW_NUMBER() OVER(ORDER BY cc.cst_id  ) customer_sk,
    cc.cst_id                 AS customer_id,
    cc.cst_key                AS customer_key,
    cc.cst_firstname          AS first_name,
    cc.cst_lastname           AS last_name,
    cl.cntry                  AS country,

    CASE
        WHEN cc.cst_gndr IS NULL THEN ci.gen
        ELSE cc.cst_gndr 
    END                       AS gender,

    cc.cst_marital_status     AS marital_status,
    ci.bdate                  AS birth_date,
    cc.cst_create_date        AS customer_create_date

FROM Silver.crm_cust_info cc

INNER JOIN Silver.erp_loc_a101 cl 
    ON cc.cst_key = cl.cid

INNER JOIN Silver.erp_cust_az12 ci 
    ON cc.cst_key = ci.cid
GO;

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
    ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_key) AS product_sk,
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
    ON cp.cat_id = ep.id
GO;

/*=====================================================================================
View Name: Gold.fact_sales

Description:
This fact view contains transactional sales data at the order-product level.
It stores core business measures such as sales amount, quantity sold,
and unit price along with associated order, shipping, and due dates.
=====================================================================================*/

CREATE VIEW Gold.fact_sales AS 
SELECT 
    ROW_NUMBER() OVER(ORDER BY sls_ord_num) sales_sk ,
    p.product_sk      AS product_sk,
    c.customer_sk      AS customer_sk,
    s.sls_ord_num      AS order_number,
    s.sls_order_dt     AS order_date,
    s.sls_ship_dt      AS shipping_date,
    s.sls_due_dt       AS due_date,
    s.sls_sales        AS sales_amount,
    s.sls_quantity     AS quantity_sold,
    s.sls_price        AS unit_price
FROM Silver.crm_sales_details as s
LEFT JOIN Gold.dim_customers as c 
ON c.customer_id = s.sls_cust_id 
LEFT JOIN Gold.dim_products as p 
ON s.sls_prd_key = p.product_key 
GO;

