--############################################################################################
--############################ ERP_LOC_A101 DATA TRANSFORMATION ##############################
--############################################################################################

--============================================================================================
--========================= customers table data profiling ===================================
--============================================================================================
SELECT
    cid,
    cntry
FROM Bronze.erp_loc_a101 ; 

--============================================================================================
--=================================== cst_id data cleaning ===================================
--============================================================================================
-- check cst_id where cst id is not int 
SELECT 
    cid
FROM Bronze.erp_loc_a101 
WHERE TRY_CONVERT(INT, cid) IS NOT NULL ;

-- cst_id data profiling 
SELECT 
      cid
FROM  Bronze.erp_loc_a101
WHERE cid IS NULL 
   OR LEN(cid) < 5;

-- cst_id duplicate check 
SELECT
    cid,
COUNT(*) as id_count
FROM Bronze.erp_loc_a101
    GROUP BY cid 
    ORDER BY id_count DESC ; 

-- duplicate check in customerid 
SELECT 
    CASE 
        WHEN cid LIKE '%-%' THEN REPLACE(cid, '-', '')
        ELSE TRIM(UPPER(cid))
    END as cid
FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC) as flag,
        *
    FROM Bronze.erp_loc_a101 
    WHERE cid IS NOT NULL 
)t WHERE flag = 1 ;

--============================================================================================
--======================================= country  cleaning ==================================
--============================================================================================

-- country data profiling 
SELECT 
    REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') as country
FROM Bronze.erp_loc_a101
WHERE cntry  IS NULL 
    OR cntry != TRIM(cntry)
    OR TRIM(cid) = '';

-- country analysis 
SELECT
    REPLACE(REPLACE(TRIM(LOWER(cntry)), CHAR(10), ''), CHAR(13), '') as country,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.erp_loc_a101
    GROUP BY REPLACE(REPLACE(TRIM(LOWER(cntry)), CHAR(10), ''), CHAR(13), '')
    ORDER BY status_count DESC; 

-- country cleaning and standardization 
WITH country_analysis AS 
(
    SELECT 
        CASE
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'Unknown'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('usa', 'us', 'united states') THEN 'United States'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('uk', 'united kingdom', 'england', 'great britain') THEN 'United Kingdom'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('de', 'germany')THEN 'Germany'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'france' THEN 'France'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'canada' THEN 'Canada'
            WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'australia' THEN 'Australia'
            ELSE 'Unknown'
        END AS cntry
    FROM Bronze.erp_loc_a101
)
SELECT
    cntry,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM country_analysis
    GROUP BY cntry
    ORDER BY status_count DESC ; 

--############################################################################################
--################################# ERP_CUST_AZ12 TRANSFRM DATA ##############################
--############################################################################################
INSERT INTO 
Silver.erp_loc_a101 
(
    cid,
    cntry
 )
SELECT 
    CASE 
        WHEN cid LIKE '%-%' THEN REPLACE(cid, '-', '')
        ELSE TRIM(UPPER(cid))
    END as cid,

    CASE
        WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('usa', 'us', 'united states') THEN 'United States'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('uk', 'united kingdom', 'england', 'great britain') THEN 'United Kingdom'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') IN ('de', 'germany')THEN 'Germany'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'france' THEN 'France'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'canada' THEN 'Canada'
        WHEN REPLACE(REPLACE(TRIM(LOWER(cntry)),CHAR(13), ''), CHAR(10), '') = 'australia' THEN 'Australia'
        ELSE 'Unknown'
    END AS cntry

FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY cid ORDER BY cid DESC) as flag,
        *
    FROM Bronze.erp_loc_a101 
    WHERE cid IS NOT NULL 
)t WHERE flag = 1 ;

SELECT * FROM Silver.erp_loc_a101 ;