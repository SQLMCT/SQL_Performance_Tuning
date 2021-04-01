------------------------------------------------------------------------------------------
-- Demo 9 - Freeze Plan Guide
------------------------------------------------------------------------------------------

-- In this demo, we will create a plan guide from cache. This is also called "Plan Freezing."

-- Setup
USE AdventureWorks2016;
GO

SET NOCOUNT ON
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE
GO
IF EXISTS (SELECT 1 FROM sys.plan_guides WHERE name = 'getAddresses')
EXECUTE sp_control_plan_guide N'drop', 'getAddresses';
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = N'P' AND name = 'getRowsByStateProvinceID')
DROP PROCEDURE getRowsByStateProvinceID;
GO

CREATE PROCEDURE getRowsByStateProvinceID @stateProvinceID INT
AS
SELECT *
FROM Person.Address AS a
WHERE a.StateProvinceID = @stateProvinceID;
GO

-- Clear the cache
DBCC FREEPROCCACHE
GO

-- Check SSMS option "Actual Execution Plan"

-- Execute the two following sproc calls one at a time
SET STATISTICS TIME ON;
GO
EXECUTE getRowsByStateProvinceID 119;
GO
EXECUTE getRowsByStateProvinceID 9;
GO
SET STATISTICS TIME OFF;
GO

-- Compare the SQL execution times of the two and notice that 
-- 9 is much more expensive than 119

-- Clear the cache
DBCC FREEPROCCACHE
GO

-- And notice the difference if we execute with 9 first
SET STATISTICS TIME ON;
GO
EXECUTE getRowsByStateProvinceID 9;
GO
EXECUTE getRowsByStateProvinceID 119;
GO
SET STATISTICS TIME OFF;
GO

/*
So whether you get a clustered index scan, or a seek and lookup
depends on which parameter gets executed first. This can be a bad situation
sometimes. If most times 9 is executed, but 119 gets run first, if this is a
larger table than we have, this can create a bad performance situation.

In order to prevent this, let's create a plan guide from the one in cache now.

Step through these steps to create the plan guide:
*/

-- Option 1, in two steps:
-- First, get the plan that is cached:
SELECT qs.plan_handle, qs.statement_start_offset, t.text 
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS qp
WHERE text LIKE N'%getRowsByStateProvinceID @sta%';
GO
-- Now use the plan handle, and statement start offset from the line that
-- begins "CREATE PROCEDURE getRowsByStateProvinceID" for the next step
-- this step freezes the plan in cache:
EXECUTE sp_create_plan_guide_from_handle 
	@name = N'getAddresses'
	,@plan_handle = 0x05000C0047AC4E41304AE2F00402000001000000000000000000000000000000000000000000000000000000 -- change this to the actual plan handle from cache
	,@statement_start_offset = 136 -- change this to the actual offset from cache
GO

--drop plan guide and recreate in one step below
EXEC sp_control_plan_guide N'DROP', N'getAddresses';

-- Option 2, all in one step:
DECLARE @plan_handle varbinary(64);
DECLARE @offset int;
SELECT @plan_handle = plan_handle, @offset = qs.statement_start_offset
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS qp
WHERE text LIKE N'%getRowsByStateProvinceID%';

EXECUTE sp_create_plan_guide_from_handle 
    @name =  N'getAddresses'
    ,@plan_handle = @plan_handle
    ,@statement_start_offset = @offset;
GO

-- Now clear the cache, and watch what happens if we execute with 119 first:
DBCC FREEPROCCACHE
GO

-- Execute these and look at the query plan:
SET STATISTICS TIME ON;
GO
EXECUTE getRowsByStateProvinceID 119;
GO
EXECUTE getRowsByStateProvinceID 9;
GO
SET STATISTICS TIME OFF;
GO

-- So now, we always get the plan optimized for the large number of rows.
-- Look at the plan guides we have registered:
SELECT * FROM sys.plan_guides
WHERE scope_batch LIKE N'%getRowsByStateProvinceID%';
GO

-- Cleanup
IF EXISTS (SELECT 1 FROM sys.plan_guides WHERE name = 'getAddresses')
EXECUTE sp_control_plan_guide N'drop', 'getAddresses';
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