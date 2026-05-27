/*=============================================================================================
--====CREATING DDL FOR BRONZE LAYER
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
-- Switch to BusinessDW database
USE BusinessDW;
GO

-- Safety check to ensure we are connected to the correct database
IF DB_NAME() NOT IN ('BusinessDW')
BEGIN
    THROW 50000, 'Error: Not connected to BusinessDW database. Please switch to BusinessDW before running this script.', 1;
    RETURN;
END;
GO

/*=============================================================
Bronze : CRM | Table  : Bronze.crm_cust_info
=============================================================*/

-- Drop table if exists
IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table Bronze.crm_cust_info.....';
    DROP TABLE Bronze.crm_cust_info;
END;
GO

-- Create table
PRINT '>> Creating table Bronze.crm_cust_info....';
CREATE TABLE Bronze.crm_cust_info
(
    cst_id               INT           NULL,
    cst_key              NVARCHAR(50)  NULL,

    cst_firstname        NVARCHAR(50)  NULL,
    cst_lastname         NVARCHAR(50)  NULL,
    cst_marital_status   NVARCHAR(20)  NULL,
    cst_gndr             NVARCHAR(10)  NULL,
    cst_create_date      DATE          NULL
) ;
GO


/*=============================================================
Bronze : CRM | Table  : Bronze.crm_prd_info
=============================================================*/
-- Drop table if exists
IF OBJECT_ID('Bronze.crm_prd_info' , 'U') IS NOT NULL 
BEGIN
	PRINT '>> Dropping Table Bronze.crm_prd_info.....' ;
	DROP TABLE Bronze.crm_prd_info ;
END ;
GO
-- Create table 
PRINT '>> Creating table Bronze.crm_prd_info....';
CREATE TABLE Bronze.crm_prd_info
(
	prd_id		    INT           NULL,
	prd_key			NVARCHAR(30)  NULL,

	prd_nm			NVARCHAR(155) NULL,
	prd_cost		DECIMAL(10,2) NULL,
	prd_line		NVARCHAR(30)  NULL,
	prd_start_dt	DATE          NULL,
	prd_end_dt		DATE          NULL
) ;
GO

/*=============================================================
Bronze : CRM | Table  : Bronze.crm_sales_details
=============================================================*/
-- Drop table if exists
IF OBJECT_ID('Bronze.crm_sales_details' , 'U') IS NOT NULL 
BEGIN
	PRINT '>> Dropping Table Bronze.crm_sales_details....' ;
	DROP TABLE Bronze.crm_sales_details ;
END ;
GO 

-- Creating table Bronze.crm_sales_details
PRINT '>> Creating table Bronze.crm_sales_details.....' ;
CREATE TABLE Bronze.crm_sales_details
(
	sls_ord_num    NVARCHAR(20) NULL ,
	sls_prd_key    NVARCHAR(50) NULL ,
	sls_cust_id    INT          NULL ,

	sls_order_dt  INT   		NULL ,
	sls_ship_dt   INT   		NULL ,
	sls_due_dt    INT   		NULL ,
							    
	sls_sales     DECIMAL(10,2) NULL ,
	sls_quantity  INT  			NULL ,
	sls_price     DECIMAL(10,2) NULL 
) ;
GO

/*=============================================================
Bronze : ERP | Table  : Bronze.erp_cust_az12
=============================================================*/
-- Drop table if exists
IF OBJECT_ID('Bronze.erp_cust_az12' , 'U') IS NOT NULL 
BEGIN 
	PRINT '>> Dropping table Bronze.erp_cust_az12...' ;
	DROP TABLE Bronze.erp_cust_az12 ;
END 
GO 

-- Creating Table Bronze.erp_cust_az12
PRINT '>> Creating table Bronze.erp_cust_az12....' ;
CREATE TABLE Bronze.erp_cust_az12
(
	cid				NVARCHAR(30) NULL ,

	bdate			DATE		 NULL ,
	gen				NVARCHAR(20) NULL 
) ;
GO

/*=============================================================
Bronze : ERP | Table : Bronze.erp_loc_a101
=============================================================*/
-- Drop table if exists
IF OBJECT_ID('Bronze.erp_loc_a101' , 'U') IS NOT NULL
BEGIN 
	PRINT '>> Dropping table Bronze.erp_loc_a101.....' ;
	DROP TABLE Bronze.erp_loc_a101 ;
END ;
GO

-- Creating table Bronze.erp_loc_a101
PRINT '>> Creating Table Bronze.erp_loc_a101......' ;
CREATE TABLE Bronze.erp_loc_a101
(
	cid				NVARCHAR(30) NULL ,
	cntry			NVARCHAR(155) NULL 
) ;
GO

/*=============================================================
Bronze : ERP | Table : Bronze.erp_px_cat_g1v2
=============================================================*/
-- Drop table if exists
IF OBJECT_ID('Bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL 
BEGIN 
	PRINT '>> Dropping table Bronze.erp_px_cat_g1v2......' ;
	DROP TABLE Bronze.erp_px_cat_g1v2 ;
END ;
GO

-- Creating table 
PRINT '>> Creating Table Bronze.erp_px_cat_g1v2......' ;
CREATE TABLE Bronze.erp_px_cat_g1v2 
(
	id            NVARCHAR(20)  NULL ,
			  
	cat           NVARCHAR(50)  NULL ,
	subcat        NVARCHAR(100) NULL ,
	maintenance   NVARCHAR(10)  NULL 
)  ;
GO

--==========================================================
