USE AdventureWorksPTO;
GO
DROP TABLE IF EXISTS dbo.Nums;
GO
USE master;
GO

IF EXISTS(SELECT * FROM sys.resource_governor_workload_groups WHERE name = 'MemoryConsumer')
    DROP WORKLOAD GROUP [MemoryConsumer]
GO
 
IF EXISTS(SELECT * FROM sys.resource_governor_resource_pools WHERE name = 'MemoryConsumer')
    DROP RESOURCE POOL [MemoryConsumer]
GO
 
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO
 
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
 
ALTER RESOURCE GOVERNOR DISABLE;
GO
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rgMemoryConsumerClassifier]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[rgMemoryConsumerClassifier]
GO
 
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
 
EXEC sys.sp_configure N'max server memory (MB)', N'2147483647'
GO
 
RECONFIGURE WITH OVERRIDE
GO