--############################################################################################
--############################ ERP_PX_CAT_G1V2 DATA TRANSFORMATION ###########################
--############################################################################################

--============================================================================================
--========================= product category table data profiling ============================
--============================================================================================
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM Bronze.erp_px_cat_g1v2 ; 

--============================================================================================
--======================================= id data cleaning ===================================
--============================================================================================
-- check id where id is not int 
SELECT 
    id
FROM Bronze.erp_px_cat_g1v2
WHERE TRY_CONVERT(INT, id) IS NOT NULL ;

-- id data profiling 
SELECT 
      id
FROM  Bronze.erp_px_cat_g1v2
WHERE id IS NULL 
   OR LEN(id) != 5;

-- id duplicate check 
SELECT
    id,
COUNT(*) as id_count
FROM Bronze.erp_px_cat_g1v2
    GROUP BY id 
    ORDER BY id_count DESC ; 

-- duplicate check in id 
SELECT 
    id
FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY id ORDER BY id DESC) as flag,
        *
    FROM Bronze.erp_px_cat_g1v2 
    WHERE id IS NOT NULL 
)t WHERE flag = 1 ;

--============================================================================================
--========================================== cat  cleaning ===================================
--============================================================================================

-- cat data profiling 
SELECT 
    cat
FROM Bronze.erp_px_cat_g1v2
WHERE cat  IS NULL 
    OR cat != TRIM(cat)
    OR TRIM(id) = '';

-- cat analysis 
SELECT
    cat,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.erp_px_cat_g1v2
    GROUP BY cat
    ORDER BY status_count DESC; 

-- cat cleaning and standardization 
WITH cat_analysis AS 
(
    SELECT 
        CASE
            WHEN TRIM(cat) IS NULL OR TRIM(cat) = '' THEN 'Unknown'
             ELSE TRIM(cat)
        END AS cat
    FROM Bronze.erp_px_cat_g1v2
)
SELECT
    cat,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM cat_analysis
    GROUP BY cat
    ORDER BY status_count DESC ; 

--============================================================================================
--======================================= subcat  cleaning ===================================
--============================================================================================

-- subcat data profiling 
SELECT 
    subcat
FROM Bronze.erp_px_cat_g1v2
WHERE subcat  IS NULL 
    OR subcat != TRIM(subcat)
    OR TRIM(id) = '';

-- subcat analysis 
SELECT
    subcat,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.erp_px_cat_g1v2
    GROUP BY subcat
    ORDER BY status_count DESC; 

-- subcat cleaning and standardization 
WITH subcat_analysis AS 
(
    SELECT 
        CASE
            WHEN TRIM(subcat) IS NULL OR TRIM(subcat) = '' THEN 'Unknown'
             ELSE TRIM(subcat)
        END AS subcat
    FROM Bronze.erp_px_cat_g1v2
)
SELECT
    subcat,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM subcat_analysis
    GROUP BY subcat
    ORDER BY status_count DESC ; 

--============================================================================================
--======================================= maintenance  cleaning ==============================
--============================================================================================

-- maintenance data profiling 
SELECT 
    REPLACE(REPLACE(TRIM(LOWER(maintenance)),CHAR(13), ''), CHAR(10), '') as maintenance
FROM Bronze.erp_px_cat_g1v2
WHERE maintenance  IS NULL 
    OR maintenance != TRIM(maintenance)
    OR TRIM(id) = '';

-- maintenance analysis 
SELECT
    REPLACE(REPLACE(TRIM(LOWER(maintenance)), CHAR(10), ''), CHAR(13), '') as maintenance,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM Bronze.erp_px_cat_g1v2
    GROUP BY REPLACE(REPLACE(TRIM(LOWER(maintenance)), CHAR(10), ''), CHAR(13), '')
    ORDER BY status_count DESC; 

-- maintenance cleaning and standardization 
WITH maintenance_analysis AS 
(
    SELECT 
        CASE
            WHEN maintenance IS NULL OR TRIM(maintenance) = '' THEN 'Unknown'
            WHEN REPLACE(REPLACE(TRIM(LOWER(maintenance)),CHAR(13), ''), CHAR(10), '') IN ('1','y', 'yes', 'true') THEN 'Yes'
            WHEN REPLACE(REPLACE(TRIM(LOWER(maintenance)),CHAR(13), ''), CHAR(10), '') IN ('0','n', 'no', 'false') THEN 'No'
            ELSE 'Unknown'
        END AS maintenance
    FROM Bronze.erp_px_cat_g1v2
)
SELECT
    maintenance,
    COUNT(*) as status_count,
    CAST(ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2)as nvarchar) AS percentages
FROM maintenance_analysis
    GROUP BY maintenance
    ORDER BY status_count DESC ; 

--############################################################################################
--############################### ERP_PX_CAT_G1V2 TRANSFRM DATA ##############################
--############################################################################################
INSERT INTO 
Silver.erp_px_cat_g1v2 
(
    id,
    cat,
    subcat,
    maintenance
 )
SELECT 
    id,
    CASE
        WHEN TRIM(cat) IS NULL OR TRIM(cat) = '' THEN 'Unknown'
         ELSE TRIM(cat)
    END AS cat,

    CASE
        WHEN TRIM(subcat) IS NULL OR TRIM(subcat) = '' THEN 'Unknown'
         ELSE TRIM(subcat)
    END AS subcat,

    CASE
        WHEN maintenance IS NULL OR TRIM(maintenance) = '' THEN 'Unknown'
        WHEN REPLACE(REPLACE(TRIM(LOWER(maintenance)),CHAR(13), ''), CHAR(10), '') IN ('1','y', 'yes', 'true') THEN 'Yes'
        WHEN REPLACE(REPLACE(TRIM(LOWER(maintenance)),CHAR(13), ''), CHAR(10), '') IN ('0','n', 'no', 'false') THEN 'No'
        ELSE 'Unknown'
    END AS maintenance
FROM 
(
    SELECT 
        ROW_NUMBER() OVER(PARTITION BY id ORDER BY id DESC) as flag,
        *
    FROM Bronze.erp_px_cat_g1v2 
    WHERE id IS NOT NULL 
)t WHERE flag = 1 ;
