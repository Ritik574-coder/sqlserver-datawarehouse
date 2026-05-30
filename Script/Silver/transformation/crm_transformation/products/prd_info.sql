--############################################################################################
--########################### CRM_PRD_INFO DATA TRANSFORMATION ###############################
--############################################################################################

--============================================================================================
--=========================== product table data profiling ===================================
--============================================================================================

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info ; 

--============================================================================================
--================================== prd_id column data cleaning =============================
--============================================================================================
-- prd_id data overview 
SELECT 
    prd_id 
FROM Bronze.crm_prd_info ;

-- null check in prd_id
SELECT 
    prd_id 
FROM Bronze.crm_prd_info 
    WHERE prd_id IS NULL ;

-- prd_id data profiling 
SELECT 
      prd_id 
FROM  Bronze.crm_prd_info 
WHERE prd_id IS NULL 
   OR prd_id < 0
   OR TRY_CONVERT(INT, prd_id) IS NULL 
   OR LEN(prd_id) < 2;

-- duplicate check in prd_id 
SELECT 
    prd_id ,
    COUNT(*) as id_count
FROM Bronze.crm_prd_info 
    GROUP BY prd_id
    ORDER BY id_count DESC ;   

-- check prd_start_dt < prd_end_dt
SELECT 
    prd_start_dt,
    prd_end_dt 
FROM Bronze.crm_prd_info 
WHERE prd_start_dt < prd_end_dt ;

-- prd_id cleaning and standardazition 
SELECT 
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM 
(
    SELECT 
    SUBSTRING(prd_key,1, 5) as cat_id,
    *,
    ROW_NUMBER() OVER(PARTITION BY prd_id ORDER BY prd_end_dt DESC) as flag
    FROM Bronze.crm_prd_info
    WHERE prd_id IS NOT NULL 
)t ; 

--============================================================================================
--================================== prd_key column data cleaning ============================
--============================================================================================
-- prd_key data profiling 
SELECT 
      prd_key 
FROM  Bronze.crm_prd_info 
WHERE prd_key IS NULL 
   OR prd_key != TRIM(UPPER(prd_key))
   OR LEN(prd_key) < 10;

-- prd_id cleaning and standardazition 
SELECT 
    CASE 
        WHEN prd_key IS NULL OR LEN(prd_key) < 10 THEN 'Unknown'
        ELSE TRIM(UPPER(prd_key))
    END as prd_key
FROM Bronze.crm_prd_info ;

--============================================================================================
--================================== prd_nm column data cleaning =============================
--============================================================================================
-- prd_nm data profiling 
SELECT 
      prd_nm 
FROM  Bronze.crm_prd_info
WHERE prd_nm IS NULL 
   OR prd_nm != TRIM(prd_nm)
   OR LEN(prd_nm) < 2
   OR TRIM(prd_nm) = ''; 

-- prd_nm cleaning and standardazition 
SELECT 
    CASE 
        WHEN prd_nm IS NULL OR TRIM(prd_nm) = '' OR LEN(prd_nm) < 2 THEN 'Unknown'
        ELSE TRIM(prd_nm)
    END as prd_nm
FROM Bronze.crm_prd_info ; 

--============================================================================================
--================================= prd_cost column data cleaning ============================
--============================================================================================
-- prd_cost data profiling 
SELECT 
    prd_cost 
FROM Bronze.crm_prd_info 
WHERE prd_cost IS NULL 
OR prd_cost < 0 ; 

-- prd_cost cleaning and standardazition 
SELECT
    CASE
        WHEN prd_cost IS NULL THEN 0
        WHEN prd_cost < 0 THEN ABS(prd_cost)
        ELSE prd_cost
    END AS prd_cost
FROM Bronze.crm_prd_info ;

--============================================================================================
--================================ prd_line column data cleaning =============================
--============================================================================================
-- prd_line data profiling 
SELECT 
      prd_line
FROM  Bronze.crm_prd_info 
WHERE prd_line IS NULL 
   OR TRIM(UPPER(prd_line)) != prd_line
   OR TRIM(prd_line) = '';

--prd_line analysis 
SELECT 
    prd_line,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.crm_prd_info 
    GROUP BY prd_line 
    ORDER BY status_count DESC ;

--prd_line cleaning and standardazition
WITH analysis AS 
(
    SELECT 
        CASE 
            WHEN prd_line = 'R' THEN 'Road'
            WHEN prd_line = 'M' THEN 'Mountain'
            WHEN prd_line = 'S' THEN 'Sport'
            WHEN prd_line = 'T' THEN 'Touring'
            ELSE 'Unknown'
        END AS prd_line
    FROM Bronze.crm_prd_info 
)
SELECT 
    prd_line,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM analysis
    GROUP BY prd_line 
    ORDER BY status_count DESC ;

--============================================================================================
--================================ prd_start_dt column data cleaning =========================
--============================================================================================
-- prd_start_dt data profiling 
SELECT 
    prd_start_dt
FROM Bronze.crm_prd_info
WHERE prd_start_dt  IS NULL 
OR TRY_CONVERT(DATE, prd_start_dt)IS NULL ;

-- prd_start_dt pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(prd_start_dt)),
        '0123456789abcdefghijklmnopqrstuvwxyz',
        '9999999999aaaaaaaaaaaaaaaaaaaaaaaaaa'
    ) as pattern
FROM Bronze.crm_prd_info
)
SELECT 
    pattern,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM pattern_analysis
    GROUP BY pattern 
    ORDER BY status_count ; 

-- prd_start_dt cleaning and standardazition 
SELECT 
    CASE 
        WHEN prd_start_dt IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, prd_start_dt) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, prd_start_dt)
    END AS prd_start_dt
FROM Bronze.crm_prd_info ;

--============================================================================================
--================================ prd_end_dt column data cleaning ===========================
--============================================================================================
-- prd_end_dt data profiling 
SELECT 
    prd_end_dt
FROM Bronze.crm_prd_info
WHERE prd_end_dt  IS NULL 
OR TRY_CONVERT(DATE, prd_end_dt)IS NULL ;

-- prd_end_dt pattern analysis 
WITH pattern_analysis AS 
(
SELECT
    TRANSLATE(
        TRIM(LOWER(prd_end_dt)),
        '0123456789abcdefghijklmnopqrstuvwxyz',
        '9999999999aaaaaaaaaaaaaaaaaaaaaaaaaa'
    ) as pattern
FROM Bronze.crm_prd_info 
)
SELECT 
    pattern,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM pattern_analysis
    GROUP BY pattern 
    ORDER BY status_count ; 

-- prd_end_dt cleaning and standardazition 
SELECT 
    CASE 
        WHEN prd_end_dt IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, prd_end_dt) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, prd_end_dt)
    END AS prd_end_dt
FROM Bronze.crm_prd_info ;

--############################################################################################
--########################### CRM_PRD_INFO DATA TRANSFORMATION ###############################
--############################################################################################
WITH analysis AS 
(
SELECT 
    prd_id,
    CONCAT(SUBSTRING(prd_key,1, 2), '_',SUBSTRING(prd_key, 4,2)) as cat_id,

    CASE 
        WHEN prd_key IS NULL OR LEN(prd_key) < 10 THEN 'Unknown'
        ELSE SUBSTRING(TRIM(UPPER(prd_key)),7,LEN(TRIM(UPPER(prd_key))))
    END as prd_key,

    CASE 
        WHEN prd_nm IS NULL OR TRIM(prd_nm) = '' OR LEN(prd_nm) < 2 THEN 'Unknown'
        ELSE TRIM(prd_nm)
    END as prd_nm,

    CASE
        WHEN prd_cost IS NULL THEN 0
        WHEN prd_cost < 0 THEN ABS(prd_cost)
        ELSE prd_cost
    END AS prd_cost,

    CASE 
        WHEN prd_line = 'R' THEN 'Road'
        WHEN prd_line = 'M' THEN 'Mountain'
        WHEN prd_line = 'S' THEN 'Sport'
        WHEN prd_line = 'T' THEN 'Touring'
        ELSE 'Unknown'
    END AS prd_line,

    CASE 
        WHEN prd_start_dt IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, prd_start_dt) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, prd_start_dt)
    END AS prd_start_dt,

    CASE 
        WHEN prd_end_dt IS NULL THEN NULL 
        WHEN TRY_CONVERT(DATE, prd_end_dt) IS NULL THEN NULL 
        ELSE TRY_CONVERT(DATE, prd_end_dt)
    END AS prd_end_dt
FROM 
(
    SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY prd_id ORDER BY prd_end_dt DESC) as flag
    FROM Bronze.crm_prd_info
    WHERE prd_id IS NOT NULL 
)t WHERE flag = 1
)
SELECT 
    a.cat_id,
    a.prd_key,
    a.prd_id,
    s.sls_prd_key
FROM analysis as a 
INNER JOIN  Bronze.crm_sales_details as s 
ON s.sls_prd_key = a.prd_key ; 

SELECT * FROM Bronze.crm_prd_info ;

SELECT * FROM Bronze.crm_sales_details ;