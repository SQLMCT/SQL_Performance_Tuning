-- See the current blocked process threshold (s) configuration

USE Master
GO
SELECT * FROM SYS.CONFIGURATIONS
WHERE name LIKE '%blocked process threshold (s)%'


-- Change the blocked process threshold (s) to 5

USE Master
GO
EXEC sys.sp_configure 'show advanced options','1'
GO
RECONFIGURE
GO
EXEC sys.sp_configure N'blocked process threshold (s)', N'5'
GO
RECONFIGURE
GO


