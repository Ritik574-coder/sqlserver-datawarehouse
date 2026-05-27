/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
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
        PRINT 'Loading Bronze Layer' ;
        PRINT '=================================================' ;

        BEGIN TRANSACTION ;

        PRINT '-------------------------------------------------' ;
        PRINT 'Loading CRM tables' ;
        PRINT '-------------------------------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : bronze.crm_cust_info' ;
        TRUNCATE TABLE bronze.crm_cust_info  ;

        PRINT '>> Loading data into : bronze.crm_cust_info' ;
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/data/Dataset/CRM/cust_info.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        );

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '-----------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table bronze.crm_prd_info' ;
        TRUNCATE TABLE bronze.crm_prd_info ;

        PRINT '>> Inserting data into : bronze.crm_prd_info' ;
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/data/Dataset/CRM/prd_info.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        ) ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND,@start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '-----------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : bronze.crm_sales_details' ;
        TRUNCATE TABLE bronze.crm_sales_details ;

        PRINT 'Inserting data into : bronze.crm_sales_details' ;
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/data/Dataset/CRM/sales_details.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        ) ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        PRINT '-------------------------------------------------' ;
        PRINT 'Loading ERP tables' ;
        PRINT '-------------------------------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : bronze.erp_cust_az12' ;
        TRUNCATE TABLE bronze.erp_cust_az12 ;

        PRINT 'Inserting data into : bronze.erp_cust_az12' ;
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/data/Dataset/ERP/CUST_AZ12.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        ) ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : bronze.erp_loc_a101' ;
        TRUNCATE TABLE bronze.erp_loc_a101 ;

        PRINT 'Inserting data into : bronze.erp_loc_a101' ;
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/data/Dataset/ERP/LOC_A101.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        ) ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;
        
        SET @start_time = GETDATE() ;

        PRINT '>> Truncating table : bronze.erp_px_cat_g1v2' ;
        TRUNCATE TABLE bronze.erp_px_cat_g1v2 ;

        PRINT 'Inserting data into : bronze.erp_px_cat_g1v2' ;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/data/Dataset/ERP/PX_CAT_G1V2.csv'
        WITH(
            FIRSTROW = 2 ,
            FIELDTERMINATOR = ',' ,
            ROWTERMINATOR = '\n' ,
            TABLOCK
        ) ;

        SET @end_time = GETDATE() ;

        PRINT 'Loading Duration : ' + CAST(DATEDIFF(SECOND , @start_time , @end_time)AS NVARCHAR) + ' seconds' ;
        PRINT '------------------------' ;

        COMMIT ;

        SET @batch_end_time = GETDATE() ;

        PRINT '=================================================' ;
        PRINT 'Loading Bronze Layer Completed' ;
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
