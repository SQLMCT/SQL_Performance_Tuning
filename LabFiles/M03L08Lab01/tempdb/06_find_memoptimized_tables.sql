USE tempdb;
go
SELECT OBJECT_NAME(object_id) as [object_name], * FROM sys.dm_db_xtp_object_stats;
go