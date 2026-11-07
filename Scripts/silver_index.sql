create clustered index idx_silver_crm_cust_info_clus on silver.crm_cust_info ( cst_key)
go
create clustered index idx_silver_crm_prd_info_clus on silver.crm_prd_info (prd_key)
GO
create nonclustered index idx_silver_crm_prd_info_nonclus_cat_key on silver.crm_prd_info (cat_key)
go
create clustered index idx_silver_crm_sales_info_clus on silver.crm_sales_detail ( sls_ord_num)
go
create clustered index idx_silver_erp_cust_info on silver.erp_cust_info (cst_key )
go
create clustered index idx_silver_erp_cust_loc_clus on silver.erp_cust_loc ( cst_key)
go
create clustered index idx_silver_erp_prd_info_clus on silver.erp_prd_info ( CID)