
---Filter Indexes Demo 
USE AdventureWorks2019;  
GO  
DROP INDEX IF EXISTS IX_Unitprice  ON  Sales.SalesOrderDetail;
DROP INDEX IF EXISTS FilteredIX_Unitprice ON  Sales.SalesOrderDetail

 ----List index is still exists 
SELECT i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
		AND s.[index_id] = i.[index_id]
GROUP BY i.[name]
Having i.[name]  in ('IX_UnitPrice','FilteredIX_UnitPrice')
GO
--------------------------------------------------------------
-- Query Using NO Index on UnitPrice
--------------------------------------------------------------
---Include Actual Execution
SET STATISTICS IO ON
SELECT 'No Index' Indexname, SalesOrderID, UnitPrice
FROM AdventureWorks2019.Sales.SalesOrderDetail
WHERE UnitPrice > 3500
GO
SET STATISTICS IO OFF

--- Clustered Index Scan
--(1551 rows affected)
-----Table 'SalesOrderDetail'. 
--(1551 rows affected)
--Table 'SalesOrderDetail'. Scan count 1, logical reads 428, physical reads 3, page server reads 0, read-ahead reads 431
--.014 second
--------------------------------------------------------------------------------------------
-- Adding Non cluster index on UnitPrice 
--------------------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_UnitPrice 
ON AdventureWorks2019.Sales.SalesOrderDetail(UnitPrice)
GO
SET STATISTICS IO ON
SELECT 'Non-clustered Index' IndexName, SalesOrderID, UnitPrice
FROM AdventureWorks2019.Sales.SalesOrderDetail
WHERE UnitPrice > 3500
GO
SET STATISTICS IO OFF
--Index Seek on Non cluster index
--(1551 rows affected)
--Table 'SalesOrderDetail'. Scan count 1, logical reads 8, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Subtree cost 0.008

---------Add Filtered Index-------------------------
CREATE NONCLUSTERED INDEX FilteredIX_UnitPrice
ON AdventureWorks2019.Sales.SalesOrderDetail(UnitPrice)
WHERE UnitPrice > 3500
GO

SET STATISTICS IO ON
SELECT 'Non-clustered Filtered Index', SalesOrderDetailID, UnitPrice
FROM AdventureWorks2019.Sales.SalesOrderDetail WITH ( INDEX ( FilteredIX_UnitPrice ) )   
WHERE UnitPrice > 3500
GO
SET STATISTICS IO OFF
--Index Scan
--(1551 rows affected)
--Table 'SalesOrderDetail'. Scan count 1, logical reads 7, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- Subtree cost 0.005
--Index scan


----------Now Further reducing logical reads when filter is changed to UnitPrice > 5000
SET STATISTICS IO ON
SELECT 'Non-clustered Filter Index', SalesOrderDetailID, UnitPrice
FROM AdventureWorks2019.Sales.SalesOrderDetail 
	WITH ( INDEX ( FilteredIX_UnitPrice ) )   
WHERE UnitPrice > 5500
SET STATISTICS IO OFF

--Index Seek
--(0 rows affected)
--Table 'SalesOrderDetail'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Cost 0.003
-------------------------------------------------------------------
----index space used 
-------------------------------------------------------------------
SELECT i.[name] AS IndexName
    ,SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
GROUP BY i.[name]
HAVING i.[name]  in ('IX_Unitprice','FilteredIX_Unitprice')
GO
-----------------------------------------------------------------------------
--Filter index Stats
----------------------------------------------------------------------------
SELECT object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE has_filter = 1


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

