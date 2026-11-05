
/*
===============================================================================
PROCEDURE NAME : proc_load_bronze
DATABASE       : Data_Warehouse
PURPOSE        : Load raw CRM and ERP data into the Bronze layer.
AUTHOR         : Ayush Agarwal
CREATED ON     : 2026-11-05
===============================================================================

INTENTION:
    This stored procedure performs a full refresh of the six Bronze-layer
    tables by truncating their existing data and loading fresh records from
    the corresponding source CSV files.

TABLES PROCESSED:
    CRM:
        1. bronze.crm_cust_info
        2. bronze.crm_prd_info
        3. bronze.crm_sales_detail

    ERP:
        4. bronze.erp_cust_info
        5. bronze.erp_cust_loc
        6. bronze.erp_prd_info

EXECUTION FLOW:
    1. Record the start time of the overall procedure.
    2. Truncate each target table to remove its existing records.
    3. Bulk-load the corresponding CSV file into each table.
    4. Calculate and print the execution time for each table load.
    5. Calculate and print the total procedure execution time.
    6. Catch and display error details if an error occurs.

USAGE:
    Execute this procedure when a complete reload of the Bronze layer is
    required.

    EXEC proc_load_bronze;

PRECAUTIONS:
    - TRUNCATE TABLE removes all existing records from the target table.
    - If a subsequent BULK INSERT fails, the table may remain empty or
      partially loaded, depending on the failure and transaction context.
    - The SQL Server service account must have access to the source CSV files.
    - Source CSV column order, data types, and delimiters must match the
      corresponding target table definitions.
    - This procedure does not implement an explicit transaction or rollback.
    - Review the target database before execution.

===============================================================================
*/


-- ============================================================================
-- Set the database context
-- ============================================================================

USE Data_Warehouse;
GO


-- ============================================================================
-- Create or alter the Bronze-layer data-loading procedure
-- ============================================================================

CREATE OR ALTER PROCEDURE proc_load_bronze

AS

    -- Variables used to record individual table-loading durations
    -- and the total execution duration of the procedure.
    DECLARE
        @starttime DATETIME2,
        @endtime DATETIME2,
        @TotalStartTime DATETIME2,
        @TotalEndTime DATETIME2

    BEGIN

        BEGIN TRY

            -- =================================================================
            -- INITIALIZE TOTAL EXECUTION TIMER
            -- =================================================================

            SET @TotalStartTime = SYSDATETIME()

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            -- =================================================================
            -- 1. LOAD CRM CUSTOMER INFORMATION
            -- Truncate existing records and reload from the source CSV file.
            -- =================================================================

            PRINT('Truncating the crm_cust_info table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.crm_cust_info;

            BULK INSERT bronze.crm_cust_info
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_crm\cust_info.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the CRM customer table load.
            PRINT('Time taken to drop and insert the crm_cust_info :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            --------------------------------------------------------------------
            -- 2. LOAD CRM PRODUCT INFORMATION
            -- Truncate existing records and reload from the source CSV file.
            --------------------------------------------------------------------

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

            PRINT('Truncating the crm_prd_info table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.crm_prd_info;

            BULK INSERT bronze.crm_prd_info
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_crm\prd_info.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the CRM product table load.
            PRINT('Time taken to drop and insert the crm_prd_info :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            --------------------------------------------------------------------
            -- 3. LOAD CRM SALES DETAILS
            -- Truncate existing records and reload from the source CSV file.
            --------------------------------------------------------------------

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

            PRINT('Truncating the crm_sales_detail table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.crm_sales_detail;

            BULK INSERT bronze.crm_sales_detail
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_crm\sales_details.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the CRM sales table load.
            PRINT('Time taken to drop and insert the crm_sales_detail :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            --------------------------------------------------------------------
            -- 4. LOAD ERP CUSTOMER INFORMATION
            -- Truncate existing records and reload from the source CSV file.
            --------------------------------------------------------------------

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

            PRINT('Truncating the erp_cust_info table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.erp_cust_info;

            BULK INSERT bronze.erp_cust_info
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_erp\CUST_AZ12.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the ERP customer table load.
            PRINT('Time taken to drop and insert the erp_cust_info :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            --------------------------------------------------------------------
            -- 5. LOAD ERP CUSTOMER LOCATION
            -- Truncate existing records and reload from the source CSV file.
            --------------------------------------------------------------------

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

            PRINT('Truncating the erp_cust_loc table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.erp_cust_loc;

            BULK INSERT bronze.erp_cust_loc
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_erp\LOC_A101.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the ERP customer-location table load.
            PRINT('Time taken to drop and insert the erp_cust_loc :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            --------------------------------------------------------------------
            -- 6. LOAD ERP PRODUCT INFORMATION
            -- Truncate existing records and reload from the source CSV file.
            --------------------------------------------------------------------

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');

            PRINT('Truncating the erp_prd_info table and reentering the data');

            SET @starttime = SYSDATETIME()

            TRUNCATE TABLE bronze.erp_prd_info;

            BULK INSERT bronze.erp_prd_info
                FROM 'C:\Users\2009a\OneDrive\Desktop\SQL_PROJECTS\enterprise-data-warehouse\Data_set\source_erp\PX_CAT_G1V2.csv'
                WITH (
                    FIRSTROW = 2,
                    FIELDTERMINATOR =',',
                    ROWTERMINATOR = '0x0a',
                    TABLOCK
                );

            SET @endtime = SYSDATETIME()

            -- Print the elapsed time for the ERP product table load.
            PRINT('Time taken to drop and insert the erp_prd_info :' +CAST(DATEDIFF(SECOND,@starttime,@endtime) AS VARCHAR(50)) + 'second')

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


            -- =================================================================
            -- CALCULATE AND DISPLAY TOTAL EXECUTION TIME
            -- =================================================================

            SET @TotalEndTime = SYSDATETIME()

            PRINT('Total Time taken to execute the query '+ CAST(DATEDIFF(SECOND,@TotalStartTime,@TotalEndTime) as varchar(50)) + ' second');

            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
            PRINT('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');


        END TRY


        -- =====================================================================
        -- ERROR HANDLING
        -- Display the error message, error number, and line number if a
        -- statement inside the TRY block fails.
        -- =====================================================================

        BEGIN CATCH

            PRINT('ERROR_MESSAGE' + error_message());

            PRINT('ERROR_NUMBER' + cast(error_number() as varchar(50)));

            PRINT('ERROR_LINE' + cast(error_line() as varchar(50)));

        END CATCH

    END;

GO


-- ============================================================================
-- EXECUTE THE BRONZE-LAYER LOADING PROCEDURE
-- ============================================================================

EXEC proc_load_bronze;
