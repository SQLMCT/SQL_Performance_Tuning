/* 
This Sample Code is provided for the purpose of illustration only and is not 
	intended to be used in a production environment. THIS SAMPLE CODE AND ANY
	RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
	EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
	WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample 
	Code and to reproduce and distribute the object code form of the Sample 
	Code, provided that You agree: 
	(i) to not use Our name, logo, or trademarks to market Your software 
		product in which the Sample Code is embedded; 
	(ii) to include a valid copyright notice on Your software product in 
		which the Sample Code is embedded; and 
	(iii) to indemnify, hold harmless, and defend Us and Our suppliers from 
		and against any claims or lawsuits, including attorneys fees, that 
		arise or result from the use or distribution of the Sample Code.
*/
USE ncci;
GO
-- Step 1 - how many rows
select count(*) from orders;

-- Step 2 - look at the rowgroups
SELECT OBJECT_NAME(object_id)
       ,index_id
       ,row_group_id
       ,delta_store_hobt_id
       ,state_desc
       ,total_rows
       ,trim_reason_desc
       ,transition_to_compressed_state_desc
FROM
  sys.dm_db_column_store_row_group_physical_stats
WHERE  object_id = OBJECT_ID('orders') 


-- Step 3 
-- show the index columns
SELECT OBJECT_NAME(i.object_id)
       ,i.Name
       ,i.index_id
	   ,type_desc
FROM
  sys.index_columns ic
  JOIN sys.indexes i
    ON i.index_id = ic.index_id
       AND i.object_id = ic.object_id
WHERE  i.object_id = OBJECT_ID('orders') 


--Step 4 - Highlight all of step 4 and Display estimated
-- analytics query performance
SET STATISTICS TIME ON
GO

-- a complex query with NCCI
select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orders
where purchaseprice > 90.0 and OrderStatus=5
group by customername
 
 -- a complex query without NCCI
select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orders
where purchaseprice > 90.0 and OrderStatus = 5
group by customername
option (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
SET STATISTICS TIME OFF
GO
-- end of step 4

-- clean up
USE master;
GO
DROP DATABASE IF EXISTS ncci;
GO