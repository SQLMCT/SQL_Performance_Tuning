------------------------------------------------------------------------------------------
-- Demo 8 - Plan Guide
------------------------------------------------------------------------------------------
USE AdventureWorks2016
GO

SET NOCOUNT ON
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE
GO

-- Setup
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Sales.GetSalesOrderByCountry') AND type in (N'P'))
DROP PROCEDURE Sales.GetSalesOrderByCountry;
GO
CREATE PROCEDURE Sales.GetSalesOrderByCountry @Country NVARCHAR(60)
AS
BEGIN
	SELECT *
        FROM Sales.SalesOrderHeader h,
        Sales.Customer c,
        Sales.SalesTerritory t
        WHERE h.CustomerID = c.CustomerID 
            AND c.TerritoryID = t.TerritoryID 
            AND CountryRegionCode = @Country
END
GO

DBCC FREEPROCCACHE
-- Run the stored proc and examine the query plan
EXECUTE Sales.GetSalesOrderByCountry 'DE';
GO

-- Take note of the actual vs. estimated rows
-- Why is there such a large discrepency?
EXECUTE Sales.GetSalesOrderByCountry 'US';
GO

-- Next, create the plan guide and then rerun the test
EXECUTE sp_create_plan_guide @name = N'Guide1', @stmt = N'SELECT *
        FROM Sales.SalesOrderHeader h,
        Sales.Customer c,
        Sales.SalesTerritory t
        WHERE h.CustomerID = c.CustomerID 
            AND c.TerritoryID = t.TerritoryID 
            AND CountryRegionCode = @Country'
, @type = N'OBJECT'
, @module_or_batch = N'Sales.GetSalesOrderByCountry'
, @params = NULL
, @hints = N'OPTION (OPTIMIZE FOR (@Country = N''US''))';
GO

-- To verify that the plan guide is being matched to a query, configure the below xEvent trace:
CREATE EVENT SESSION [PlanGuide] ON SERVER 
ADD EVENT sqlserver.plan_guide_successful(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.plan_guide_unsuccessful(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.sql_text)) 
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- Now start it and Watch Live data coming from it
ALTER EVENT SESSION [PlanGuide] ON SERVER STATE = start;
GO

-- Run the stored proc and examine the query plan
EXECUTE Sales.GetSalesOrderByCountry 'DE';
GO

-- take note of the actual vs. estimated rows
-- is the estimate better?
EXECUTE Sales.GetSalesOrderByCountry 'US';
GO

-- Cleanup
EXECUTE sp_control_plan_guide N'DROP', N'Guide1';
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Sales.GetSalesOrderByCountry') AND type in (N'P'))
DROP PROCEDURE Sales.GetSalesOrderByCountry;
GO



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