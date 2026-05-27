/*
========================================================================================
Create Database and Schemas
========================================================================================
Script Purpose:
    This script creates a new database named 'BusinessDW'.

    If the database already exists, it will be safely dropped and recreated.
    The script also creates three schemas used in the Medallion Architecture:
        - Bronze  (Raw data layer)
        - Silver  (Cleaned and transformed layer)
        - Gold    (Business-ready layer)

WARNING:
    Running this script will permanently DROP the 'BusinessDW' database.
    All existing data will be deleted.

    Ensure that proper backups are available before executing this script.

Author      : Ritik__
Created On  : 2026-02-26
Version     : 1.0
Project     : Data Warehousing
Project Name: BusinessDW

Environment:
    Development / Testing

Dependencies:
    - Microsoft SQL Server (RDBMS)
    - Appropriate database creation permissions

    Ensure you have the required privileges before executing this script.
========================================================================================
*/

-- Switch to master database
USE master;
GO

-- Safety check: Ensure script is executed in the master database
IF DB_NAME() NOT IN ('master')
BEGIN
    THROW 50000 , 'This script must be executed in the master database.', 1;
    RETURN;
END;
GO

-- Drop and recreate the BusinessDW database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BusinessDW')
BEGIN
    PRINT 'Dropping existing BusinessDW database...' ;

    ALTER DATABASE BusinessDW
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;

    DROP DATABASE BusinessDW ;
END ;
GO

-- Create BusinessDW database
PRINT 'Creating BusinessDW database...';
CREATE DATABASE BusinessDW ;
GO

-- Switch to BusinessDW
USE BusinessDW ;
GO

-- Safety check: Ensure script is executed in the BusinessDW database
IF DB_NAME() NOT IN ('BusinessDW')
BEGIN
    THROW 50000 , 'This script must be executed in the BusinessDW database.', 1;
    RETURN;
END;
GO

--======================================================================================

-- Create Bronze schema (Raw ingestion layer)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Bronze')
BEGIN
    PRINT 'Creating Bronze schema...';
    EXEC sp_executesql 
        N'CREATE SCHEMA Bronze AUTHORIZATION dbo';
END;
GO

-- Create Silver schema (Cleaned and standardized layer)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Silver')
BEGIN
    PRINT 'Creating Silver schema...';
    EXEC sp_executesql 
        N'CREATE SCHEMA Silver AUTHORIZATION dbo';
END;
GO

-- Create Gold schema (Business and analytics layer)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Gold')
BEGIN
    PRINT 'Creating Gold schema...';
    EXEC sp_executesql 
        N'CREATE SCHEMA Gold AUTHORIZATION dbo';
END;
GO

--======================================================================================
