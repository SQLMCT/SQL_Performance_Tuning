SELECT OBJECT_SCHEMA_NAME(I.object_id) AS SchemaName,
	   OBJECT_NAME(I.object_id) AS TableName, 
	   I.name, I.index_id,
	   IPS.avg_fragmentation_in_percent,
	   IPS.page_count,
	   IPS.avg_page_space_used_in_percent
FROM sys.indexes as I
INNER JOIN sys.dm_db_index_physical_stats
			(DB_ID(), NULL, NULL, NULL, 'Limited') as IPS
	ON I.object_id = IPS. object_id 
	AND I.index_id = IPS.index_id
WHERE IPS.avg_fragmentation_in_percent > 30
AND IPS.page_count > 1000