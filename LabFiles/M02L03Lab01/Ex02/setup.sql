USE AdventureWorksPTO
GO
IF NOT EXISTS (SELECT * from sys.tables WHERE name = N'nums')
BEGIN
DECLARE @UpperBound INT = 100000000;

;WITH NumbersTable(Number) AS
(
	SELECT ROW_NUMBER() OVER (ORDER BY s1.[object_id]) - 1
	FROM sys.all_columns AS s1
	CROSS JOIN sys.all_columns AS s2
)
SELECT [Number] INTO dbo.Nums
	FROM NumbersTable WHERE [Number] <= @UpperBound;
END
 
USE [master]
GO
 
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'MemoryConsumer')
    DROP LOGIN [MemoryConsumer]
GO
 
CREATE LOGIN [MemoryConsumer] WITH PASSWORD=N'P@$$w0rd1', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
 
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
 
EXEC sys.sp_configure N'max server memory (MB)', N'750'
GO
 
RECONFIGURE WITH OVERRIDE
GO
 
CREATE FUNCTION [dbo].[rgMemoryConsumerClassifier]()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @resource_pool sysname
     
    IF SUSER_SNAME() = 'MemoryConsumer'
        SET @resource_pool = N'MemoryConsumer'
    ELSE
        SET @resource_pool = 'default'
     
    RETURN @resource_pool
END
GO
 
CREATE RESOURCE POOL [MemoryConsumer] WITH(min_cpu_percent=0, 
        max_cpu_percent=100, 
        min_memory_percent=0, 
        max_memory_percent=1)
GO
 
CREATE WORKLOAD GROUP [MemoryConsumer] WITH(group_max_requests=0, 
        importance=Medium, 
        request_max_cpu_time_sec=0, 
        request_max_memory_grant_percent=25, 
        request_memory_grant_timeout_sec=0, 
        max_dop=0) USING [MemoryConsumer]
GO
 
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = [dbo].[rgMemoryConsumerClassifier]);
GO
 
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
 
USE AdventureWorksPTO
GO
DROP USER IF EXISTS [MemoryConsumer]
GO
CREATE USER [MemoryConsumer] FOR LOGIN [MemoryConsumer]
GO
 
EXEC sp_addrolemember N'db_ddladmin', N'MemoryConsumer'
