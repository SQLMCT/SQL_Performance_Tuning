--Adaptive Joins
SET NOCOUNT ON;

USE WideWorldImportersDW;

/*
	To use Adaptive Joins for *row mode* processing you need to be 
	using SQL Server 2019 (version 15) and your database needs to be
	at compatibility level 150. 
	Check your configuration settings
*/

SELECT SERVERPROPERTY('ProductMajorVersion') AS SQL_version, 
DB_NAME() AS database_name, compatibility_level
FROM sys.databases
WHERE database_id = DB_ID();

/*
	If you need to, run the ALTER DATABASE command below to 
	bump up the compatibility level of your database.
*/

ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150;
GO

/*	The ability to use BATCH_MODE_ADAPTIVE_JOINS is enabled by default.  
	You can toggle it off and on using a database-scoped configuration 
	setting:

	ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ADAPTIVE_JOINS = { ON | OFF};

	And you can selectively disable it at the query level with the 
	USE HINT syntax:
	
	OPTION ( USE HINT ( 'DISABLE_BATCH_MODE_ADAPTIVE_JOINS' ) );
*/


/*	Check to confirm that BATCH_MODE_ADAPTIVE_JOINS is enabled.
	This would be configuration_id = 9 */

SELECT * FROM sys.database_scoped_configurations;	
GO

/*Enable it, if necessary */
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ADAPTIVE_JOINS = ON;
GO

/*
-- SQL Server 2017
ALTER DATABASE SCOPED CONFIGURATION SET DISABLE_BATCH_MODE_ADAPTIVE_JOINS = OFF | ON;

-- Azure SQL Database, SQL Server 2019 and higher
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ADAPTIVE_JOINS = ON | OFF;
*/

/*****************************************************************************/

-- Create a stored proc for testing
CREATE OR ALTER PROC dbo.GatherOrderData 
( @order_key BIGINT, @quantity INT )
AS
BEGIN
    SELECT fo.[Order Key], si.[Lead Time Days], fo.Quantity
    FROM Fact.[Order] AS fo
         INNER JOIN Dimension.[Stock Item] AS si 
		 ON fo.[Stock Item Key] = si.[Stock Item Key]
    WHERE fo.Quantity = @quantity AND fo.[Order Key] <= @order_key;
END
GO

/*
	Enable the option to Include Actual Execution Plan (Ctrl+M)
*/

/*--Clear the plan cache so we're starting with a clean slate then 
	execute the procedure using parameters that will return 
	differing numbers of rows */
	
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

/*-- Execute the proc with parameters that return 
	different-sized result sets */

EXEC dbo.GatherOrderData @order_key = 10000, @quantity = 360;
GO
EXEC dbo.GatherOrderData @order_key = 500000, @quantity = 360;
GO 

/* Clean-up */ 
DROP PROC dbo.GatherOrderData;
GO

/*
	The first result set contains 8 rows, the second has 206.
	Now, compare the query plans for the two executions...

	At first glance, the plans look identical - and a little weird 
	since there	are 3 inputs to the new Adaptive Join operator.  
	Joins are always between two inputs, so what's going on here?

	What's happened is that the Optimizer has generated an "adaptive" plan
	that allows query execution to go either of two directions at runtime. 
	
		* use a Hash Join for higher row count queries 
		* use a Nested Loops join for lower row count queries

	Which is used is determined by a query-dependent threshold row count
	that you can find in the properties of the Adaptive Join operator 
	(67.8975 rows in this example).  

	Below this value, use of a Nested Loop join is less costly.  
	Above it, a Hash Join is more efficient.

	The Adaptive Join is part of the cached plan so all subsequent 
	executions of the SQL statments can be optimized using the same
	threshold at runtime.  

	Understanding Adaptive Joins
	https://docs.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver15#adaptive
*/


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