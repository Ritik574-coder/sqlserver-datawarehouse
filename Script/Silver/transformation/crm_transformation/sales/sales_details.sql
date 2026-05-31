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


--============================================================================================
--================================= sls_cust_id column data profiling =========================
--============================================================================================


--============================================================================================
--=============================== sls_order_dt column data profiling =========================
--============================================================================================
-- cst_create_date data profiling 
SELECT 
    cst_create_date
FROM Bronze.crm_cust_info 
WHERE cst_create_date  IS NULL 
OR TRY_CONVERT(DATE, cst_create_date)IS NULL ;

-- cst_create_date pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(cst_create_date)),
        '0123456789abcdefghijklmnopqrstuvwxyz',
        '9999999999aaaaaaaaaaaaaaaaaaaaaaaaaa'
    ) as pattern
FROM Bronze.crm_cust_info 
)
SELECT 
    pattern,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM pattern_analysis
    GROUP BY pattern 
    ORDER BY status_count ; 

-- cst_create_date cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_create_date IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, cst_create_date) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, cst_create_date)
    END AS cst_create_date
FROM Bronze.crm_cust_info ;

--============================================================================================
--================================ sls_ship_dt column data profiling =========================
--============================================================================================
-- sls_ship_dt data profiling 
SELECT 
    sls_ship_dt
FROM Bronze.crm_sales_details
WHERE sls_ship_dt  IS NULL 
OR TRY_CONVERT(INT, sls_ship_dt)IS NULL ;


SELECT 
CAST(sls_ship_dt as date) AS DATE 
FROM Bronze.crm_sales_details ;

-- sls_ship_dt pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(sls_ship_dt)),
        '0123456789',
        '9999999999'
    ) as pattern
FROM Bronze.crm_sales_details 
)
SELECT 
    pattern,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM pattern_analysis
    GROUP BY pattern 
    ORDER BY status_count ; 

-- cst_create_date cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_create_date IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, cst_create_date) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, cst_create_date)
    END AS cst_create_date
FROM Bronze.crm_cust_info ;

--============================================================================================
--================================= sls_due_dt column data profiling =========================
--============================================================================================
-- cst_create_date data profiling 
SELECT 
    cst_create_date
FROM Bronze.crm_cust_info 
WHERE cst_create_date  IS NULL 
OR TRY_CONVERT(DATE, cst_create_date)IS NULL ;

-- cst_create_date pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(cst_create_date)),
        '0123456789abcdefghijklmnopqrstuvwxyz',
        '9999999999aaaaaaaaaaaaaaaaaaaaaaaaaa'
    ) as pattern
FROM Bronze.crm_cust_info 
)
SELECT 
    pattern,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM pattern_analysis
    GROUP BY pattern 
    ORDER BY status_count ; 

-- cst_create_date cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_create_date IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, cst_create_date) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, cst_create_date)
    END AS cst_create_date
FROM Bronze.crm_cust_info ;

--============================================================================================
--================================ sls_sales column data profiling ===========================
--============================================================================================


--============================================================================================
--================================ sls_quantity column data profiling ========================
--============================================================================================


--============================================================================================
--================================ sls_price column data profiling ===========================
--============================================================================================



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