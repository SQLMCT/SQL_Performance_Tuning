USE AdventureWorks2019
GO

--ProductID 870 returns 4,688 rows out of 121,317 total rows. 
EXEC sp_executesql
@stmt = N'SELECT * FROM Sales.SalesOrderDetail 
	WHERE ProductID = @ProductID',
@params = N'@ProductID int', 
	@ProductID = 870
GO

--ProductID 897 returns 2 rows out of 121,317 total rows.  
EXEC sp_executesql 
@stmt = N'SELECT * FROM Sales.SalesOrderDetail 
	WHERE ProductID = @ProductID',
@params = N'@ProductID int', 
	@ProductID = 897
GO


--Create SQL Plan Guide to force a RECOMPILE.
EXEC sp_create_plan_guide
@name = N'SalesOrders_ProductID_Recompile',
@stmt = N'SELECT * FROM Sales.SalesOrderDetail WHERE ProductID = @ProductID',
@type = N'SQL',
@module_or_batch = NULL,
@params = N'@ProductID int',
@hints = N'OPTION (RECOMPILE)'
GO

--To see a list of plan guides stored on the database
SELECT * FROM sys.plan_guides
GO

--Disable plan guide
--@operation – a control option; one of DROP, DROP ALL, DISABLE, DISABLE ALL, ENABLE, ENABLE ALL
--@name – name of the plan guide to control
EXEC sp_control_plan_guide N'DISABLE', N'SalesOrders_ProductID_Recompile'
GO