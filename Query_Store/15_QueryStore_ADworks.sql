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
DECLARE @counter INT = 1, @subcounter INT = 1;
WHILE (@counter <= 25000)
BEGIN
	-- Run the stored procedure with parameters that will return a range of rows
	EXECUTE dbo.getProductInfo 870;	-- 4688
	EXECUTE dbo.getProductInfo 777;	--  242
	EXECUTE dbo.getProductInfo 942;	--    5
	EXECUTE dbo.getProductInfo 768;	--  441

	DECLARE @product_id INT, @counter2 INT = 1;
	WHILE (@counter2 <= 5)
	BEGIN
		SET @product_id = ROUND(( ( 707 - 999 - 1 ) * RAND() + 707 ), 0);
		EXEC dbo.getProductInfo @product_id;
		SET @counter2 += 1;
	END
	
	-- Every so often, change up the indexes so different plans are generated
	IF @counter % 250 = 0
	BEGIN
		IF @subcounter = 1
			CREATE NONCLUSTERED INDEX demo_ProductID__UnitPrice ON Sales.SalesOrderDetail ( ProductID ) INCLUDE (UnitPrice);

		IF @subcounter = 2
			CREATE NONCLUSTERED INDEX demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail ( ProductID ) INCLUDE ( UnitPrice, OrderQty );

		IF @subcounter = 3
			DROP INDEX IF EXISTS demo_ProductID__UnitPrice_OrderQty ON Sales.SalesOrderDetail;

		IF @subcounter = 4
			DROP INDEX IF EXISTS demo_ProductID__UnitPrice ON Sales.SalesOrderDetail;

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



