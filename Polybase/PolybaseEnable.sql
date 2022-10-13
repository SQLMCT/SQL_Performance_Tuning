USE MASTER
GO

EXEC sp_configure 
	@configname = 'polybase enabled',
	@configvalue = 1;
GO
RECONFIGURE
GO

EXEC sp_configure 
	@configname = 'hadoop connectivity',
	@configvalue = 7;
GO
RECONFIGURE
GO