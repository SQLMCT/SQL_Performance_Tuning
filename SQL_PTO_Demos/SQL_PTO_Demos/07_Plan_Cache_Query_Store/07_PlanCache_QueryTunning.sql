
-- Plan Cache

-- what information is available in this DMV?
SELECT  *
FROM   sys.dm_exec_cached_plans;

-- what information is available in this DMV?
SELECT  *
FROM   sys.dm_exec_query_stats;

-- this query returns the text and plan for queries
-- point out each column type
SELECT objtype, refcounts, usecounts, text, query_plan
FROM   sys.dm_exec_cached_plans AS a
       INNER JOIN
       sys.dm_exec_query_stats AS b
       ON a.plan_handle = b.plan_handle 
	   CROSS APPLY sys.dm_exec_sql_text (b.sql_handle) 
   CROSS APPLY sys.dm_exec_query_plan (b.plan_handle)
WHERE objtype = 'AdHoc'
ORDER BY usecounts desc;

--Ad-Hoc Query
SELECT SalesOrderID, OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870
GO
--DBCC FREEPROCCACHE



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
