-- Execute query to connect to AdventureWorksPTO
USE AdventureWorksPTO
GO

-- Create test tables and stored proedures

if  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SalesOrderHeader_pto]') AND type IN (N'U'))
DROP TABLE [dbo].[SalesOrderHeader_pto]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SalesOrderdetail_pto]') AND type IN (N'U'))
DROP TABLE [dbo].[SalesOrderdetail_pto]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customer_pto]') AND type IN (N'U'))
DROP TABLE [dbo].[customer_pto]
GO
SELECT * INTO SalesOrderHeader_pto
FROM Sales.SalesOrderHeader
GO
SELECT * INTO SalesOrderdetail_pto
FROM Sales.SalesOrderDetail
GO
SELECT * INTO Customer_pto
FROM Sales.Customer
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcCount_Country]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].ProcCount_Country
GO
CREATE PROCEDURE ProcCount_Country
(@CountryRegionCode char(2) = 'GB')
AS
BEGIN
	SELECT    COUNT (SOH.ShipToAddressID) 
			, CountryRegionCode
	FROM Sales.Customer C 
	INNER JOIN Sales.SalesTerritory ST 
	ON ST.TerritoryID = C.TerritoryID 
	INNER JOIN Sales.SalesOrderHeader SOH 
	ON SOH.TerritoryID = C.TerritoryID 
	WHERE  ST.CountryRegionCode  =@CountryRegionCode
	GROUP BY CountryRegionCode
END 
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Product]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].Proc_Product
GO
CREATE PROCEDURE Proc_Product
(@productid int = 1)
AS
BEGIN
	SELECT * 
	FROM Production.Product
	WHERE ProductID=@productid
END 
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[perf_proc1]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[perf_proc1]
GO

CREATE PROCEDURE perf_proc1 
AS
BEGIN
	SELECT * FROM Production.Product
	  WHERE ProductID=1

	SELECT a.CustomerID, --customertype,
	   OrderDate, ShipDate, ProductID,
	   OrderQty, UnitPrice, UnitPriceDiscount
	FROM dbo.Customer_pto a
		JOIN dbo.SalesOrderHeader_pto b ON a.CustomerID=b.CustomerID
		JOIN dbo.SalesOrderdetail_pto c ON b.SalesOrderID= c.SalesOrderID
	WHERE ShipDate between '07/01/2001' AND '07/31/2001'
END
GO

-- Execute:
DBCC freeproccache
GO
EXEC perf_proc1
GO
EXEC Proc_Product
GO
EXEC ProcCount_Country
GO

-- identifying expensive queries based on I/O :

-- Stored Procedures by logical reads average 
SELECT TOP 30
	CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
	,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME]  
	,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]
	,cached_time
	,last_execution_time
	,execution_count
	,total_worker_time / execution_count AS AVG_CPU
	,total_elapsed_time / execution_count AS AVG_ELAPSED
	,total_logical_reads / execution_count AS AVG_LOGICAL_READS
	,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
	,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
	,*
FROM sys.dm_exec_procedure_stats  
WHERE  database_id = DB_ID('AdventureWorksPTO')  
ORDER BY AVG_LOGICAL_READS DESC
GO 

-- Queries with highest total IO (physical reads + logical writes + logical reads)
SELECT TOP 20 
	last_execution_time
	, (total_physical_reads + total_logical_writes + total_logical_reads) AS [Total IO]
	, text
	, qp.query_plan
	, statement_start_offset
	, statement_end_offset
	, sql_handle
	, plan_handle 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st 
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp 
WHERE text like '%CREATE PROCEDURE%'
ORDER BY text;
GO

-- Stored Procedures statements
SELECT TOP 20 
	last_execution_time
	, (total_physical_reads + total_logical_writes + total_logical_reads) AS [Total IO]
	, text
	,substring(text, statement_start_offset/2,
		(CASE WHEN statement_end_offset=-1 THEN len(convert(NVARCHAR(MAX),text))*2
		 ElSE statement_end_offset
		 END -statement_start_offset)/2) as statement_text
	, qp.query_plan
	, statement_start_offset
	, statement_end_offset
	, sql_handle
	, plan_handle 
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st 
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp 
WHERE text like '%CREATE PROCEDURE%'
ORDER BY text;
GO

