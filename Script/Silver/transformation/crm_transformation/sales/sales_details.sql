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
WHERE TRY_CONVERT(INT , sls_order_dt) IS NULL 
   OR LEN(sls_order_dt) != 8 
   OR sls_order_dt < 0 
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101; 

-- sls_order_dt cleaning and standardazition 
WITH clean_ship AS 
(
    SELECT 
        CASE 
            WHEN LEN(sls_order_dt) != 8  OR sls_order_dt <= 0 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS NVARCHAR), 112)
        END as sls_order_dt
    FROM Bronze.crm_sales_details 
)
SELECT 
    sls_order_dt 
FROM clean_ship 
WHERE sls_order_dt IS NULL 
   OR sls_order_dt NOT LIKE '____-__-__';
--============================================================================================
--================================ sls_ship_dt column data profiling =========================
--============================================================================================
-- sls_ship_dt data profiling 
SELECT
    sls_ship_dt 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT , sls_ship_dt) IS NULL 
   OR LEN(sls_ship_dt) != 8 
   OR sls_ship_dt < 0 
   OR sls_ship_dt > 20500101
   OR sls_due_dt < 19000101; 

-- sls_ship_dt cleaning and standardazition 
WITH clean_ship AS 
(
    SELECT 
        CASE 
            WHEN LEN(sls_ship_dt) != 8  OR sls_ship_dt <= 0 OR sls_ship_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS NVARCHAR), 112)
        END as sls_ship_dt
    FROM Bronze.crm_sales_details 
)
SELECT 
    sls_ship_dt 
FROM clean_ship 
WHERE sls_ship_dt IS NULL 
   OR sls_ship_dt NOT LIKE '____-__-__';

--============================================================================================
--================================= sls_due_dt column data profiling =========================
--============================================================================================
-- sls_due_dt data profiling 
SELECT
    sls_due_dt 
FROM Bronze.crm_sales_details 
WHERE TRY_CONVERT(INT , sls_due_dt) IS NULL 
   OR LEN(sls_due_dt) != 8 
   OR sls_due_dt < 0 
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101; 

-- sls_due_dt cleaning and standardazition 
WITH clean_ship AS 
(
    SELECT 
        CASE 
            WHEN LEN(sls_due_dt) != 8  OR sls_due_dt <= 0 OR sls_due_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS NVARCHAR), 112)
        END as sls_due_dt
    FROM Bronze.crm_sales_details 
)
SELECT 
    sls_due_dt 
FROM clean_ship 
WHERE sls_due_dt IS NULL 
   OR sls_due_dt NOT LIKE '____-__-__';

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

-- sls_due_dt cleaning and standardazition 
SELECT 
sls_quantity * sls_price as sls_sales
FROM Bronze.crm_sales_details ; 
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

--============================================================================================
--=============================== fileal data validation and check ===========================
--============================================================================================ 
WITH sales_analysis AS 
(
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE 
            WHEN LEN(sls_order_dt) != 8  OR sls_order_dt <= 0 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS NVARCHAR), 112)
        END as sls_order_dt,

        CASE 
            WHEN LEN(sls_ship_dt) != 8  OR sls_ship_dt <= 0 OR sls_ship_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS NVARCHAR), 112)
        END as sls_ship_dt,

        CASE 
            WHEN LEN(sls_due_dt) != 8  OR sls_due_dt <= 0 OR sls_due_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
            ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS NVARCHAR), 112)
        END as sls_due_dt,

        CASE
            WHEN sls_quantity IS NULL OR sls_quantity <= 0
            THEN NULL
            ELSE sls_quantity
        END AS sls_quantity,

        CASE
            WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales) / ABS(sls_quantity) 
            ELSE ABS(sls_price)
        END AS sls_price,

        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales
    FROM Bronze.crm_sales_details 
)
SELECT 
*
FROM sales_analysis 
WHERE 
    -- invalid business date sequence
    sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt
    OR sls_ship_dt > sls_due_dt

    -- missing critical fields
    OR sls_ord_num IS NULL
    OR sls_prd_key IS NULL
    OR sls_cust_id IS NULL

    -- invalid sales metrics
    OR sls_sales IS NULL
    OR sls_sales <= 0

    OR sls_quantity IS NULL
    OR sls_quantity <= 0

    OR sls_price IS NULL
    OR sls_price <= 0

    -- future order date check
    OR sls_order_dt > GETDATE()

    -- unrealistic quantity
    OR sls_quantity > 100000

    -- unrealistic price
    OR sls_price > 1000000

    -- unrealistic sales
    OR sls_sales > 100000000

    -- duplicate order-product combination
    OR EXISTS
    (
        SELECT 1
        FROM Bronze.crm_sales_details t2
        WHERE sales_analysis.sls_ord_num = t2.sls_ord_num
          AND sales_analysis.sls_prd_key = t2.sls_prd_key
        GROUP BY t2.sls_ord_num, t2.sls_prd_key
        HAVING COUNT(*) > 1
    );


-- check the issue and debug it 
SELECT
    sls_sales,
    sls_quantity,
    sls_price,

    ABS(sls_sales / NULLIF(sls_price, 0)) AS calc_quantity,
    ABS(sls_sales / NULLIF(sls_quantity, 0)) AS calc_price

FROM Bronze.crm_sales_details
WHERE sls_ord_num IN ('SO61636', 'SO68889');

SELECT * from Bronze.crm_sales_details 
WHERE sls_quantity <= 0  ;
--############################################################################################
--########################### CRM_SALES_DETAILS DATA TRANSFORMATION ##########################
--############################################################################################
INSERT INTO Silver.crm_sales_details 
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_quantity,
    sls_price,
    sls_sales
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE 
        WHEN LEN(sls_order_dt) != 8  OR sls_order_dt <= 0 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101 THEN NULL 
        ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS NVARCHAR), 112)
    END as sls_order_dt,

    CASE 
        WHEN LEN(sls_ship_dt) != 8  OR sls_ship_dt <= 0 OR sls_ship_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
        ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS NVARCHAR), 112)
    END as sls_ship_dt,

    CASE 
        WHEN LEN(sls_due_dt) != 8  OR sls_due_dt <= 0 OR sls_due_dt > 20500101 OR sls_due_dt < 19000101 THEN NULL 
        ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS NVARCHAR), 112)
    END as sls_due_dt,

    CASE
        WHEN sls_quantity IS NULL OR sls_quantity <= 0
        THEN NULL
        ELSE sls_quantity
    END AS sls_quantity,

    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales) / ABS(sls_quantity) 
        ELSE ABS(sls_price)
    END AS sls_price,

    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales
FROM Bronze.crm_sales_details ;
