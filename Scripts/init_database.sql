--=================================
/* WARNING: This script permanently deletes the existing Data_Warehouse database
 and all its data if it exists. Ensure you have backups and are connected
 to the correct SQL Server instance before executing this script.
 This script is intended for development and testing environments only.*/
--=================================
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--Switching to the master database
USE MASTER ;
GO 
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Check whether the database exists and drop it if present
IF DB_ID('Data_Warehouse') is not null 
BEGIN 
	DECLARE @STARTTIME DATETIME2
	,@ENDTIME DATETIME2
	 SET @STARTTIME = SYSDATETIME();
	-- Disconnect active sessions and roll back uncommitted transactions
	ALTER DATABASE Data_Warehouse 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
	-- Drop the existing database
	DROP DATABASE Data_Warehouse;
	SET @ENDTIME = SYSDATETIME();
		-- Calculate and display the database destruction time
	PRINT ('Database Destruction time:'+ CAST(Datediff(second,@STARTTIME ,@ENDTIME) AS VARCHAR(MAX))+'seconds');
END
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
GO
-- Create the Data_Warehouse database
CREATE DATABASE Data_Warehouse;
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
GO
USE Data_Warehouse;
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Create the Bronze, Silver, and Gold schemas for the medallion architecture
GO
CREATE SCHEMA bronze ;
GO 
CREATE SCHEMA silver ;
GO 
CREATE SCHEMA gold ;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
GO
PRINT('Schema created using medalian datawarehouse (Bronze,Silver and Gold)');
GO
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

