SET NOCOUNT ON;

USE AdventureWorks2016;
GO

/*
	-- Start with a clean slate
	ALTER DATABASE AdventureWorks2016 SET QUERY_STORE = OFF;
	ALTER DATABASE AdventureWorks2016 SET QUERY_STORE CLEAR;
	DROP INDEX IF EXISTS demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail;
	DROP INDEX IF EXISTS demo_ProductID__UnitPrice ON Sales.SalesOrderDetail;
	GO
*/

-- Enable with default settings
ALTER DATABASE AdventureWorks2016
SET QUERY_STORE = ON ( 
	OPERATION_MODE = READ_WRITE,
	MAX_STORAGE_SIZE_MB = 100,			/* demo value */
	INTERVAL_LENGTH_MINUTES = 15,		/* demo value */	
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
	SIZE_BASED_CLEANUP_MODE = AUTO,
	QUERY_CAPTURE_MODE = ALL,			/* demo value */
	DATA_FLUSH_INTERVAL_SECONDS = 900,	
	MAX_PLANS_PER_QUERY = 200,
	WAIT_STATS_CAPTURE_MODE = ON  
	);
GO	

-- Create a stored proc
CREATE OR ALTER PROCEDURE dbo.getProductInfo
    @ProductID INT
WITH RECOMPILE
AS
    SET NOCOUNT ON;
    SELECT   ProductID, OrderQty, UnitPrice
    FROM     Sales.SalesOrderDetail
    WHERE    ProductID = @ProductID;
GO

/*****************************************************************************/

/* 
	Check whether any bogus demo indexes currently exist - drop them if they do

		EXEC sys.sp_helpindex 'sales.salesorderdetail';

	For this query window, use option to skip display of results when code runs
		Right-click in window
		Query Options
		Results
		Discard results after execution
*/

-- Generate some interesting data for Query Store
-- Allow script to run for some time prior to customer demo
DECLARE @counter INT = 1, @subcounter INT = 1, @exCounter TINYINT = 1;
WHILE (@counter <= 25000)
BEGIN
	BEGIN
	-- Run the stored procedure with parameters that will return 
	-- a range of rows
		IF @exCounter = 1
			EXECUTE dbo.getProductInfo 870	-- 4688 Rows
			EXECUTE dbo.getProductInfo 897	-- 2 Rows
			EXECUTE dbo.getProductInfo 945	-- 257 Rows
			EXECUTE dbo.getProductInfo 768	-- 441 Rows
		IF @exCounter = 2
			EXECUTE dbo.getProductInfo 897	-- 2 Rows
			EXECUTE dbo.getProductInfo 945	-- 257 Rows
			EXECUTE dbo.getProductInfo 768	-- 441 Rows
			EXECUTE dbo.getProductInfo 870	-- 4688 Rows
		IF @excounter >= 3
			SET @excounter += 1;
		ELSE 
			SET @excounter = 1 
		END
	
-- Every so often, change up the indexes so different plans are generated
	IF @counter % 5 = 0
	BEGIN
		IF @subcounter = 1
			CREATE NONCLUSTERED INDEX demo_ProductID__UnitPrice ON Sales.SalesOrderDetail (ProductID) INCLUDE (UnitPrice);
		
		IF @subcounter = 2
			DROP INDEX IF EXISTS demo_ProductID__UnitPrice ON Sales.SalesOrderDetail;
		
		IF @subcounter = 3
			CREATE NONCLUSTERED INDEX demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail (ProductID) INCLUDE (UnitPrice, OrderQty);
			
		IF @subcounter = 4
			DROP INDEX IF EXISTS demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail;
		
		IF @subcounter < 4
			SET @subcounter += 1;
		ELSE 
			SET @subcounter = 1;
	END
	
	SET @counter += 1;
	
	WAITFOR DELAY '00:00:02';
	    
END
GO

/*****************************************************************************/

-- Check again for any leftover demo indexes - delete any that are still there
EXEC sys.sp_helpindex 'sales.salesorderdetail';


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/
