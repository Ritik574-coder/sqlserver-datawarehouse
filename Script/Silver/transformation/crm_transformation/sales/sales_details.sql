--############################################################################################
--########################### CRM_SALES_DETAILS DATA TRANSFORMATION ##########################
--############################################################################################

--============================================================================================
--=========================== crm_sales_details table data profiling =========================
--============================================================================================
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM Bronze.crm_sales_details ;

--============================================================================================
--================================ sls_ord_num column data profiling =========================
--============================================================================================
-- sls_ord_num data prifiling 
SELECT 
      sls_ord_num 
FROM  Bronze.crm_sales_details 
WHERE sls_ord_num IS NULL 
   OR TRIM(UPPER(sls_ord_num)) != sls_ord_num
   OR LEN(sls_ord_num) != 7;


--############################################################################################
--########################### CRM_SALES_DETAILS DATA TRANSFORMATION ##########################
--############################################################################################

SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM
(
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY sls_ord_num ORDER BY sls_ord_num DESC) as flag
    FROM Bronze.crm_sales_details 
)t WHERE flag > 1 ;