--#################################################################################
--#################CUSTOMER INFORMATION DATA PROFILING SCRIPT######################
--#################################################################################
-- DATA EXPLORING 
SELECT TOP (1000) [cst_id]
      ,[cst_key]
      ,[cst_firstname]
      ,[cst_lastname]
      ,[cst_marital_status]
      ,[cst_gndr]
      ,[cst_create_date]
  FROM [BusinessDW].[Bronze].[crm_cust_info]

--===============================================================================
--======================= NULL and duplicate finding ============================
--===============================================================================
SELECT 
    cst_id,
    COUNT(*) as customer_count
FROM Bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL ;

--===============================================================================
--============================ check fresh info  ================================
--===============================================================================
SELECT 
    *
FROM Bronze.crm_cust_info
WHERE cst_id = 29466 ;

--===============================================================================
--============================ check fresh info  ================================
--===============================================================================
SELECT 
    *
FROM
(
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS last_flag 
    FROM Bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)t WHERE last_flag = 1 

--===============================================================================
--========================= cleaning space first name  ==========================
--===============================================================================
SELECT 
    cst_firstname,
    TRIM(cst_firstname) AS FirstName
FROM Bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

