IF EXISTS (SELECT * FROM sys.configurations WHERE configuration_id = 1544 AND [value] = 399)
  EXEC sp_configure 'max server memory', 2147483647
GO
IF EXISTS (SELECT * FROM sys.configurations WHERE configuration_id = 1544 AND [value_in_use] = 399)
  RECONFIGURE WITH OVERRIDE
GO
DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
GO
