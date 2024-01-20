EXEC sys.sp_configure N'show', 1
GO
RECONFIGURE WITH OVERRIDE
GO

EXEC sys.sp_configure N'max server memory (MB)', N'2000'
GO
RECONFIGURE WITH OVERRIDE
GO

