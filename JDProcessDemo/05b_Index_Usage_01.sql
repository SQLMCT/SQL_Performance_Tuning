/*
This query shows the indexes for table Sales.SalesOrderHeader
notice that not all indexes have been used for SEEK/SCAN
maybe the CLUSTERED index hasn't been used for LOOKUP yet
*/

USE AdventureWorks2019
GO
SELECT 
    i.index_id,
	indexname = i.name, 
    user_seeks, user_scans, user_lookups, user_updates,
    user_seeks + user_scans + user_lookups AS total_reads
FROM 
	sys.dm_db_index_usage_stats s
    RIGHT OUTER JOIN sys.indexes i 
		ON i.object_id = s.object_id AND i.index_id = s.index_id
    JOIN sys.objects o 
		ON o.object_id = i.object_id
    JOIN sys.schemas sc 
		ON sc.schema_id = o.schema_id
WHERE o.type = 'U' -- user table
    AND o.name = N'SalesOrderHeader';
GO

/*  Look for rarely used indexes on all tables 
	If the index hasn't been used, it does not have an entry 
	in the sys.dm_db_index_usage_stats as this query doesn't
	use an outer join. */

--SELECT 
--	s.object_id, indexname = i.name, 
--    user_seeks, user_scans, user_lookups, user_updates,
--    user_seeks + user_scans + user_lookups AS total_reads
--FROM 
--	sys.dm_db_index_usage_stats s
--    JOIN sys.indexes i 
--		ON i.object_id = s.object_id AND i.index_id = s.index_id
--    JOIN sys.objects o 
--		ON o.object_id = i.object_id
--    JOIN sys.schemas sc 
--		ON sc.schema_id = o.schema_id
--WHERE 
--	o.type = 'U' -- user table
--    AND 
--	user_seeks + user_scans + user_lookups < 20
--ORDER BY ( user_seeks + user_scans + user_lookups );















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