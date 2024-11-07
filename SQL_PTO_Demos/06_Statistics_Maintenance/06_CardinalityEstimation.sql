/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/

--	=====================================================================
--	Demo 1
--	QO estimated number of rows calculation
--  Show where the estimated rows come from
--	=====================================================================

USE AdventureWorksPTO;
GO

-- Open a second tab an execute:
DBCC SHOW_STATISTICS ('Sales.SalesOrderDetail', PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID);
-- go back to this query tab

-- Click on Include Actual Execution Plan

-- Execute the following query
-- look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- It is exact estimation
-- switch to the 2nd tab and point to the Statistics at the Histogram 
-- Show column EQ_ROWS at the row with the value '44079'

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 44079

-- Execute the following query
-- look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- It is NOT an exact estimation
-- look the number of rows estimated at the CLUSTERED INDEX SEEK OPERATOR. 
-- Switch to the 2nd tab and point to the Statistics at the Histogram 
-- This time, there is no entry in the histogram matching the PREDICATE
-- so the estimate comes from the column AVG_RANGE_ROWS for the range that contains the search value

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 43901


-- See the behavior when variables are used
-- Execute the next batch
-- The batch executes the same SELECT, but the second one uses a variable to set the search value
-- Note that in this cse both queries get the same execution plan, 
-- For both plans, look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- You get different estimated rows, even when both are looking for the SalesOrderID=44079. Why?

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 44079

declare @orderid int
set @orderid = 44079

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = @orderid
	
GO

-- Answer:	the Query Optimizer does not know the value of the variable at compilation time
--			so it does not use the histogram but density
--			estimated rows = number of rows in the table (from the header) * density (from density vector)
--			estimated rows = 121317 * 3.178134E-05
--			estimated rows = 3.85562


-- If the estimated rows are too far away from actual rows, you can get a bad plan or memory grants can be inadequate
-- How to solve the problem?
-- Remark this is not an issue about outdated statistics
-- By using OPTION (RECOMPILE) you force the QO to compile the query at execution time and at that point 
-- the value for @orderid is known
-- Execute the next batch
-- The batch executes the same SELECT, but the second one uses a hint to recompile at runtime

DBCC FREEPROCCACHE

declare @orderid int
set @orderid = 44079

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = @orderid
		
SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = @orderid
OPTION (RECOMPILE)
	
GO

-- See the behavior when the search value is out of the histogram
-- Execute the next batch
-- For both plans, look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- the QO always assumes that data exist and estimates that 1 rows will be retorned
-- Check the DBCC SHOW_STATISTICS output and confirm that the highest value is 75123

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 97014
GO

-- See the behavior when no equiality predicates
-- Execute the next batch
-- Note that the 2 plans look the same, 
-- but the cost is actually different (SHOW Cost of the both plans)
-- For both plans, look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- You get different estimated rows, even when both are looking for the SalesOrderID>74869
-- For the second case, the estimated number rows is too far from the acutal number rows
-- We now know that the Query Optimizer does not know the value of the variable at compilation time
-- so it does not use the histogram. Where does the estimated rows come from?

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > 74869
	
declare @orderid int
set @orderid = 74869

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 

GO

-- Answer:	In this case
--			estimated rows = 30% of total rows in the table 
--			estimated rows = 121317 * 0.3
--			estimated rows = 36395.1
--			select  121317 * 0.3
--			The cardinality of the filter is equal to the cardinality 
--			of its left child multiplied by the probability of the 
--			comparison being true, which is always 30 percent 

-- This rule can cause problems if use search values that return different number of rows
-- Execute the next batch
-- Note that the 2 plans look the same and have the same cost (SHOW Cost of the both plans)
-- even when the first query returns the whole table 
-- and the second query returns no row as the the highest SalesOrderID is lower than 100000
-- For both plans, look the number of actual and estimated rows at the CLUSTERED INDEX SEEK OPERATOR. 
-- they both estimate the same (30% of the rows of the table)
-- How can you fix this?

DBCC FREEPROCCACHE

declare @orderid int
set @orderid = 1

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 
	
set @orderid = 100000

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 

GO

-- you can use OPTION (RECOMPILE)
-- By using OPTION (RECOMPILE) you force the QO to compile the queries at execution time and at that point 
-- the value for @orderid is known
-- Execute the next batch
-- Note that now the 2 plans are different and have different cost (SHOW Cost of the both plans)
-- The new plan adjust better to the reality 

DBCC FREEPROCCACHE

declare @orderid int
set @orderid = 1

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 
OPTION (RECOMPILE)
	
set @orderid = 100000

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 
OPTION (RECOMPILE)

GO

-- See the behavior when using agregations
-- Execute the next batch
-- Look the number of actual and estimated rows at the CLUSTERED INDEX SCAN OPERATOR. 
-- The estimation is exact.
-- The CE gets the value from the statistics as they indicate the number of different values for the column

DBCC FREEPROCCACHE

SELECT SalesOrderID, AVG(OrderQty*UnitPrice) avg_order_total  
FROM .[Sales].[SalesOrderDetail]
GROUP BY SalesOrderID


-- See the behavior when functions are used on the predicate
-- Execute the next batch
-- For both plans, look the number of actual and estimated rows at the FILTER OPERATOR. 
-- In both cases the estimated number of rows is away from reality
-- How can we help the QO to have calculate better estimates?

-- Clean env
DROP STATISTICS Sales.SalesOrderDetail.[_WA_Sys_00000004_6BE40491]
DROP STATISTICS Sales.SalesOrderDetail.[_WA_Sys_00000006_6BE40491]
DROP STATISTICS Sales.SalesOrderDetail.[_WA_Sys_00000007_6BE40491]

DBCC FREEPROCCACHE

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice = 100

SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice > 100

GO

-- Notice that SQL Server created statitics for each column independently
-- The estimated number of rows is defined by internal formulas based on those statistics

SELECT OBJECT_NAME(S.object_id) AS 'Object_name'
		, S.name AS 'statistics_name'
		, COL_NAME(SC.object_id, SC.column_id) AS 'Column'
FROM sys.stats AS S 
INNER JOIN sys.stats_columns AS SC
	ON S.stats_id = SC.stats_id AND S.object_id = SC.object_id
WHERE S.object_id = OBJECT_id('Sales.SalesOrderDetail')
	AND S.auto_created = 1

-- How can we help the QO to have calculate better estimates?
-- By adding a computed non persited column to the table

ALTER TABLE [Sales].[SalesOrderDetail]
ADD [totalforline]  AS (OrderQty*UnitPrice)

CREATE STATISTICS TotalStatsFullScan 
ON [Sales].[SalesOrderDetail] (totalforline) WITH FULLSCAN;

-- execute the queries again and see if there was any change on the estimated rows

DBCC FREEPROCCACHE

SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice = 100

SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice > 100
GO

-- Notice that the estimation are now closer to the actual number of rows
-- and the query did not have to be modified to use the statistic on the computed colum
-- and Yes, The plan uses a scan, the best option to tune the query woudl be to create an index

create index ix_test
on [Sales].[SalesOrderDetail] (totalforline)

SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice = 100

SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE OrderQty*UnitPrice > 100
GO

-- Notice that the query did no have to be modified to make use of the index on computed column


--	=====================================================================
--	Demo 2
--	Using filtered estatistics to improve catrdinality estimation
--	=====================================================================

-- The table [Sales].[SalesOrderDetail] has infomation from 2011-05-31 to 2014-06-30

select MIN(ModifiedDate), MAX(ModifiedDate) 
from [Sales].[SalesOrderDetail]

-- Get information for 2014-05-16
-- the QE estiamtes 132 rows, when the actual numebr of rows is 219
-- How can you help the QE to calculate a better estimated number of rows

DBCC FREEPROCCACHE

SELECT * 
FROM  [Sales].[SalesOrderDetail]
WHERE  ModifiedDate = '2014-05-21'

-- Answer: Filtered statistics 
-- In this demo, explain students that due to bussiness requirements, you ussualy query data
-- not older than 2 months, so you need to optimize queries that retrieve data not older than 2 months

CREATE STATISTICS filteredstatslsat2months
ON [Sales].[SalesOrderDetail] (ModifiedDate) 
WHERE ModifiedDate >= '2014-05-01'
WITH FULLSCAN 

-- Execute the query again. You will get a better estiamtion
DBCC FREEPROCCACHE

SELECT * 
FROM  [Sales].[SalesOrderDetail]
WHERE  ModifiedDate = '2014-05-21'

-- If you change the query to use a variable. The estimation will be bad again
-- As the QE does not know the value for the variable at compilation time and can not use the filtered statistic
-- using OPTION (RECOMPILE) can solve the issue

DBCC FREEPROCCACHE

declare @date as datetime
set @date = '2014-05-21'

SELECT * 
FROM  [Sales].[SalesOrderDetail]
WHERE  ModifiedDate = @date

SELECT * 
FROM  [Sales].[SalesOrderDetail]
WHERE  ModifiedDate = @date
OPTION (RECOMPILE)


--	=====================================================================
--	Demo 3
--	Identify used statitics
--	=====================================================================

-- Execute the following query
-- Right click on the SELECT operator and then click on Properties
-- Expand the property OptimizerStatsUsage 
-- Show the statistics used to create the plan. Only 1 stat was used

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] = 44079

-- Execute the following query
-- Right click on the SELECT operator and then click on Properties
-- There is no property OptimizerStatsUsage 
-- because SQL Serve is estimating 30% of the rows by default

declare @orderid int
set @orderid = 1

SELECT *
FROM .[Sales].[SalesOrderDetail]
WHERE [SalesOrderID] > @orderid 

-- Execute the following query
-- Right click on the SELECT operator and then click on Properties
-- Expand the property OptimizerStatsUsage 
-- Show the statistics used to create the plan. Several statistics were used

SELECT *
FROM .[Sales].[SalesOrderDetail]
where SalesOrderID = 43668 and ProductID  = 725
