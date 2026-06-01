/*
===========================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)

Script Purpose:
This stored procedure loads cleansed and transformed data from the 'Bronze'
schema into the 'Silver' schema.

```
The procedure performs the following operations:
- Truncates existing data from Silver tables before loading.
- Applies data cleansing, standardization, and transformation rules.
- Handles invalid, missing, and inconsistent records.
- Performs data quality validations and business rule checks.
- Derives corrected values for sales, quantity, and price fields.
- Loads validated and transformed data into Silver tables.

The Silver layer represents a refined and standardized version of the raw
Bronze data, designed for downstream analytics, reporting, and business use.
```

Parameters:
None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC Silver.transform_silver;
==========================================================================================
*/


CREATE OR ALTER PROCEDURE Silver.transform_silver
AS
BEGIN
    SET NOCOUNT ON ;
    SET XACT_ABORT ON ;
    
    DECLARE
        @batch_start_time DATETIME ,
        @batch_end_time   DATETIME ,
        @start_time       DATETIME ,
        @end_time         DATETIME ;
    
    BEGIN TRY
        
        SET @batch_start_time = GETDATE() ;

        PRINT '=================================================' ;
        PRINT ' Silver Layer Data Transformation Started' ;
        PRINT '=================================================' ;

        BEGIN TRANSACTION ;

        PRINT '-------------------------------------------------' ;
        PRINT 'Data Transformation CRM tables' ;
        PRINT '-------------------------------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : Silver.crm_cust_info' ;
        TRUNCATE TABLE Silver.crm_cust_info  ;

        PRINT '>> Loading data into : Silver.crm_cust_info' ;
        INSERT INTO Silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
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

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '-----------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table Silver.crm_prd_info' ;
        TRUNCATE TABLE Silver.crm_prd_info ;

        PRINT '>> Inserting data into : Silver.crm_prd_info' ;
        INSERT INTO Silver.crm_prd_info 
        (
            prd_id,
            cat_id, 
            prd_key,
            prd_nm, 
            prd_cost,
            prd_line,
            prd_start_dt,          
            prd_end_dt 
        )
        SELECT 
            prd_id,

            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,

            CASE 
                WHEN prd_key IS NULL THEN 'Unknown'
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
                WHEN LEAD(TRY_CONVERT(DATE, prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) IS NULL THEN NULL
                ELSE DATEADD(DAY, -1, LEAD(TRY_CONVERT(DATE, prd_start_dt)) OVER(PARTITION BY prd_key ORDER BY TRY_CONVERT(DATE, prd_start_dt)))
            END AS prd_end_dt
        FROM Bronze.crm_prd_info ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND,@start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '-----------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : Silver.crm_sales_details' ;
        TRUNCATE TABLE Silver.crm_sales_details ;

        PRINT 'Inserting data into : Silver.crm_sales_details' ;
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

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        PRINT '-------------------------------------------------' ;
        PRINT 'Data Transformation ERP tables' ;
        PRINT '-------------------------------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : Silver.erp_cust_az12' ;
        TRUNCATE TABLE Silver.erp_cust_az12 ;

        PRINT 'Inserting data into : Silver.erp_cust_az12' ;
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

            CASE REPLACE(REPLACE(TRIM(LOWER(gen)), CHAR(10), ''), CHAR(13), '')
                WHEN  ''       THEN 'Unknown'
                WHEN  'm'      THEN 'Male'
                WHEN  'f'      THEN 'Female'
                WHEN 'male'    THEN 'Male'
                WHEN 'female'  THEN 'Female'
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

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : Silver.erp_loc_a101' ;
        TRUNCATE TABLE Silver.erp_loc_a101 ;

        PRINT 'Inserting data into : Silver.erp_loc_a101' ;
        INSERT INTO Silver.erp_loc_a101 
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

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;
        
        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : Silver.erp_px_cat_g1v2' ;
        TRUNCATE TABLE Silver.erp_px_cat_g1v2 ;

        PRINT 'Inserting data into : Silver.erp_px_cat_g1v2' ;
        INSERT INTO Silver.erp_px_cat_g1v2 
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

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        COMMIT ;

        SET @batch_end_time = GETDATE() ;

        PRINT '=================================================' ;
        PRINT 'Silver Layer Data Transformation Completed' ;
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND , @batch_start_time , @batch_end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '=================================================' ;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK ;

        PRINT '=================================================' ;
        PRINT 'Error message : ' + ERROR_MESSAGE() ;
        PRINT 'Error number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR) ;
        PRINT 'Error state   : ' + CAST(ERROR_STATE()  AS NVARCHAR) ;
        PRINT '=================================================' ;
    END CATCH
END ;
