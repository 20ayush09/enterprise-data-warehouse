IF OBJECT_ID('bronze.crm_cust_info') IS NOT NULL 
BEGIN 
DROP TABLE bronze.crm_cust_info
END

GO

CREATE TABLE bronze.crm_cust_info
(
	 cst_id  INT PRIMARY KEY ,
	 cst_key  VARCHAR (10),
	 cst_firstname  VARCHAR(50),
	 cst_lastname  VARCHAR(50),
	 cst_marital_status  VARCHAR(10),
	 cst_gender VARCHAR(10),
	 cst_creation_date DATETIME2,
	dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()
)

GO
IF OBJECT_ID('bronze.crm_prd_info') IS NOT NULL 
BEGIN 
DROP TABLE bronze.crm_prd_info
END

GO

CREATE TABLE bronze.crm_prd_info
(
	prd_id int primary key ,
	prd_key VARCHAR(50) ,
	prd_nm VARCHAR(50),
	prd_cost FLOAT,
	prd_line VARCHAR(50) ,
	prd_start_dt DATETIME ,
	prd_end_dt DATETIME,
	dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()
)

GO

IF OBJECT_ID('bronze.crm_sales_detail') IS NOT NULL 
BEGIN 
DROP TABLE bronze.crm_sales_detail
END

GO

CREATE TABLE bronze.crm_sales_detail
(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt	INT,
	sls_ship_dt	 INT ,
	sls_due_dt	INT,
	sls_sales	FLOAT,
	sls_quantity INT,
	sls_price FLOAT,
	dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()
)

GO

IF OBJECT_ID('bromze.erp_cust_info') IS NOT NULL 
BEGIN 
DROP TABLE bromze.erp_cust_info
END

GO

CREATE TABLE bronze.erp_cust_info 
(
	CID VARCHAR(50),
	BDATE DATE,
	GEN VARCHAR(10),
	dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()

)

GO
IF OBJECT_ID('bronze.erp_cust_loc') IS NOT NULL 
BEGIN 
DROP TABLE bronze.erp_cust_loc
END

GO

CREATE TABLE bronze.erp_cust_loc
(
	CID INT,
	COUNTRY VARCHAR(50),
	dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()
)

GO
IF OBJECT_ID('bronze.erp_product_info') IS NOT NULL 
BEGIN 
DROP TABLE bronze.erp_product_info
END

GO

CREATE TABLE bronze.erp_product_info
(
	ID INT ,
	CAT VARCHAR(50),
	SUBCAT VARCHAR(50),
	MAINTENANCE VARCHAR(5),
dwh_update_datetime DATETIME2 DEFAULT SYSDATETIME()
)

