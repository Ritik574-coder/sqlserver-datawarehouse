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