Use PartitionDB
GO
----------------------------------------------------------------------------------------------------------------------
----------------------------------------Before Switching Partition 3 has 352 rows------------------------
----------------------------------------------------------------------------------------------------------------------
SELECT object_name(object_id) TableName, * 
FROM sys.partitions 
WHERE (object_id = object_id ('SalesOrderHeader') --partiton 3 has 352 rows
				OR  object_id = object_id ('SalesOrderHeaderstg') --partiton 3 has 0 rows
				)
And  Index_id = 1
order by TableName,index_id,partition_number 
-----Switch  Execution plan to normal 
-----Before Switching the partitions , Show number of rows in SalesOrderHeader and SalesOrderHeaderstg
--select distinct TerritoryID from SalesOrderHeader
SELECT count(*) Total_in_SalesOrderHeader from SalesOrderHeader WHERE TerritoryID = 2--352
SELECT count(*) total_in_staging from SalesOrderHeaderstg --0
-------------------------------------------------------------------------------------------------------
-- Switch the oldest data from partition 3 out of main table into the staging table
-------------------------------------------------------------------------------------------------------
TRUNCATE table SalesOrderHeaderstg
go
ALTER TABLE SalesOrderHeader
SWITCH PARTITION 3 TO SalesOrderHeaderstg  PARTITION 3;
---------------------------------------------After Switch -------------------------------------------------------
---after switch , Show number of rows in SalesOrderHeader and SalesOrderHeaderstg

SELECT object_name(object_id) TableName, * 
FROM sys.partitions 
WHERE (object_id = object_id ('SalesOrderHeader') --partiton 3 has 0 rows
				OR  object_id = object_id ('SalesOrderHeaderstg') --partiton 3 has 352 rows
				)
And  Index_id = 1
order by TableName,index_id,partition_number 
----------------------------------------------------------------------------------------------------------------
--NOW partition 3 has 0 rows in non-cluster indexes 
----------------------------------------------------------------------------------------------------------------

SELECT count(*) Total_in_SalesOrderHeader from SalesOrderHeader WHERE TerritoryID = 2--0
SELECT count(*) total_in_staging from SalesOrderHeaderstg --352
----------------------------------------------------------------------------------------------------------------------