/*
	After enabling Query Store, creating a stored procedure and starting a looping
	execution of the stored procedure, continue with the lab here.
*/

SET NOCOUNT ON;

USE AdventureWorksPTO;
GO

/*
	The WHILE loop in Script 1 will execute for at least an hour.  You may restart
	it if you need more time to complete the lab.

	In the Object Explorer window, drill down to the AdventureWorksPTO database
	then open the Query Store folder.  Open the Top Resource Consuming Queries 
	report.
	
	In the bar chart, the top query by duration should be the T-SQL from the 
	stored procedure.  Move your cursor over the bar to review the data available
	in the tool tip:  query id, object_id and name, total duration, execution count,
	plan count and the SQL statement

	Then do the same in the Plan Summary window - move your cursor over one of
	colored dots in the graph and review the data available in the tool tip:
	plan id, execution type, is forcing in effect, the interval represented by
	the dot, execution count (per plan, per interval) and the range of statistics
	for the currently selected metric (Duration, by default).

	Note that the query plan includes Merge and Hash Match joins - a sign that 
	it was created to support a higher row count query.

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	In this exercise we'll look at the effect of altering vs dropping then 
	recreating a stored procedure.  

	When using Query Store it's important that you ALTER an object rather than 
	DROP/CREATE it when you need to make modifications as the latter results in 
	the assignment of a new object_id and essentially orphans the historic data
	collected against the original object_id.	

	First we'll ALTER the stored procedure changing the size of the paramter and
	adding a carriage return to the SELECT clause...
*/

CREATE OR ALTER PROC dbo.GetOrdersByCustomer ( @LastName_partial NVARCHAR(40))
AS
BEGIN
    SELECT p.LastName, p.FirstName, h.AccountNumber, h.OrderDate, h.PurchaseOrderNumber, 
		   i.Name, d.OrderQty
    FROM Sales.SalesOrderHeader h
         INNER JOIN Sales.SalesOrderDetail d ON d.SalesOrderID = h.SalesOrderID
         INNER JOIN Production.Product i ON i.ProductID = d.ProductID
         INNER JOIN Sales.Customer c ON c.CustomerID = h.CustomerID
         INNER JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
    WHERE p.LastName LIKE @LastName_partial + N'%';
END
GO

-- Now execute the stored procedure 10 times to generate data for the Query Store
EXEC dbo.GetOrdersByCustomer @LastName_partial = N'J';
GO 10 

-- Check the catalog views
SELECT t.query_text_id, q.context_settings_id, q.query_id, q.object_id,
    OBJECT_NAME(q.object_id) AS object_name, t.query_sql_text
FROM sys.query_store_query_text t
     INNER JOIN sys.query_store_query q ON q.query_text_id = t.query_text_id
WHERE t.query_sql_text LIKE N'%WHERE p.LastName LIKE @LastName_partial + N%' AND q.object_id <> 0;
GO

/*
	The changes to the SQL text have caused a new row to be written in sys.query_store_query_text
	which, in turn, resulted in a new entry in sys.query_store_query (and the gen-
	eration of a new query_id), but the object_id remained the same.

	If you click on the Refresh button above the bar chart in the Top Resource
	Consuming Queries report you'll note that the two left left-most bars cor-
	respond to the 2 query_id values seen above.  There's a discontinuity in
	the Query Store data, but we can associate the before and after data using
	the object_id.

	Next, we'll drop and recreate the stored procedure without making any changes
	to its text.
*/

DROP PROC dbo.GetOrdersByCustomer;
GO

CREATE PROC dbo.GetOrdersByCustomer ( @LastName_partial NVARCHAR(40))
AS
BEGIN
    SELECT p.LastName, p.FirstName, h.AccountNumber, h.OrderDate, h.PurchaseOrderNumber, 
		   i.Name, d.OrderQty
    FROM Sales.SalesOrderHeader h
         INNER JOIN Sales.SalesOrderDetail d ON d.SalesOrderID = h.SalesOrderID
         INNER JOIN Production.Product i ON i.ProductID = d.ProductID
         INNER JOIN Sales.Customer c ON c.CustomerID = h.CustomerID
         INNER JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
    WHERE p.LastName LIKE @LastName_partial + N'%';
END
GO

-- Execute the stored procedure again to generate data for the Query Store
EXEC dbo.GetOrdersByCustomer @LastName_partial = N'J';
GO 10 

-- Check the catalog views again
SELECT t.query_text_id, q.context_settings_id, q.query_id, q.object_id,
    OBJECT_NAME(q.object_id) AS object_name, t.query_sql_text
FROM sys.query_store_query_text t
     INNER JOIN sys.query_store_query q ON q.query_text_id = t.query_text_id
WHERE t.query_sql_text LIKE N'%WHERE p.LastName LIKE @LastName_partial + N%' AND q.object_id <> 0;
GO

/*
	The query now returns 3 rows.  Looking at row 3...

	Since the SQL text defining the stored procedure didn't change, the pre-existing,
	matching
	entry in sys.query_store_query_text could be reused (Query Store uses a normalized 
	design to store data efficiently), but the assignment of both a new query_id 
	and new object_id have effectively orphaned the historical data already collected 
	for the stored procedure.  The original object_id can no longer be resolved 
	to an object name.

	To reiterate - object modifications should be done using ALTER to allow easier
	tracking of historic data.
	
	Refresh the bar chart in the Top Resource Consuming Queries report again and
	note that there are now 3 prominent bars (each for one of the unique query_ids 
	seen in the result set from the above query).

	Looking at the plan summary data for each you'll note that the plan execution
	metrics (dots) cover non-overlapping points in time.  

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	
	In the next exercise we're going to explore troubleshooting a parameter snif-
	ing issue by caching a query plan optimized for a low row count query.

*/

-- Use the sp_recompile system stored proc to invalidate the cached plan then 
-- immediately execute the proc using a parameter that returns an unusually low 
-- row count to cache a plan that will perform poorly for most parameter values 
EXEC sp_recompile @objname = N'dbo.GetOrdersByCustomer';
EXEC dbo.GetOrdersByCustomer @LastName_partial = N'U';
GO

/*
	Refresh the bar chart display in the Top Resource Consuming Queries report.  
	
	You should now see dots of two colors, each associated with a separate  
	query plan.  One is suited to high row counts and the other, more recently
	generated plan, to low row counts. 


	Open the Regressed Queries report then make a few configuration changes...
	
	Set the Metric to Logical Reads and set the Statistic to Avg.  Then update 
	the Configuration settings. Under Time Interval, set Recent to 5 min and 
	History to 12 hours

	You should see one wide bar in the queries panel associate with 2 plans - dots 
	of 2 colors that won't necessarily match those in the Top Resource Consuming Queries report.

	Click on each of the dots and review the associated query plans.  The older
	plan has the Merge and Hash Match joins we noted earlier (suggesting a high 
	row count query), and the more recent plan has the Nested Join operators 
	typical of lower row count queries.

	The test query and it's plans should also be evident in the Queries With High
	Variation report.  Optionally open and review this report.  Close it when 
	you're done exploring.

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	For our next exercise we'll see how to compare 2 query plans in the Query 
	Store reports.

	In the Regressed Queries report, use the Shift key to multi-select the two
	plans (differently colored dots) you which to compare, then click on the 
	Compare Plans button in the toolbar (below and to the right of
	the Configure button.  A new query window will open displaying the two query 
	plans and their Properties windows.  
	
	Properties differences are highlighted with a "not equal" sign.  In the graphical
	plans, related blocks of operators will be highlighted in the same colors.

	When you are done reviewing the data, close both the the properties window
	and and the window displaying the query	plans.

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	For the next exercise we'll Force the use of a query plan.

	In the Regressed Queries report, click on a dot associated with the 
	plan you wish to force (the one with the Merge Joins and lower Logical Reads)
	then click the Force Plan button.  Confirm your choice when prompted.  A check 
	mark will appear over the dots associated with the forced plan.

	Click on button that opens the Tracked Queries
	report.  Configure the display to show the average logical reads during the 
	last hour.

	Note that it's easily to see whether a query plan has been forced and
	whether forcing is currently in effect - just look for those check marks.

	Disable one the the indexes being used by the forced plan.
*/

ALTER INDEX demo_SalesOrderId_inc ON Sales.SalesOrderDetail DISABLE;
GO

/*
	Return to the Tracked Queries report and refresh the display.  

	When the index was dropped, the forced plan could no longer be used.  The 
	Optimizer handed this gracefully.  It simply compiled another execution
	plan and execution continued.

	Open the Queries With Forced Plans report and configure the Time Interval 
	to show the last 30 min of data. 
	
	Note that the query is still displayed here, even though the forced plan 
	isn't currently in use.  Scroll to the right to see why forcing failed:  
	NO_INDEX

	Close the Queries With Forced Plans report.

	You can also retrieve a reason directly from sys.query_store_plan...
*/

-- Execute this query in another query window
SELECT q.query_id, p.plan_id, p.force_failure_count, p.last_force_failure_reason_desc,
    CAST(p.query_plan AS XML) AS XMLPlan_forced
FROM sys.query_store_plan p
     INNER JOIN sys.query_store_query q ON q.query_id = p.query_id
WHERE p.is_forced_plan = 1 AND q.object_id = OBJECT_ID('dbo.GetOrdersByCustomer');
GO

-- Rebuild the disabled index to make it available again
ALTER INDEX demo_SalesOrderId_inc ON Sales.SalesOrderDetail REBUILD;
GO

/*
	Refresh the plan summary data in Tracked Queries report and note
	that the Optimizer automatically resumed using the forced plan once the 
	necessary index became available.

	Unforce the plan by clicking on a dot associated with the forced plan then 
	clicking on the Unforce Plan button.  Confirm your choice.

	Close the Tracked Queries report.

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	In this exercise we'll look at the impact of executing the same SQL
	statement in differing execution contexts.  Here we'll use a non-default ANSI 
	setting.

	Note that doing so is deprecated.
*/

SET ANSI_DEFAULTS OFF;
GO

EXEC dbo.GetOrdersByCustomer @LastName_partial = N'J';
GO 10

-- Reset to the default value
SET ANSI_DEFAULTS ON; 
GO

-- What's in the catalog views
SELECT t.query_text_id, q.context_settings_id, q.query_id, q.object_id, t.query_sql_text
FROM sys.query_store_query_text t
     INNER JOIN sys.query_store_query q ON q.query_text_id = t.query_text_id
WHERE t.query_sql_text LIKE N'%WHERE p.LastName LIKE @LastName_partial + N%' AND q.object_id <> 0;
GO

/*
	This query now returns 4 rows.  Note that the last 2 have the same query_text_id
	value, but differing context_settings_id values - which results in yet another 
	query_id.  

	If desired, we could link the Query Store data for these two query_ids using
	their common object_id (as we could when the stored procedure was modified 
	using ALTER).

	Optionally open the Tracked Queries report and plug in most recent query_id 
	to see its execution statistics.  Close the report when you're done exploring.

	Close both Regressed Queries report and Top Resource Consuming Queries report.
	
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------

	For the last Exerise we'll explore the use of Query Store data for offline
	tuning and troubleshooting.  This is possible because the data is persisted
	to tables within the database which is included in both database backups and
	database clones.

	We'll use the DBCC CLONEDATABASE command to create a clone then browse the 
	Query Store reports in the clone.

	Syntax:  DBCC CLONEDATABASE (source_database_name, target_database_name) [WITH [NO_STATISTICS][, NO_QUERYSTORE]]
	https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-clonedatabase-transact-sql?view=sql-server-ver15
	
	Generate a schema-only clone of AdventureWorksPTO...
*/
USE MASTER
go
DBCC CLONEDATABASE(AdventureWorksPTO, AW_Clone);
GO

/*
	In the Messages tab:

		Database cloning for 'AdventureWorksPTO' has started with target as 'AW_Clone'.
		Database cloning for 'AdventureWorksPTO' has finished. Cloned database is 'AW_Clone'.
		Database 'AW_Clone' is a cloned database. This database should be used for diagnostic purposes only and is not supported for use in a production environment.
		DBCC execution completed. If DBCC printed error messages, contact your system administrator.

	Refresh the Databases view in Object Explorer, then drill down to and explore 
	the Query Store reports in 
	the AW_Clone database.  Note that both the database and Query Store are
	in Read-Only mode.
	
	When you're done, drop the cloned database.
*/

-- Clean up
USE MASTER
go
DROP DATABASE AW_Clone;
GO

/*****************************************************************************/

/*
	Close any reports that remain open

	Return to Script 1 and stop its execution (if it's still running)
*/

-- Clean up
USE AdventureWorksPTO;
GO
DROP INDEX Sales.SalesOrderHeader.demo_CustomerId_inc;
DROP INDEX Sales.Customer.demo_PersonId;
DROP INDEX Sales.SalesOrderDetail.demo_SalesOrderId_inc;
GO

DROP PROCEDURE dbo.GetOrdersByCustomer;
GO

