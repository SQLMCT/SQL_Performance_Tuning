Use PartitionDB
GO
----------------------------------------------------------------------------------------------------------------------
-- Now Remove the empty oldest partition(3) from the main table
-----------------------------------------------------------------------------------------------------------------------
ALTER PARTITION FUNCTION OrderHeader_TerritoryPartitions_PFN()
MERGE RANGE (3);
---SHOW PARTITION 3 IS GONE but data of partition 3 and 4 is merged 

SELECT
OBJECT_NAME(PS.object_id) AS TableName
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
,prv.value AS PartitionBoundaryValue
,Col.name AS PartitionKey
,CASE 
WHEN pf.boundary_value_on_right = 0 
THEN Col.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY PS.object_id ORDER BY PS.object_id, PS.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + Col.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
ELSE Col.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) + ' and ' + Col.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY PS.object_id ORDER BY PS.object_id, PS.partition_number), 'Infinity') AS VARCHAR(100))
END AS PartitionRange
,P.partition_id PartitionNumber
,P.rows AS PartitionRowCount
,P.data_compression_desc AS DataCompression
--,OBJECT_SCHEMA_NAME(PS.object_id) AS SchemaName
--,PScm.name AS PartitionSchemeName
--,DSpc.name AS PartitionFilegroupName
--,pf.name AS PartitionFunctionName
FROM sys.dm_db_partition_stats AS PS
INNER JOIN sys.partitions AS P 
	ON PS.partition_id = P.partition_id
INNER JOIN sys.destination_data_spaces AS DDSpc
	ON PS.partition_number = DDSpc.destination_id
INNER JOIN sys.data_spaces AS DSpc 
	ON DDSpc.data_space_id = DSpc.data_space_id
INNER JOIN sys.partition_schemes AS Pscm 
	ON DDSpc.partition_scheme_id = PScm.data_space_id
INNER JOIN sys.partition_functions AS pf 
	ON PScm.function_id = pf.function_id
INNER JOIN sys.indexes AS Indx 
	ON PS.object_id = Indx.object_id AND PS.index_id = Indx.index_id AND DDSpc.partition_scheme_id = Indx.data_space_id AND Indx.type <= 1 /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ICol 
	ON Indx.index_id = ICol.index_id AND Indx.object_id = Icol.object_id AND ICol.partition_ordinal > 0
INNER JOIN sys.columns AS Col 
	ON PS.object_id = Col.object_id AND ICol.column_id = Col.column_id
LEFT JOIN sys.partition_range_values AS prv 
	ON pf.function_id = prv.function_id AND PS.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
ORDER BY TableName, PartitionBoundaryValue;

--------------------------------------------------------------------------------------------------------------------------
-- Make a new partition filegroup available to the partition scheme
--As a next step, we need to split the partition to accommodate for the new boundary. 
--The "Alter Partition Scheme NEXT USED" SQL statement will help to prepare the filegroup to accommodate the new partition.
---------------------------------------------------------------------------------------------------------------------------
ALTER PARTITION SCHEME [OrderHeader_TerritoryPartitions_PS]
NEXT USED [PRIMARY];
----------------------------------------------------------------------------------------------------------------------------
-- Add a new partition (which will use the filegroup identified as "next used")
----------------------------------------------------------------------------------------------------------------------------
ALTER PARTITION FUNCTION OrderHeader_TerritoryPartitions_PFN()
SPLIT RANGE (3);
-------------------------------------------------------------------------------------------------------------------------------------------
--partition 3 is created and ready to accept the new data at this moemnt  hence now partition 3 has 0 rows
----------------------------------------------------------------------------------------------------------------------------------------------

SELECT
OBJECT_NAME(PS.object_id) AS TableName
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
,prv.value AS PartitionBoundaryValue
,Col.name AS PartitionKey
,CASE 
WHEN pf.boundary_value_on_right = 0 
THEN Col.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY PS.object_id ORDER BY PS.object_id, PS.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + Col.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
ELSE Col.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) + ' and ' + Col.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY PS.object_id ORDER BY PS.object_id, PS.partition_number), 'Infinity') AS VARCHAR(100))
END AS PartitionRange
,P.partition_id PartitionNumber
,P.rows AS PartitionRowCount
,P.data_compression_desc AS DataCompression
--,OBJECT_SCHEMA_NAME(PS.object_id) AS SchemaName
--,PScm.name AS PartitionSchemeName
--,DSpc.name AS PartitionFilegroupName
--,pf.name AS PartitionFunctionName
FROM sys.dm_db_partition_stats AS PS
INNER JOIN sys.partitions AS P 
	ON PS.partition_id = P.partition_id
INNER JOIN sys.destination_data_spaces AS DDSpc
	ON PS.partition_number = DDSpc.destination_id
INNER JOIN sys.data_spaces AS DSpc 
	ON DDSpc.data_space_id = DSpc.data_space_id
INNER JOIN sys.partition_schemes AS Pscm 
	ON DDSpc.partition_scheme_id = PScm.data_space_id
INNER JOIN sys.partition_functions AS pf 
	ON PScm.function_id = pf.function_id
INNER JOIN sys.indexes AS Indx 
	ON PS.object_id = Indx.object_id AND PS.index_id = Indx.index_id AND DDSpc.partition_scheme_id = Indx.data_space_id AND Indx.type <= 1 /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ICol 
	ON Indx.index_id = ICol.index_id AND Indx.object_id = Icol.object_id AND ICol.partition_ordinal > 0
INNER JOIN sys.columns AS Col 
	ON PS.object_id = Col.object_id AND ICol.column_id = Col.column_id
LEFT JOIN sys.partition_range_values AS prv 
	ON pf.function_id = prv.function_id AND PS.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
ORDER BY TableName, PartitionBoundaryValue;

--5 --> 26134
--3 ---> 0
--------------------------------------------------------------------------------------------------------------------------------
-- Confirm data row count in both tables after making changes
--------------------------------------------------------------------------------------------------------------------------------
SELECT
    N'CountOfSalesOrderHeaderStg' = (SELECT COUNT(*) FROM SalesOrderHeaderStg where TerritoryID=2)
    , N'CountOfSalesOrderHeader' = (SELECT COUNT(*) FROM SalesOrderHeader  where TerritoryID=2);