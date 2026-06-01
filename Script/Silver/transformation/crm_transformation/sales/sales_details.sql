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

-- duplicate check in sales_ord_num
SELECT 
    sls_ord_num ,
    COUNT(*) as oid_count,
    CAST(ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2)as NVARCHAR) as percentages 
FROM Bronze.crm_sales_details
    GROUP BY sls_ord_num
    ORDER BY oid_count DESC ;

--============================================================================================
--================================ sls_prd_key column data profiling =========================
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
FROM Bronze.crm_sales_details 
WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info );

--============================================================================================
--================================= sls_cust_id column data profiling =========================
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
FROM Bronze.crm_sales_details 
WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info);
--============================================================================================
--=============================== sls_order_dt column data profiling =========================
--============================================================================================
-- sls_order_dt data profiling 
SELECT
    sls_order_dt 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT , sls_order_dt ) IS NULL 
   OR LEN(sls_order_dt) != 8 
   OR sls_order_dt < 0 ; 

SELECT 
TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR), 112) AS sls_order_dt
FROM Bronze.crm_sales_details ;
--============================================================================================
--================================ sls_ship_dt column data profiling =========================
--============================================================================================
-- sls_ship_dt data profiling 
SELECT
    sls_order_dt 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT , sls_order_dt ) IS NULL 
   OR LEN(sls_order_dt) != 8 
   OR sls_order_dt < 0 ; 

--============================================================================================
--================================= sls_due_dt column data profiling =========================
--============================================================================================


--============================================================================================
--================================ sls_sales column data profiling ===========================
--============================================================================================
-- sls_sales data type check 
SELECT 
    sls_sales 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(DECIMAL, sls_quantity) IS NULL ;

-- sls_sales data profiling 
SELECT 
    sls_sales 
FROM Bronze.crm_sales_details
WHERE sls_sales IS NULL 
OR sls_sales < 0  ;

-- sales order analysis 
SELECT 
    sls_sales ,
    COUNT(*) as count_sls,
    CAST(ROUND(COUNT(*) * 100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar)  + '%' AS percentages 
FROM Bronze.crm_sales_details 
GROUP BY sls_sales 
ORDER BY count_sls DESC ; 

--============================================================================================
--================================ sls_quantity column data profiling ========================
--============================================================================================
-- sls_quantity data type check 
SELECT 
    sls_quantity 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT, sls_quantity) IS NULL ;

-- sls_quantity data profiling 
SELECT 
    sls_quantity 
FROM Bronze.crm_sales_details
WHERE sls_quantity IS NULL 
OR sls_quantity < 0  ;

-- qunatity order analysis 
SELECT 
    sls_quantity ,
    COUNT(*) as count_qt,
    CAST(ROUND(COUNT(*) * 100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar)  + '%' AS percentages 
FROM Bronze.crm_sales_details 
GROUP BY sls_quantity 
ORDER BY count_qt DESC ; 

--============================================================================================
--================================ sls_price column data profiling ===========================
--============================================================================================
-- sls_quantity data type check 
SELECT 
    sls_quantity 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT, sls_quantity) IS NULL ;

-- sls_quantity data profiling 
SELECT 
    sls_quantity 
FROM Bronze.crm_sales_details
WHERE sls_quantity IS NULL 
OR sls_quantity < 0  ;

-- qunatity order analysis 
SELECT 
    sls_quantity ,
    COUNT(*) as count_qt,
    CAST(ROUND(COUNT(*) * 100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar)  + '%' AS percentages 
FROM Bronze.crm_sales_details 
GROUP BY sls_quantity 
ORDER BY count_qt DESC ; 

--############################################################################################
--########################### CRM_SALES_DETAILS DATA TRANSFORMATION ##########################
--############################################################################################

SELECT TOP 100
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