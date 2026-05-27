/*=============================================================================================
--====CREATING DDL FOR SILVER LAYER
===============================================================================================
purpose : 
	these script will create tables for bronze layer ,
	if table is already created if will drop table and recreate .
	
	the script will create these following table .
		- bronze.crm_cust_info 
		- bronze.crm_prd_info
		- bronze.crm_sales_details
		
		- bronze.erp_cust_az12
		- bronze.erp_loc_a101
		- bronze.erp_px_cat_g1v2
WARNING :
	execute these script will drop you tables if exists
	all data will permanently deleted .
	
	ensure that backup are available before executing these script .
	
Author : Ritik__
Created on : 2026-02-25
Version : 1.0
project : DataWarehouse2
schema : Bronze

Environment :
	Development / Testing
	
Dependencies :
    - SQL Server Management Studio (SSMS)
=============================================================================================*/

-- Switch Databse to BusinessDW databse
USE BusinessDW ;
GO

-- Safety check to ensure we are connected to the correct database
IF DB_NAME() NOT IN ('BusinessDW')
BEGIN
    THROW 50000, 'Error: Not connected to BusinessDW database. Please switch to BusinessDW before running this script.', 1;
    RETURN;
END;
GO

/*===============================================================
Schema : Silver | Source : CRM | Table : Silver.crm_cust_info
--=============================================================*/

-- Dropping table Silver.crm_cust_info if exists
IF OBJECT_ID('Silver.crm_cust_info' , 'U') IS NOT NULL 
BEGIN
    PRINT 'Dropping Table Silver.crm_cust_info......' ;
    DROP TABLE Silver.crm_cust_info ;
END ;
GO 

-- Creating table Silver.crm_cust_info 
PRINT 'Creating table Silver.crm_cust_info.......' ;
CREATE TABLE Silver.crm_cust_info
(
    cst_id              INT         ,
    cst_key             NVARCHAR(30),

    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(10),
    cst_gndr            NVARCHAR(10),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()        
)
GO

/*===============================================================
Schema : Silver | Source : CRM | Table : Silver.crm_prd_info
--=============================================================*/

IF OBJECT_ID('Silver.crm_prd_info', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping Table Silver.crm_prd_info.........' ;
    DROP TABLE Silver.crm_prd_info;
END ;
GO

PRINT 'Creating table Silver.crm_prd_info...........' ;
CREATE TABLE Silver.crm_prd_info (
    prd_id          INT,
    prd_key         NVARCHAR(50),

    prd_nm          NVARCHAR(50),
    prd_cost        DECIMAL(10,2),
    prd_line        NVARCHAR(20),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*===============================================================
Schema : Silver | Source : CRM | Table : Silver.crm_sales_details
--=============================================================*/

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping table silver.crm_sales_details........' ;
    DROP TABLE silver.crm_sales_details ;
END ;
GO

PRINT 'Creating table silver.crm_sales_details........' ;
CREATE TABLE Silver.crm_sales_details (
    sls_ord_num    NVARCHAR(20),
    sls_prd_key    NVARCHAR(20),
    sls_cust_id    INT,

    sls_order_dt   DATE,
    sls_ship_dt    DATE,
    sls_due_dt     DATE,
    sls_sales      DECIMAL(10,2),
    sls_quantity   INT,
    sls_price      DECIMAL(10,2),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*===============================================================
Schema : Silver | Source : ERP | Table : Silver.erp_loc_a101
--=============================================================*/

IF OBJECT_ID('Silver.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping table Silver.erp_loc_a101..........' ;
    DROP TABLE Silver.erp_loc_a101 ;
END ;
GO

PRINT 'Creating table Silver.erp_loc_a101........' ;
CREATE TABLE Silver.erp_loc_a101 (
    cid            NVARCHAR(30),
    cntry          NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*===============================================================
Schema : Silver | Source : ERP | Table : Silver.erp_cust_az12
--=============================================================*/

IF OBJECT_ID('Silver.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping table Silver.erp_cust_az12......';
    DROP TABLE Silver.erp_cust_az12;
END ;
GO

PRINT 'Creating table Silver.erp_cust_az12......' ;
CREATE TABLE Silver.erp_cust_az12 (
    cid           NVARCHAR(30),
    bdate         DATE,
    gen           NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*===============================================================
Schema : Silver | Source : ERP | Table : Silver.erp_px_cat_g1v2
--=============================================================*/

IF OBJECT_ID('Silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    PRINT 'Dropping table Silver.erp_px_cat_g1v2.......' ;
    DROP TABLE Silver.erp_px_cat_g1v2;
END ;
GO

PRINT 'Creating table Silver.erp_px_cat_g1v2.......' ;
CREATE TABLE Silver.erp_px_cat_g1v2 (
    id            NVARCHAR(30),
    cat           NVARCHAR(50),
    subcat        NVARCHAR(50),
    maintenance   NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
--==============================================================