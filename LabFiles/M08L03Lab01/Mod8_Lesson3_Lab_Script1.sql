USE AdventureWorksPTO;	
GO

-- Start with a clean slate - disable Query Store and purge any accumulated data 
ALTER DATABASE AdventureWorksPTO SET QUERY_STORE = OFF;
GO
ALTER DATABASE AdventureWorksPTO SET QUERY_STORE CLEAR;	
GO

-- Enable Query Store using a configuration optimized for our demonstration
ALTER DATABASE AdventureWorksPTO
SET QUERY_STORE = ON ( 
	OPERATION_MODE = READ_WRITE,
	MAX_STORAGE_SIZE_MB = 512,			/* Demo value */
	INTERVAL_LENGTH_MINUTES = 1,		/* Demo value */	
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
	SIZE_BASED_CLEANUP_MODE = AUTO,
	QUERY_CAPTURE_MODE = ALL,			/* Demo value */
	DATA_FLUSH_INTERVAL_SECONDS = 900,	
	MAX_PLANS_PER_QUERY = 200,
	WAIT_STATS_CAPTURE_MODE = ON  
	);
GO	

/*****************************************************************************/

-- Create a stored procedure 
CREATE OR ALTER PROC dbo.GetOrdersByCustomer ( @LastName_partial NVARCHAR(20))
AS
BEGIN
    SELECT p.LastName, p.FirstName, h.AccountNumber, h.OrderDate, h.PurchaseOrderNumber, i.Name, d.OrderQty
    FROM Sales.SalesOrderHeader h
         INNER JOIN Sales.SalesOrderDetail d ON d.SalesOrderID = h.SalesOrderID
         INNER JOIN Production.Product i ON i.ProductID = d.ProductID
         INNER JOIN Sales.Customer c ON c.CustomerID = h.CustomerID
         INNER JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
    WHERE p.LastName LIKE @LastName_partial + N'%';
END
GO

-- Create some nonclustered indexes to support the query in the stored procedure
CREATE INDEX demo_SalesOrderId_inc ON Sales.SalesOrderDetail ( SalesOrderID )
INCLUDE ( ProductID, OrderQty );
GO

CREATE INDEX demo_PersonId ON Sales.Customer ( PersonID );
GO

CREATE INDEX demo_CustomerId_inc ON Sales.SalesOrderHeader ( CustomerID )
INCLUDE ( OrderDate, PurchaseOrderNumber, AccountNumber );
GO

/*****************************************************************************/

-- Execute the stored procedure using a parameter that returns a "typical" number
-- of rows so we know that the cached plan will work well for most parameter values
EXEC dbo.GetOrdersByCustomer @LastName_partial = N'D';
GO

/*
	To reduce the cost of executing the stored procedure *many* times over, we'll
	enable an option to discard result sets rather than printing them out.

		Right-click in window
		Select "Query Options..."
		Click on "Results" in the lefthand panel
		Enable the option to "Discard results after execution"


	Once that's done, execute the WHILE loop below to generate data for the Query 
	Store.  It will run for more than an hour during which time you will complete
	the lab using Script 2.  If you need additional time, you may execute this
	code again.
*/

-- Execute the stored proc many times using a random parameter value each time
DECLARE @counter INT = 0, @letter NVARCHAR(1);
WHILE (@counter <= 2500)
BEGIN
	SET @letter = CHAR(CAST(RAND() * 26 AS INT) + 65);
	EXEC dbo.GetOrdersByCustomer @LastName_partial = @letter;
	SET @counter += 1;
	WAITFOR DELAY '00:00:02';
END
GO 

/*
	Leaving this script running, open Script 2 and procede with the lab.
*/
