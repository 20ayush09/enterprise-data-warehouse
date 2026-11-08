/*
===============================================================================
PROJECT      : Data Warehouse
SCRIPT       : load_silver.sql
PROCEDURE    : load_silver
LAYER        : Silver Layer
===============================================================================

PURPOSE
-------
Loads and transforms data from the Bronze layer into the Silver layer of the
Data Warehouse.

The procedure performs data cleansing, standardization, and basic validation
before inserting the transformed data into the corresponding Silver tables.

TABLES PROCESSED
----------------
1. silver.crm_sales_detail
   - Standardizes sales dates.
   - Cleans sales amounts and unit prices.
   - Loads sales transaction data.

2. silver.crm_cust_info
   - Handles missing customer IDs.
   - Trims customer names.
   - Standardizes marital status and gender.

3. silver.crm_prd_info
   - Derives category keys from product keys.
   - Standardizes product line descriptions.
   - Calculates product end dates using LEAD().
   - Filters records based on the calculated end date.

4. silver.erp_cust_info
   - Derives customer keys from customer IDs.
   - Handles future birth dates.
   - Standardizes gender descriptions.

5. silver.erp_cust_loc
   - Standardizes customer IDs.
   - Normalizes country names.
   - Handles missing and whitespace-containing country values.

6. silver.erp_prd_info
   - Cleans maintenance descriptions.
   - Removes tab, carriage-return, and line-feed characters.
   - Converts maintenance descriptions to uppercase.

EXECUTION MONITORING
--------------------
- Records the start and end time of individual table loads.
- Prints the elapsed time for each table transformation.
- Records and prints the total elapsed time for the Silver layer load.

EXECUTION FLOW
--------------
1. Initialize execution timers.
2. Truncate the target Silver table.
3. Insert transformed data from the corresponding Bronze table.
4. Calculate and print the execution time.
5. Repeat for each remaining table.
6. Print the total execution time.

PRECAUTIONS AND WARNINGS
------------------------
1. DESTRUCTIVE OPERATION:
   TRUNCATE TABLE removes all existing rows from each target Silver table
   before the new data is inserted. Ensure that the target tables are correct
   and that the source data is available before execution.

2. DATA LOSS RISK:
   If an INSERT statement fails after a table has been truncated, the affected
   Silver table may remain empty or partially loaded, depending on the failure
   and execution context.

3. TRANSACTION HANDLING:
   This procedure does not explicitly implement a transaction or TRY...CATCH
   error-handling block. Review recovery requirements before production use.

4. DATE CONVERSION:
   The sales date expressions rely on the source values being convertible to
   DATE. Invalid date values may cause conversion errors.

5. DATA TYPE COMPATIBILITY:
   Ensure that source expressions and destination column data types are
   compatible, particularly for customer IDs, dates, sales, and prices.

6. BUSINESS RULES:
   Sales amounts, prices, customer classifications, product lines, and country
   names are transformed according to the rules defined in this procedure.
   Validate these rules against the intended business requirements.

7. PRODUCT HISTORY:
   The product transformation filters records using prd_last_dt IS NULL.
   Verify that this behavior matches the intended product-history requirements.

8. EXECUTION TIME:
   DATEDIFF(SECOND, ...) reports elapsed time in whole seconds. Operations
   completing in less than one second may display zero seconds.

9. EXECUTION PERMISSIONS:
   The executing account must have the necessary permissions to truncate
   target tables and insert data.

10. DEPENDENCIES:
    The Data_Warehouse database, Bronze source tables, Silver target tables,
    and their expected schemas must exist before execution.

MAINTENANCE NOTES
-----------------
- Keep the source and target column mappings synchronized with their schemas.
- Validate row counts and data quality after execution.
- Review printed execution times to identify unusually slow transformations.
- Update this documentation whenever the procedure's behavior changes.

IMPORTANT
---------
The SQL statements below have been preserved as provided. Comments and
formatting are documentation-only additions.

===============================================================================
*/


USE Data_Warehouse;
GO

CREATE OR ALTER PROCEDURE load_silver
AS

BEGIN

    /*=========================================================================
      DECLARE EXECUTION TIMERS
      -------------------------------------------------------------------------
      @StartTime      : Start time of the current table load.
      @EndTime        : End time of the current table load.
      @TotalStartTime : Start time of the complete Silver layer load.
      @TotalEndTime   : End time of the complete Silver layer load.
    =========================================================================*/

    DECLARE
        @StartTime DATETIME2,
        @EndTime DATETIME2,
        @TotalStartTime DATETIME2,
        @TotalEndTime DATETIME2;


    /*=========================================================================
      1. CRM SALES DETAIL
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Standardize sales dates.
      - Clean sales amounts and prices.
      - Insert transformed sales transaction data.
    =========================================================================*/

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('truncating and adding the silver.crm_sales_detial');

    SET @StartTime = SYSDATETIME();
    SET @TotalStartTime = SYSDATETIME();

    TRUNCATE TABLE silver.crm_sales_detail;

    INSERT INTO silver.crm_sales_detail
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )

    SELECT
        [sls_ord_num],
        [sls_prd_key],
        [sls_cust_id],

        -- Validate the order date length before converting it to DATE.
        CASE
            WHEN LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR(50)) AS DATE)
        END AS sls_order_dt,

        -- Validate the shipping date length before converting it to DATE.
        CASE
            WHEN LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR(50)) AS DATE)
        END AS sls_ship_date,

        -- Validate the due date length before converting it to DATE.
        CASE
            WHEN LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR(50)) AS DATE)
        END AS sls_due_date,

        -- Recalculate sales when the source sales value differs
        -- from quantity multiplied by price.
        CASE
            WHEN [sls_sales] != sls_quantity * sls_price
                THEN sls_quantity * ABS(sls_price)
            ELSE ABS(sls_sales)
        END AS sls_sales,

        [sls_quantity],

        -- Derive the unit price when the source price is non-positive.
        -- NULLIF prevents division by zero when quantity is zero.
        CASE
            WHEN [sls_price] <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE ABS(sls_price)
        END AS sls_price

    FROM [Data_Warehouse].[bronze].[crm_sales_detail];


    -- Record and print the execution time for the sales detail load.
    SET @EndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.crm_sales_detial:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


    /*=========================================================================
      2. CRM CUSTOMER INFORMATION
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Handle missing customer IDs.
      - Remove leading and trailing whitespace from names.
      - Standardize marital status and gender descriptions.
    =========================================================================*/

    PRINT('truncating and adding the silver.crm_cust_info');

    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info
    (
        [cst_id],
        [cst_key],
        [cst_firstname],
        [cst_lastname],
        [cst_marital_status],
        [cst_gender],
        [cst_creation_date]
    )

    SELECT
        -- Derive the customer ID from the customer key when the ID is NULL.
        CASE
            WHEN [cst_id] IS NULL
                THEN SUBSTRING(cst_key, 6, LEN(cst_key))
            ELSE cst_id
        END AS cst_id,

        [cst_key],

        -- Remove leading and trailing whitespace from customer names.
        TRIM([cst_firstname]) AS first_name,
        TRIM([cst_lastname]) AS last_name,

        -- Standardize marital status descriptions.
        CASE
            WHEN UPPER([cst_marital_status]) = 'M' THEN 'MARRIED'
            WHEN UPPER(cst_marital_status) = 'S' THEN 'SINGLE'
            ELSE UPPER(COALESCE(cst_marital_status, 'N/A'))
        END AS cst_marital_status,

        -- Standardize gender descriptions.
        CASE
            WHEN UPPER([cst_gender]) = 'M' THEN 'MALE'
            WHEN UPPER(cst_gender) = 'F' THEN 'FEMALE'
            ELSE UPPER(COALESCE(cst_gender, 'N/A'))
        END AS cst_gender,

        [cst_creation_date]

    FROM [Data_Warehouse].[bronze].[crm_cust_info];


    -- Record and print the execution time for the customer information load.
    SET @EndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.crm_cust_info:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


    /*=========================================================================
      3. CRM PRODUCT INFORMATION
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Derive the category key from the product key.
      - Standardize product line descriptions.
      - Calculate product end dates using LEAD().
      - Retain records whose calculated end date is NULL.
    =========================================================================*/

    PRINT('truncating and adding the silver.crm_prd_info');

    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info
    (
        [prd_num],
        [prd_id],
        [cat_key],
        [prd_nm],
        [prd_cost],
        [prd_line],
        [prd_start_dt],
        [prd_end_dt]
    )

    SELECT *
    FROM
    (
        SELECT
        substring (prd_key,7,len(prd_key)) as prd_num,
            [prd_id],
            -- Derive the category key from the first five characters
            -- of the product key and replace the hyphen with an underscore.
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_key,

            [prd_nm],
            [prd_cost],

            -- Standardize product line codes into descriptive labels.
            CASE UPPER(TRIM([prd_line]))
                WHEN 'M' THEN 'MOUNTAIN'
                WHEN 'R' THEN 'ROAD'
                WHEN 'S' THEN 'OTHER SALES'
                WHEN 'T' THEN 'TOURING'
                ELSE 'N/A'
            END AS prd_line,

            [prd_start_dt],

            -- Calculate the end date using the next start date
            -- for the same product key, minus one day.
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt ASC
            ) - 1 AS prd_last_dt

        FROM [Data_Warehouse].[bronze].[crm_prd_info]

    ) t

    -- Retain rows for which no subsequent start date exists.
    WHERE prd_last_dt IS NULL;


    -- Record and print the execution time for the product information load.
    SET @EndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.crm_prd_info:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


    /*=========================================================================
      4. ERP CUSTOMER INFORMATION
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Derive the customer key from the customer ID.
      - Replace future birth dates with NULL.
      - Standardize gender descriptions.
    =========================================================================*/

    PRINT('truncating and adding the silver.erp_cust_info');

    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE silver.erp_cust_info;

    INSERT INTO silver.erp_cust_info
    (
        [CID],
        [cst_key],
        [BDATE],
        [GEN]
    )

    SELECT
        CID,

        -- Derive the customer key by extracting part of the customer ID.
        SUBSTRING(CID, 4, 10000) AS cst_key,

        -- Replace birth dates later than the current date with NULL.
        CASE
            WHEN BDATE > GETDATE() THEN NULL
            ELSE BDATE
        END BDATE,

        -- Standardize gender values and handle missing values.
        CASE
            WHEN GEN = '' THEN 'N/A'
            WHEN UPPER(TRIM(GEN)) = 'F' THEN 'FEMALE'
            WHEN UPPER(TRIM(GEN)) = 'MA' THEN 'MALE'
            ELSE COALESCE(UPPER(GEN), 'N/A')
        END AS GEN

    FROM bronze.erp_cust_info;


    -- Record and print the execution time for the ERP customer load.
    SET @EndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.erp_cust_info:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


    /*=========================================================================
      5. ERP CUSTOMER LOCATION
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Standardize customer IDs.
      - Normalize selected country names.
      - Remove control characters and handle blank country values.
    =========================================================================*/

    PRINT('truncating and adding the silver.erp_cust_loc');

    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE silver.erp_cust_loc;

    INSERT INTO silver.erp_cust_loc
    (
        [CID],
        [COUNTRY]
    )

    SELECT
        -- Remove hyphens from customer IDs.
        REPLACE(CID, '-', '') AS CID,

        -- Normalize country codes and clean country descriptions.
CASE
    WHEN UPPER(
        TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(COUNTRY, CHAR(9), ''),
                        CHAR(10), ''
                    ),
                    CHAR(13), ''
                ),
                CHAR(160), ' '
            )
        )
    ) = 'DE' THEN 'Germany'

    WHEN UPPER(
        TRIM(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(COUNTRY, CHAR(9), ''),
                        CHAR(10), ''
                    ),
                    CHAR(13), ''
                ),
                CHAR(160), ' '
            )
        )
    ) IN ('US', 'USA') THEN 'United States'

    ELSE COALESCE(
        NULLIF(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(COUNTRY, CHAR(9), ''),
                            CHAR(10), ''
                        ),
                        CHAR(13), ''
                    ),
                    CHAR(160), ' '
                )
            ),
            ''
        ),
        'N/A'
    )
END AS COUNTRY
   

    FROM bronze.erp_cust_loc;


    -- Record and print the execution time for the ERP customer location load.
    SET @EndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.erp_cust_loc:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


    /*=========================================================================
      6. ERP PRODUCT INFORMATION
      -------------------------------------------------------------------------
      Purpose:
      - Truncate the existing Silver table.
      - Clean the maintenance description.
      - Remove tab, line-feed, and carriage-return characters.
      - Trim surrounding whitespace and convert the description to uppercase.
    =========================================================================*/

    PRINT('truncating and adding the silver.erp_prd_info');

    SET @StartTime = SYSDATETIME();

    TRUNCATE TABLE silver.erp_prd_info;

    INSERT INTO silver.erp_prd_info
    (
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    )

    SELECT
       
        [ID],
        [CAT],
        [SUBCAT],

        -- Remove control characters, trim whitespace, and standardize case.
        UPPER(
            TRIM(
                REPLACE(
                    REPLACE(
                        REPLACE(MAINTENANCE, CHAR(9), ''),
                        CHAR(10), ''
                    ),
                    CHAR(13), ''
                )
            )
        ) AS MAINTENANCE

    FROM [Data_Warehouse].[bronze].[erp_prd_info];


    /*=========================================================================
      FINAL EXECUTION TIMING
      -------------------------------------------------------------------------
      Capture the end time of the final table load and the total execution.
      Print the final table-load duration and total elapsed time.
    =========================================================================*/

    SET @EndTime = SYSDATETIME();
    SET @TotalEndTime = SYSDATETIME();

    PRINT CONCAT(
        'TIME TAKEN TO ADD silver.erp_prd_info:',
        DATEDIFF(SECOND, @StartTime, @EndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

    PRINT CONCAT(
        ' TOTAL TIME TAKEN TO ADD data in silver layer:',
        DATEDIFF(SECOND, @TotalStartTime, @TotalEndTime),
        ' second'
    );

    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

END;
GO

-- Execute the Silver layer loading procedure.
EXEC load_silver;
