USE [AdventureWorks2019]
GO

--Creating partitioned index on an existing table. 
--This would be a non-aligned partitioned index.
--Create the partition function to set the value to partition.
CREATE PARTITION FUNCTION [pf_OrderDate](datetime) 
AS RANGE RIGHT FOR VALUES (N'2011-01-01', N'2012-01-01', 
	N'2013-01-01')

--Create the partition scheme to map the partitions to filegroups.
--In this demonstration, all partition will use the Primary filegroup.
CREATE PARTITION SCHEME [pf_Date_Scheme] 
AS PARTITION [pf_OrderDate] 
ALL TO ([PRIMARY])

--Apply the partition scheme to a new nonclustered index
CREATE NONCLUSTERED INDEX [NonClusteredIndex_on_pf_Date_Scheme] ON [Sales].[SalesOrderHeader]
([OrderDate])ON [pf_Date_Scheme]([OrderDate])

--Check the number of partitions of the new index (index_id > 5)
SELECT * 
FROM sys.partitions 
WHERE object_id = object_id('[Sales].[SalesOrderHeader]') AND index_id > 5

--When ready to start a new year create a new range
--Split Range will split the last partition.
ALTER PARTITION FUNCTION [pf_OrderDate]() 
SPLIT RANGE (N'2014-01-01');

--Check the number of Partitions
SELECT * FROM sys.partitions 
where object_id = object_id('[Sales].[SalesOrderHeader]') AND index_id > 5

