-- DISCLAIMER:
/* 
	This Sample Code is provided for the purpose of illustration only and is not intended
	to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE
	PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
	NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
	PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
	and to reproduce and distribute the object code form of the Sample Code, provided that You
	agree: 
		(i) to not use Our name, logo, or trademarks to market Your software product in which
			the Sample Code is embedded; 
		(ii) to include a valid copyright notice on Your software product
			in which the Sample Code is embedded; 
			and 
		(iii) to indemnify, hold harmless, and defend Us and
			Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or
			result from the use or distribution of the Sample Code.
*/
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-resource-pool-transact-sql


USE master;
GO

--State of Resource Governor
SELECT * FROM sys.resource_governor_configuration
GO

--Enable Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

--Disable Resource Governor
ALTER RESOURCE GOVERNOR DISABLE;
GO

--Show Logins
SELECT s.session_id, s.login_name, g.name
FROM sys.dm_exec_sessions as s
JOIN sys.dm_resource_governor_workload_groups as g
ON s.group_id = g.group_id
WHERE s.session_id > 50



-- show how many CPUs are available before the demo:
SELECT * FROM sys.dm_os_schedulers --How many are visible online
WHERE status = 'VISIBLE ONLINE'
GO


-- use only 1 CPU on demo machine
sp_configure 'show advanced', 1
GO
RECONFIGURE WITH OVERRIDE
GO
-- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/affinity-mask-server-configuration-option
sp_configure 'affinity mask', 15
GO
RECONFIGURE WITH OVERRIDE
GO

-- Validate
SELECT * FROM sys.dm_os_schedulers --How many are visible online
WHERE status = 'VISIBLE ONLINE'
GO

-- Is Resource Governor Enabled ?
SELECT * FROM sys.resource_governor_configuration;

-- create logins to separate users into different groups
-- note that we disabled strong password checking for demo purposes, but this is against any best practice
-- make sure to change to MASTER
USE Master
GO
CREATE LOGIN UserOperations WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
CREATE LOGIN UserSales      WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
CREATE LOGIN UserMarketing  WITH PASSWORD = 'UserPwd', CHECK_POLICY = OFF
GO

USE AdventureWorks2022
GO
CREATE USER UserOperations FROM LOGIN UserOperations WITH DEFAULT_SCHEMA=[dbo]
CREATE USER UserSales	FROM LOGIN UserSales		 WITH DEFAULT_SCHEMA=[dbo]
CREATE USER UserMarketing  FROM LOGIN UserMarketing	 WITH DEFAULT_SCHEMA=[dbo]
GO

ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [UserOperations]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [UserSales]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [UserMarketing]
GO

ALTER ROLE [db_owner] ADD MEMBER [UserOperations]
GO
ALTER ROLE [db_owner] ADD MEMBER [UserSales]
GO
ALTER ROLE [db_owner] ADD MEMBER [UserMarketing]
GO

USE Master
GO

-- create user pools - note that we are using all default parameters
IF EXISTS (SELECT * FROM sys.dm_resource_governor_workload_groups WHERE name = 'Group_Operations')
	DROP WORKLOAD GROUP Group_Operations 
GO
IF EXISTS (SELECT * FROM sys.dm_resource_governor_resource_pools WHERE name = 'Pool_Operations')
	DROP RESOURCE POOL Pool_Operations 
GO

CREATE RESOURCE POOL Pool_Operations 
WITH
	(
		 MIN_CPU_PERCENT = 40
		,MAX_CPU_PERCENT = 60
		--MIN_MEMORY_PERCENT = 10
		--,MAX_MEMORY_PERCENT = 25
		,MIN_IOPS_PER_VOLUME = 1
		,MAX_IOPS_PER_VOLUME = 5
	);

-- create Workload Group - also note that all groups created with default parameters
-- only pointing to the corresponding pools (and not 'default')
CREATE WORKLOAD GROUP Group_Operations 
WITH
(
	IMPORTANCE = LOW -- {LOW | MEDIUM | HIGH}
	--,REQUEST_MAX_MEMORY_GRANT_PERCENT = value
	--,REQUEST_MAX_CPU_TIME_SEC = value
	--,REQUEST_MEMORY_GRANT_TIMEOUT_SEC = value
	,MAX_DOP = 1 -- value
	--,GROUP_MAX_REQUEST = value
)USING Pool_Operations
GO

IF EXISTS (SELECT * FROM sys.dm_resource_governor_workload_groups WHERE name = 'Group_Sales')
	DROP WORKLOAD GROUP Group_Sales 
GO
IF EXISTS (SELECT * FROM sys.dm_resource_governor_workload_groups WHERE name = 'Group_MKT')
	DROP WORKLOAD GROUP Group_MKT
GO
IF EXISTS (SELECT * FROM sys.dm_resource_governor_resource_pools WHERE name = 'Pool_SalesMKT')
	DROP RESOURCE POOL Pool_SalesMKT
GO


CREATE RESOURCE POOL Pool_SalesMKT 
WITH
(
	 MIN_CPU_PERCENT = 20
	,MAX_CPU_PERCENT = 30
	--MIN_MEMORY_PERCENT = 10
	--,MAX_MEMORY_PERCENT = 25
	,MIN_IOPS_PER_VOLUME = 1
	,MAX_IOPS_PER_VOLUME = 2
);
-- create Workload Group - also note that all groups created with default parameters
-- only pointing to the corresponding pools (and not 'default')
CREATE WORKLOAD GROUP Group_Sales 
WITH
(
	IMPORTANCE = LOW -- {LOW | MEDIUM | HIGH}
	--,REQUEST_MAX_MEMORY_GRANT_PERCENT = value
	--,REQUEST_MAX_CPU_TIME_SEC = value
	--,REQUEST_MEMORY_GRANT_TIMEOUT_SEC = value
	,MAX_DOP = 2
	--,GROUP_MAX_REQUEST = value
) USING Pool_SalesMKT
GO
CREATE WORKLOAD GROUP Group_MKT
WITH
(
	IMPORTANCE = LOW -- {LOW | MEDIUM | HIGH}
	--,REQUEST_MAX_MEMORY_GRANT_PERCENT = value
	--,REQUEST_MAX_CPU_TIME_SEC = value
	--,REQUEST_MEMORY_GRANT_TIMEOUT_SEC = value
	,MAX_DOP = 2
	--,GROUP_MAX_REQUEST = value
) USING Pool_SalesMKT
GO

--------------------------------------------------------------------------------------
-- BEFORE "activating" RG
-- RUN SCRIPT query to show PerfMon catalog entries
 
SELECT * FROM sys.dm_os_performance_counters WHERE Object_Name like '%resource pool stats%'
SELECT * FROM sys.dm_os_performance_counters WHERE Object_Name like '%Workload group stats%'

SELECT DISTINCT counter_name FROM sys.dm_os_performance_counters WHERE Object_Name like '%resource pool stats%'
SELECT DISTINCT counter_name FROM sys.dm_os_performance_counters WHERE Object_Name like '%Workload group stats%'

SELECT DISTINCT instance_name FROM sys.dm_os_performance_counters WHERE Object_Name like '%resource pool stats%'
SELECT DISTINCT instance_name FROM sys.dm_os_performance_counters WHERE Object_Name like '%Workload group stats%'

--------------------------------------------------------------------------------------


-- classifier function should be created in master database, 
--		switch to master unless you are there already
-- make function known to the Resource Governor 
USE master;
GO
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- now create the classifier function
IF OBJECT_ID('DBO.CLASSIFIER_V1','FN') IS NOT NULL
       DROP FUNCTION DBO.CLASSIFIER_V1
GO

-- note that this is just a regular function 
USE master;
DROP FUNCTION IF EXISTS CLASSIFIER_V1 
GO
CREATE FUNCTION CLASSIFIER_V1 ()
RETURNS SYSNAME 
WITH SCHEMABINDING
BEGIN
       DECLARE @val varchar(32)
       SET @val = 'default';
       if  'UserOperations' = SUSER_SNAME() 
              SET @val = 'Group_Operations'
         else if 'UserSales' = SUSER_SNAME()
              SET @val = 'Group_Sales'
           else if 'UserMarketing' = SUSER_SNAME()
              SET @val = 'Group_MKT'
	   return @val;
END
GO

-- make function known to the Resource Governor 
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.CLASSIFIER_V1)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

--------------------------------------------------
-- 3 - VIEW METADATA INFORMATION
--------------------------------------------------
  -- Reset the pool and workload statistics
ALTER RESOURCE GOVERNOR RESET STATISTICS;


-- metadata information
SELECT * FROM sys.resource_governor_workload_groups
SELECT * FROM sys.resource_governor_resource_pools
SELECT OBJECT_NAME(classifier_function_id) as 'classifier function',* FROM sys.resource_governor_configuration


-- in-memory information
SELECT * FROM sys.dm_resource_governor_workload_groups
SELECT * FROM sys.dm_resource_governor_resource_pools
SELECT * FROM sys.dm_resource_governor_configuration

SELECT 
	p.pool_id,
	group_id, 
	P.name as [Pool Name],
	W.name as [Workload Group Name] 
FROM 
	sys.dm_resource_governor_workload_groups W
	Inner Join sys.dm_resource_governor_resource_pools P
		On W.pool_id = P.pool_id
ORDER BY 
	p.pool_id,
	group_id, 
	P.name,
	W.name 


--------------------------------------------------------------------------------------
-- open the 2 PerfMon counters related to RG:
-- [RESOURCE GOVERNOR - PerfCounters - ResourcePool Stats.PerfmonCfg]
-- [RESOURCE GOVERNOR - PerfCounters - WorkloadGroup Stats.PerfmonCfg]
--------------------------------------------------------------------------------------


--******* Start batch CPU jobs: 1 job at time, watch PERFMON *******
-- open PowerShell, move to the folder where these files can be located, and:
-- start QueryOps1_CPU.bat
-- show PerfMon 
-- start QuerySales1_CPU.bat
-- show PerfMon 
-- start QueryMKT1_CPU.bat
-- show PerfMon 


--What Scheduler am I running on?
Select 
	session_id, 
	scheduler_id, 
	WG.Name, 
	RP.name,
	ER.command,
	ER.cpu_time,
	ER.logical_reads, 
	ER.open_resultset_count , 
	ER.percent_complete,
	ER.reads,
	ER.scheduler_id, 
	er.status,
	ER.wait_type,
	ER.wait_resource,
	ER.wait_time
from 
	sys.dm_exec_requests ER
	Inner Join sys.dm_resource_governor_workload_groups WG
		on ER.group_id = WG.group_id
	INNER JOIN sys.dm_resource_governor_resource_pools RP
		ON WG.pool_id = RP.pool_id
where 
	WG.group_id > 2
ORDER BY 
	session_id

-- ASSIGN higher priority to Pool_Operations
ALTER RESOURCE POOL Pool_Operations 
WITH (MIN_CPU_PERCENT = 60,MAX_CPU_PERCENT=80)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- SHOW PerfMon graph
--		Now the Operations workload is clearly getting more of the CPU resources, 
--		and close to 60 percent of a single CPU, 
--		while the Sales and Marketing workloads are getting closer to 30 percent.


-- adjust Pool_SalesMKT to not consume more than 30% of CPU
ALTER RESOURCE POOL Pool_SalesMKT
WITH (MIN_CPU_PERCENT=10, MAX_CPU_PERCENT = 15)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO
-- Show PerfMon again


-- STOP BATCH FROM Pool_Operations and see what happens to PerfMon
--	this will show that Pool_SalesMKT DOES NOT stay limited to 30%
--		AS IT USES OPPORTUNISTIC MAXIMUM

-- to CAP the Pool_SalesMKT to 30% MAX, we use the next statement:
ALTER RESOURCE POOL Pool_Operations
WITH (min_cpu_percent=30,CAP_CPU_PERCENT=50)
GO

ALTER RESOURCE POOL Pool_SalesMKT
WITH (CAP_CPU_PERCENT=10)
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- show PerfMon again


-- 2012 FEATURE: allow SCHEDULER AFFINITY
-- make available all cores
sp_configure 'affinity mask', 0
GO
RECONFIGURE WITH OVERRIDE
GO
-- Validate
Select * from sys.dm_os_schedulers --How many are visible online
GO

-- affinitize each pool
ALTER RESOURCE POOL Pool_Operations
WITH (AFFINITY SCHEDULER = (0))
GO
ALTER RESOURCE POOL Pool_SalesMKT
WITH (AFFINITY SCHEDULER = (1))
GO
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- Show PerfMon
-- each workload is running on separate CPU
--	CAP is still in place 


-- alter importance of B group
ALTER WORKLOAD GROUP Group_Sales WITH (IMPORTANCE = Low) --1/10

-- alter importance of C group
ALTER WORKLOAD GROUP Group_MKT WITH (IMPORTANCE = High)-- 9/10

-- make the changes effective
ALTER RESOURCE GOVERNOR RECONFIGURE

-- Restart batches

-- Stop Batches

-- New with SQL Server 2012 I can now CAP CPU. Let's CAP CPU for Resource Pool 1

-- adjust Pool_Operations to be capped at 50% of CPU
ALTER RESOURCE POOL Pool_Operations WITH (CAP_CPU_PERCENT = 50,MIN_CPU_PERCENT=30)

-- make the changes effective
ALTER RESOURCE GOVERNOR RECONFIGURE
-- Restart batches

-- Stop Batches


