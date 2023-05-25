USE master;
go
-- Is Resource Governor Enabled ?
SELECT * FROM sys.resource_governor_configuration;

--USE Master
--CREATE LOGIN UserSales  WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
--CREATE LOGIN UserMarketing  WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
--GO

--USE AdventureWorks2019
--CREATE USER UserSales FROM LOGIN UserSales WITH DEFAULT_SCHEMA=[dbo]
--ALTER ROLE db_owner ADD MEMBER UserSales
--CREATE USER UserMarketing FROM LOGIN UserMarketing WITH DEFAULT_SCHEMA=[dbo]
--ALTER ROLE db_owner ADD MEMBER UserMarketing
--GO


-- Create Resource Pool 
USE Master
GO
ALTER RESOURCE POOL Sales_Operations 
WITH
	(	 MIN_CPU_PERCENT = 0
		,MAX_CPU_PERCENT = 20
		--MIN_MEMORY_PERCENT = 10
		--,MAX_MEMORY_PERCENT = 25
		--,MIN_IOPS_PER_VOLUME = 1
		--,MAX_IOPS_PER_VOLUME = 5
	);

-- Create Workload Group 
ALTER WORKLOAD GROUP Group_Operations 
WITH
	(
	IMPORTANCE = MEDIUM -- {LOW | MEDIUM | HIGH}
	,MAX_DOP = 8 -- value
	--,REQUEST_MAX_MEMORY_GRANT_PERCENT = value
	--,REQUEST_MAX_CPU_TIME_SEC = value
	--,REQUEST_MEMORY_GRANT_TIMEOUT_SEC = value
	--,GROUP_MAX_REQUEST = value
	) USING Sales_Operations
GO

USE master;
GO
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- note that this is just a regular function 
USE master;
DROP FUNCTION IF EXISTS udf_Sales_Classifier
GO

--Create Classifer Function
CREATE FUNCTION dbo.udf_Sales_Classifier()
RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @AssignWorkGroup as sysname
	IF (SUSER_NAME() = 'UserSales')
		SET @AssignWorkGroup = 'Group_Operations'
	ELSE
		SET @AssignWorkGroup = 'default'
	RETURN @AssignWorkGroup
END
GO

ALTER RESOURCE GOVERNOR WITH 
(CLASSIFIER_FUNCTION = dbo.udf_Sales_Classifier)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

SELECT s.session_id, s.login_name, s.login_time,
	wg.name as 'Group_Assigned', rp.name AS 'Pool_Assigned'
FROM sys.dm_exec_sessions as s
	JOIN sys.dm_resource_governor_workload_groups as wg
		ON s.group_id = wg.group_id
	JOIN sys.dm_resource_governor_resource_pools as rp
		ON wg.pool_id = rp.pool_id
WHERE s.login_name <> 'sa'
GO

/* Open Performance Monitor and add Workload Group Counters */

/* Execute QuerySales_CPU.bat 
	 OSTRESS -S.\JDSQL19 -UUserSales -PUserPwd 
	 -i"14_CPU_Intensive_Loop02.sql" -n20 -o"CPUSales02" */

/* Execute QueryMKT1_CPU.bat
	OSTRESS -S.\JDSQL19 -UUserSales -PUserPwd 
	-i"14_CPU_Intensive_Loop02.sql" -n20 -o"CPUSales02" */



