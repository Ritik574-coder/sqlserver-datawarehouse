
/*=============================================================================================
--==== CREATING DDL FOR SILVER LAYER
===============================================================================================
Purpose :
    These scripts create tables for the Silver layer.

    If tables already exist, they will be dropped and recreated.

    The script will create the following tables:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

        - silver.erp_cust_az12
        - silver.erp_loc_a101
        - silver.erp_px_cat_g1v2

WARNING :
    Executing this script will DROP existing Silver tables.

    All existing data in those tables will be permanently deleted.

    Ensure backups are available before execution.

Author : Ritik__
Created on : 2026-05-28
Version : 1.0
Project : BusinessDW
Schema : Silver

Environment :
    Development / Testing

Dependencies :
    - SQL Server Management Studio (SSMS)
=============================================================================================*/

-- Switch to BusinessDW database
USE BusinessDW;
GO

-- Safety check
IF DB_NAME() NOT IN ('BusinessDW')
BEGIN
    THROW 50000, 'Error: Not connected to BusinessDW database.', 1;
    RETURN;
END;
GO

/*============================================================================
Create Schema if not exists
============================================================================*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

/*============================================================================
Silver : CRM | Table : silver.crm_cust_info
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.crm_cust_info...';
    DROP TABLE silver.crm_cust_info;
END;
GO

-- Create table
PRINT '>> Creating table silver.crm_cust_info...';

CREATE TABLE silver.crm_cust_info
(
    cst_id                 INT             NOT NULL,
    cst_key                NVARCHAR(50)    NOT NULL,
    cst_firstname          NVARCHAR(50)    NULL,
    cst_lastname           NVARCHAR(50)    NULL,
    cst_marital_status     NVARCHAR(20)    NULL,
    cst_gndr               NVARCHAR(10)    NULL,
    cst_create_date        DATE            NULL,
    dwh_create_date        DATETIME2       DEFAULT GETDATE(),

    CONSTRAINT pk_silver_crm_cust_info
        PRIMARY KEY (cst_id)
);
GO

/*============================================================================
Silver : CRM | Table : silver.crm_prd_info
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.crm_prd_info...';
    DROP TABLE silver.crm_prd_info;
END;
GO

-- Create table
PRINT '>> Creating table silver.crm_prd_info...';

CREATE TABLE silver.crm_prd_info
(
    prd_id                 INT              NOT NULL,
    cat_id                 NVARCHAR(50)     NULL,
    prd_key                NVARCHAR(30)     NOT NULL,
    prd_nm                 NVARCHAR(155)    NULL,
    prd_cost               DECIMAL(18,2)    NULL,
    prd_line               NVARCHAR(30)     NULL,
    prd_start_dt           DATE             NULL,
    prd_end_dt             DATE             NULL,
    dwh_create_date        DATETIME2        DEFAULT GETDATE(),

    CONSTRAINT pk_silver_crm_prd_info
        PRIMARY KEY (prd_id)
);
GO

/*============================================================================
Silver : CRM | Table : silver.crm_sales_details
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.crm_sales_details...';
    DROP TABLE silver.crm_sales_details;
END;
GO

-- Create table
PRINT '>> Creating table silver.crm_sales_details...';

CREATE TABLE silver.crm_sales_details
(
    sls_ord_num            NVARCHAR(20)     NOT NULL,
    sls_prd_key            NVARCHAR(50)     NOT NULL,
    sls_cust_id            INT              NOT NULL,
    sls_order_dt           DATE             NULL,
    sls_ship_dt            DATE             NULL,
    sls_due_dt             DATE             NULL,
    sls_sales              DECIMAL(18,2)    NULL,
    sls_quantity           INT              NULL,
    sls_price              DECIMAL(18,2)    NULL,

    dwh_create_date        DATETIME2        DEFAULT GETDATE()
);
GO

/*============================================================================
Silver : ERP | Table : silver.erp_cust_az12
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.erp_cust_az12...';
    DROP TABLE silver.erp_cust_az12;
END;
GO

-- Create table
PRINT '>> Creating table silver.erp_cust_az12...';

CREATE TABLE silver.erp_cust_az12
(
    cid                    NVARCHAR(30)     NOT NULL,
    bdate                  DATE             NULL,
    gen                    NVARCHAR(20)     NULL,
    dwh_create_date        DATETIME2        DEFAULT GETDATE(),

    CONSTRAINT pk_silver_erp_cust_az12
        PRIMARY KEY (cid)
);
GO

/*============================================================================
Silver : ERP | Table : silver.erp_loc_a101
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.erp_loc_a101...';
    DROP TABLE silver.erp_loc_a101;
END;
GO

-- Create table
PRINT '>> Creating table silver.erp_loc_a101...';

CREATE TABLE silver.erp_loc_a101
(
    cid                    NVARCHAR(30)     NOT NULL,
    cntry                  NVARCHAR(155)    NULL,
    dwh_create_date        DATETIME2        DEFAULT GETDATE(),

    CONSTRAINT pk_silver_erp_loc_a101
        PRIMARY KEY (cid)
);
GO

/*============================================================================
Silver : ERP | Table : silver.erp_px_cat_g1v2
============================================================================*/

-- Drop table if exists
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
BEGIN
    PRINT '>> Dropping table silver.erp_px_cat_g1v2...';
    DROP TABLE silver.erp_px_cat_g1v2;
END;
GO

-- Create table
PRINT '>> Creating table silver.erp_px_cat_g1v2...';

CREATE TABLE silver.erp_px_cat_g1v2
(
    id                     NVARCHAR(20)      NOT NULL,
    cat                    NVARCHAR(50)      NULL,
    subcat                 NVARCHAR(100)     NULL,
    maintenance            NVARCHAR(10)      NULL,
    dwh_create_date        DATETIME2         DEFAULT GETDATE(),

    CONSTRAINT pk_silver_erp_px_cat_g1v2
        PRIMARY KEY (id)
);
GO

/*============================================================================
Foreign Key Constraints
============================================================================*/

-- CRM Sales -> CRM Customers
ALTER TABLE silver.crm_sales_details
ADD CONSTRAINT fk_sales_customer
FOREIGN KEY (sls_cust_id)
REFERENCES silver.crm_cust_info(cst_id);
GO

-- CRM Sales -> CRM Products
ALTER TABLE silver.crm_sales_details
ADD CONSTRAINT fk_sales_product
FOREIGN KEY (sls_prd_key)
REFERENCES silver.crm_prd_info(prd_key);
GO

-- CRM Products -> ERP Product Categories
ALTER TABLE silver.crm_prd_info
ADD CONSTRAINT fk_product_category
FOREIGN KEY (cat_id)
REFERENCES silver.erp_px_cat_g1v2(id);
GO

/*============================================================================
Indexes
============================================================================*/

CREATE INDEX idx_sales_customer
ON silver.crm_sales_details(sls_cust_id);
GO

CREATE INDEX idx_sales_product
ON silver.crm_sales_details(sls_prd_key);
GO

CREATE INDEX idx_customer_key
ON silver.crm_cust_info(cst_key);
GO

CREATE INDEX idx_product_cat
ON silver.crm_prd_info(cat_id);
GO

/*============================================================================
Script Completed
============================================================================*/

PRINT '=====================================================';
PRINT 'Silver Layer Tables Created Successfully';
PRINT '=====================================================';
GO

