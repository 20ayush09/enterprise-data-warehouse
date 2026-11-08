if object_ID ('gold.vw_cst_detail') is not null 
drop view gold.vw_cst_detail;
GO
create view gold.vw_cst_detail as 
(
select 
cci.cst_id [Customer_ID],
cci.cst_key [Customer_Key],
cci.cst_lastname [First_Name] 
,cci.cst_firstname [Last_Name],
eci.BDATE [Birth_Date],
ecl.COUNTRY,
cci.cst_gender [Gender],
cci.cst_marital_status [Marital_Status],
cci.cst_creation_date [Update_Date]
from [silver].[crm_cust_info] as cci
left join silver.erp_cust_info  as eci 
on cci.cst_key =eci.cst_key
left join silver.erp_cust_loc as ecl
on ecl.CID = cci.cst_key
)
go
if object_ID ('gold.vw_prd_info') is not null 
drop view gold.vw_prd_info;

go

create view gold.vw_prd_info as 
(
select 
cpi.prd_id as product_id,
cpi.prd_num as product_num,
cpi.cat_key as category_key,
cpi.prd_nm as product_name,
cpi.prd_cost as product_cost,
cpi.prd_line as product_line,
eri.CAT as product_category,
eri.SUBCAT as product_subcategory,
eri.MAINTENANCE ,
cpi.prd_start_dt as [start_date],
cpi.prd_end_dt as [end_date]
from silver.crm_prd_info as cpi
left join silver.erp_prd_info as eri
on  eri.ID =cpi.cat_key
)
go
if object_ID ('gold.vw_sales_info') is not null 
drop view gold.vw_sales_info;
GO
create view gold.vw_sales_info as (
	SELECT  
        [sls_ord_num] as Order_number
      ,[sls_prd_key] as Product_key
      ,[sls_cust_id] as customer_id
      ,[sls_order_dt] as order_date
      ,[sls_ship_dt] as ship_date
      ,[sls_due_dt] as due_date
      ,[sls_sales]  as Sales
      ,[sls_quantity] as Quantity
      ,[sls_price] as Price
  FROM [Data_Warehouse].[silver].[crm_sales_detail]
)


