--############################################################################################
--########################### CRM_CUST_INFO DATA TRANSFORMATION ##############################
--############################################################################################

--============================================================================================
--========================= customers table data profiling ===================================
--============================================================================================
SELECT TOP 1000
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM Bronze.crm_cust_info ; 

--============================================================================================
--=================================== cst_id data cleaning ===================================
--============================================================================================
-- check cst_id where cst id is not int 
SELECT 
    cst_id 
FROM Bronze.crm_cust_info 
WHERE TRY_CONVERT(INT, cst_id) IS NULL ;

-- cst_id data profiling 
SELECT 
      cst_id 
FROM  Bronze.crm_cust_info 
WHERE cst_id IS NULL 
   OR cst_id < 0
   OR LEN(cst_id) != 5;

-- cst_id duplicate check 
SELECT
    cst_id,
COUNT(*) as id_count
FROM Bronze.crm_cust_info 
    GROUP BY cst_id 
    ORDER BY id_count DESC ;

-- duplicate check in customerid 
SELECT 
*
FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag,
        *
    FROM Bronze.crm_cust_info
    WHERE cst_id IS NOT NULL 
)t WHERE flag = 1 ;

--============================================================================================
--=================================== cst_key data cleaning ===================================
--============================================================================================
-- customers cst_key data profiling 
SELECT 
      cst_key 
FROM  Bronze.crm_cust_info 
WHERE cst_key IS NULL 
   OR cst_key != TRIM(cst_key)
   OR LEN(cst_key) != 10
   OR TRIM(cst_key) = ''; 

-- cst_key cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_key IS NULL OR TRIM(cst_key) = '' OR LEN(cst_key) != 10 THEN 'Unknown'
        ELSE TRIM(cst_key)
    END as cst_key
FROM Bronze.crm_cust_info ; 
--============================================================================================
--=================================== cst_firstname data cleaning ============================
--============================================================================================
-- customers firstname data profiling 
SELECT 
      cst_firstname 
FROM  Bronze.crm_cust_info 
WHERE cst_firstname IS NULL 
   OR cst_firstname != TRIM(cst_firstname)
   OR LEN(cst_firstname) < 2
   OR TRIM(cst_firstname) = ''; 

-- cst_firstname cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_firstname IS NULL OR TRIM(cst_firstname) = '' OR LEN(cst_firstname) < 2 THEN 'Unknown'
        ELSE TRIM(cst_firstname)
    END as cst_firstname
FROM Bronze.crm_cust_info ; 

--============================================================================================
--=================================== cst_lastname data cleaning =============================
--============================================================================================
-- cst_lastname data profiling 
SELECT 
    cst_lastname 
FROM Bronze.crm_cust_info 
WHERE cst_lastname IS NULL 
   OR cst_lastname != TRIM(cst_lastname)
   OR LEN(cst_lastname) < 2
   OR TRIM(cst_lastname) = ''; 

-- cst_lastname cleaning and standardazition 
SELECT 
    CASE 
        WHEN cst_lastname IS NULL OR TRIM(cst_lastname) = '' OR LEN(cst_lastname) < 2 THEN 'Unknown'
        ELSE TRIM(cst_lastname)
    END as cst_lastname
FROM Bronze.crm_cust_info ; 
--============================================================================================
--========================= cst_marital_status data cleaning =================================
--============================================================================================
-- cst_marital_status data profiling 
SELECT 
    cst_marital_status 
FROM Bronze.crm_cust_info 
WHERE cst_marital_status  IS NULL 
    OR cst_marital_status != TRIM(cst_marital_status)
    OR TRIM(cst_marital_status) = '';

-- cst_marital_status analysis 
SELECT
    cst_marital_status ,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.crm_cust_info 
    GROUP BY cst_marital_status 
    ORDER BY status_count ; 

-- cst_marital_status cleaning and standardazition 
SELECT 
    CASE 
        WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
        WHEN TRIM(cst_marital_status) = 'M' THEN 'Married'
        WHEN cst_marital_status IS NULL OR TRIM(cst_marital_status) = '' THEN 'Unknown'
        ELSE 'Other'
    END AS cst_marital_status
FROM Bronze.crm_cust_info ;

--============================================================================================
--=================================== cst_gndr data cleaning =================================
--============================================================================================
-- cst_gndr data profiling 
SELECT 
    cst_gndr
FROM Bronze.crm_cust_info 
WHERE cst_gndr  IS NULL 
    OR cst_gndr != TRIM(cst_gndr)
    OR TRIM(cst_gndr) = '';

-- cst_gndr analysis 
SELECT
    cst_gndr ,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.crm_cust_info 
    GROUP BY cst_gndr 
    ORDER BY status_count ; 

-- cst_gndr cleaning and standardazition 
SELECT 
    CASE 
        WHEN TRIM(cst_gndr) = 'M' THEN 'Male'
        WHEN TRIM(cst_gndr) = 'F' THEN 'Female'
        WHEN TRIM(cst_gndr) = '' THEN 'Unknown'
        ELSE cst_gndr
    END AS cst_gndr
FROM Bronze.crm_cust_info ;
--============================================================================================
--=================================== cst_create_date data cleaning ==========================
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
--############################################################################################
--################################# CRM_CUST_INFO TRANSFRM DATA ##############################
--############################################################################################

SELECT 
    cst_id,

    CASE 
        WHEN cst_key IS NULL OR TRIM(cst_key) = '' OR LEN(cst_key) != 10 THEN 'Unknown'
        ELSE TRIM(cst_key)
    END as cst_key,

    CASE 
        WHEN cst_firstname IS NULL OR TRIM(cst_firstname) = '' OR LEN(cst_firstname) < 2 THEN 'Unknown'
        ELSE TRIM(cst_firstname)
    END as cst_firstname,

    CASE 
        WHEN cst_lastname IS NULL OR TRIM(cst_lastname) = '' OR LEN(cst_lastname) < 2 THEN 'Unknown'
        ELSE TRIM(cst_lastname)
    END as cst_lastname,

    CASE 
        WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
        WHEN TRIM(cst_marital_status) = 'M' THEN 'Married'
        WHEN cst_marital_status IS NULL OR TRIM(cst_marital_status) = '' THEN 'Unknown'
        ELSE 'Other'
    END AS cst_marital_status,
    
    CASE 
        WHEN TRIM(cst_gndr) = 'M' THEN 'Male'
        WHEN TRIM(cst_gndr) = 'F' THEN 'Female'
        WHEN TRIM(cst_gndr) = '' THEN 'Unknown'
        ELSE cst_gndr
    END AS cst_gndr,

    CASE 
        WHEN cst_create_date IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, cst_create_date) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, cst_create_date)
    END AS cst_create_date
    
FROM 
(
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag
    FROM Bronze.crm_cust_info
    WHERE cst_id IS NOT NULL 
)t WHERE flag = 1 ;

