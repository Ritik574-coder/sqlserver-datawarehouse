--############################################################################################
--########################### ERP_CUST_AZ12 DATA TRANSFORMATION ##############################
--############################################################################################

--============================================================================================
--========================= customers table data profiling ===================================
--============================================================================================
SELECT
    cid,
    bdate,
    gen
FROM Bronze.erp_cust_az12 ; 

--============================================================================================
--=================================== cst_id data cleaning ===================================
--============================================================================================
-- check cst_id where cst id is not int 
SELECT 
    cid
FROM Bronze.erp_cust_az12 
WHERE TRY_CONVERT(INT, cid) IS NULL ;

-- cst_id data profiling 
SELECT 
      cid
FROM  Bronze.erp_cust_az12
WHERE cid IS NULL 
   OR LEN(cid) < 5;

-- cst_id duplicate check 
SELECT
    cid,
COUNT(*) as id_count
FROM Bronze.erp_cust_az12 
    GROUP BY cid 
    ORDER BY id_count DESC ; 

-- duplicate check in customerid 
SELECT 
cid as cust_key,
CASE 
WHEN cid LIKE '%NASA%' THEN SUBSTRING(cid,4, LEN(cid))
ELSE TRIM(UPPER(cid))
END as cid
FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC) as flag,
        *
    FROM Bronze.erp_cust_az12 
    WHERE cid IS NOT NULL 
)t WHERE flag = 1 ;

--============================================================================================
--=================================== cst_key data cleaning ==================================
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
--====================================== csutomer Gender cleaning ============================
--============================================================================================
-- cst_gndr data profiling 
SELECT 
    REPLACE(REPLACE(TRIM(LOWER(gen)),CHAR(13), ''), CHAR(10), '')
FROM Bronze.erp_cust_az12
WHERE gen  IS NULL 
    OR gen != TRIM(gen)
    OR TRIM(gen) = '';

-- cst_gndr analysis 
SELECT
    REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') as Gender,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.erp_cust_az12
    GROUP BY REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '')
    ORDER BY status_count ; 

-- cst_gndr cleaning and standardazition 
WITH gender_analysis AS 
(
SELECT 
    CASE 
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = ''       THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') IS NULL    THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'm'      THEN 'Male'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'f'      THEN 'Female'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'male'   THEN 'Male'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'female' THEN 'Female'
        ELSE 'Unknown'
    END as gen
FROM Bronze.erp_cust_az12 
)
SELECT
    gen,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM gender_analysis
    GROUP BY gen
    ORDER BY status_count ; 

--============================================================================================
--====================================== csutomer Gender cleaning ============================
--============================================================================================
-- cst_create_date data profiling 
SELECT 
    bdate
FROM Bronze.erp_cust_az12 
WHERE bdate  IS NULL 
OR TRY_CONVERT(DATE, bdate)IS NULL ;

-- cst_create_date pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(bdate)),
        '0123456789abcdefghijklmnopqrstuvwxyz',
        '9999999999aaaaaaaaaaaaaaaaaaaaaaaaaa'
    ) as pattern
FROM Bronze.erp_cust_az12 
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
        WHEN bdate IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, bdate) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, bdate)
    END AS bdate
FROM Bronze.erp_cust_az12  ;
--############################################################################################
--################################# ERP_CUST_AZ12 TRANSFRM DATA ##############################
--############################################################################################
INSERT INTO Silver.erp_cust_az12
(
    cust_key,
    cid,
    bdate,
    gen
)
SELECT 
    cid as cust_key,

    CASE 
        WHEN cid LIKE '%NASA%' THEN SUBSTRING(cid,4, LEN(cid))
        ELSE TRIM(UPPER(cid))
    END as cid ,

    CASE 
        WHEN bdate IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, bdate) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, bdate)
    END AS bdate,

    CASE 
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = ''       THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') IS NULL    THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'm'      THEN 'Male'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'f'      THEN 'Female'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'male'   THEN 'Male'
        WHEN REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '') = 'female' THEN 'Female'
        ELSE 'Unknown'
    END as gen

FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC) as flag,
        *
    FROM Bronze.erp_cust_az12 
    WHERE cid IS NOT NULL 
)t WHERE flag = 1 ;
