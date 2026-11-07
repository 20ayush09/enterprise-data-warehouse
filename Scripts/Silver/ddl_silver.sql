--====================================================================
 
/*
===============================================================================
Script Name : create_tables.sql
Description : Drops and recreates tables in the database.
Author      : Ayush Agarwal
Created On  : 2026-11-05
===============================================================================

WARNING:
    This script contains destructive operations (DROP TABLE).
    Executing this script will permanently delete existing tables and all
    data stored within them before recreating the tables.

    Ensure that:
        1. You are connected to the correct database.
        2. Required data has been backed up, if necessary.
        3. This script is being executed in the intended environment.

PURPOSE:
    To reset and recreate the database tables with their defined structures.
    Primarily intended for development, testing, and controlled database
    initialization or reset operations.

USAGE:
    1. Review the target database and schema before execution.
    2. Execute only when a full table reset is intended.
    3. Run the appropriate data-loading scripts afterward, if required.

PRECAUTIONS:
    - Do not execute in production without explicit authorization.
    - DROP TABLE removes the table structure and its data.
    - Dependent foreign keys, views, procedures, or other objects may be
      affected or may prevent the operation.
    - Verify the script's DROP and CREATE statements before execution.
*/
--====================================================================
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- This script recreates 3 tables from crm amd 3 tables from erp.
-- tables from crm : crm_cust_info , crm_prd_info, crm_sales_detail
-- tables from erp : erp_cust_info , erp_cust_loc , erp_prd_info
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
USE Data_Warehouse
-------------------------------------------------------------------------
-- Drops the crm customer info table and recreates it 
IF OBJECT_ID('silver.crm_cust_info') IS NOT NULL 
BEGIN 
	DROP TABLE silver.crm_cust_info
END

GO

CREATE TABLE silver.crm_cust_info
(
	 cst_id  INT  ,
	 cst_key  VARCHAR (10),
	 cst_firstname  VARCHAR(50),
	 cst_lastname  VARCHAR(50),
	 cst_marital_status  VARCHAR(10),
	 cst_gender VARCHAR(10),
	 cst_creation_date DATE,
	 dwh_update_date datetime default sysdatetime()


)

GO
-------------------------------------------------------------------------------------------
--Drops the crm product info table and recreate it 
IF OBJECT_ID('silver.crm_prd_info') IS NOT NULL 
BEGIN 
	DROP TABLE silver.crm_prd_info
END

GO

CREATE TABLE silver.crm_prd_info
(
	prd_id int  ,
	prd_key VARCHAR(50) ,
	cat_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost FLOAT,
	prd_line VARCHAR(50) ,
	prd_start_dt DATETIME ,
	prd_end_dt DATETIME
	,	 dwh_update_date datetime default sysdatetime()
)

GO
-------------------------------------------------------------------------------------------
-- drop the crm sales info table and recreates it 
IF OBJECT_ID('silver.crm_sales_detail') IS NOT NULL 
BEGIN 
	DROP TABLE silver.crm_sales_detail
END

GO

CREATE TABLE silver.crm_sales_detail
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt	 DATE ,
	sls_due_dt	DATE,
	sls_sales	FLOAT,
	sls_quantity INT,
	sls_price FLOAT
	,	 dwh_update_date datetime default sysdatetime()
		
)

GO
-------------------------------------------------------------------------------------------
-- drop the erp customer info table and recreate it 
IF OBJECT_ID('silver.erp_cust_info') IS NOT NULL 
BEGIN 
	DROP TABLE silver.erp_cust_info
END

GO

CREATE TABLE silver.erp_cust_info 
(
	CID VARCHAR(50),
	cst_key VARCHAR(50),
	BDATE DATE,
	GEN VARCHAR(10)
	,	 dwh_update_date datetime default sysdatetime()
)

GO
-------------------------------------------------------------------------------------------
-- drops the erp customer location table and recreates it 
IF OBJECT_ID('silver.erp_cust_loc') IS NOT NULL 
BEGIN 
DROP TABLE silver.erp_cust_loc
END

GO

CREATE TABLE silver.erp_cust_loc
(
	CID VARCHAR(50 ),
	COUNTRY VARCHAR(50)
	,	 dwh_update_date datetime default sysdatetime()
		
)

GO
-------------------------------------------------------------------------------------------
-- drops the erp product info tabel and recreates it 
IF OBJECT_ID('silver.erp_prd_info') IS NOT NULL 
BEGIN 
DROP TABLE silver.erp_prd_info
END

GO

CREATE TABLE silver.erp_prd_info
(
	ID VARCHAR(50) ,
	CAT VARCHAR(50),
	SUBCAT VARCHAR(50),
	MAINTENANCE VARCHAR(5)
	,	 dwh_update_date datetime default sysdatetime()
)
-------------------------------------------------------------------------------------------
