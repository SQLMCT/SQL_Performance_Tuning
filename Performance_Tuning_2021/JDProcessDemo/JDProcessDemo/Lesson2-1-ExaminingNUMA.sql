/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/

--Run the following query to find the number of memory nodes available to SQL Server
--A single memory node (node 0), either you do not have hardware NUMA, or the hardware 
--is configured as interleaved (non-NUMA). 
SELECT DISTINCT memory_node_id
FROM sys.dm_os_memory_clerks

--sys.dm_os_memory_nodes and sys.dm_os_memory_node_access_stats provide information about physical 
--non-uniform memory access (NUMA) memory nodes and node access statistics grouped by the type of the page. (sys.dm_os_memory_node_access_stats is populated under dynamic trace flag 842 due to its performance impact.)
--sys.dm_os_nodes provides information about CPU node configuration for SQL Server. 
--This DMV also reflects software NUMA (soft-NUMA) configuration.

SELECT * FROM sys.dm_os_memory_nodes

SELECT * FROM sys.dm_os_nodes

SELECT * FROM sys.dm_os_memory_node_access_stats

--Reference: http://blogs.msdn.com/b/ialonso/archive/2012/07/22/reason-for-the-mismatch-between-sys-dm-os-memory-nodes-virtual-address-space-committed-kb-and-aggregated-sys-dm-os-memory-clerks-virtual-memory-committed-kb-by-memory-node-id.aspx

DBCC MEMORYSTATUS
-- Look for Memory Manager \  NUMA Growth Phase
--Reference: http://sqlblog.com/blogs/sqlos_team/archive/2012/07/11/memory-manager-surface-area-changes-in-sql-server-2012.aspx

/*Set the CPU affinity mask
Run the following statement on instance A to configure it to use CPUs 1, 2, 3, and 4 by setting the CPU affinity mask:*/

ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU=1 TO 4
 
--Run the following statement on instance B to configure it to use CPUs 5, 6, 7, and 8 by setting the CPU affinity mask:

ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU=5 TO 8
 

--DEMO WITH WORKLOAD
--From 'SimulatedWorkloads\OVERVIEW', start Scenario.cmd to generate some background workload.
--Mapping between the physical numa configuration and the sql server scheduler ids:
SELECT osn.memory_node_id AS [numa_node_id], sc.cpu_id, sc.scheduler_id
FROM sys.dm_os_nodes AS osn
INNER JOIN sys.dm_os_schedulers AS sc ON osn.node_id = sc.parent_node_id 
WHERE sc.scheduler_id < 1048576;
GO

--Get the scheduler affinity mask per node
DECLARE @cpuaffin VARCHAR(255), @cpucount int, @numa int
DECLARE @i int, @cpuaffin_fixed VARCHAR(300)
SELECT @cpucount = COUNT(cpu_id) FROM sys.dm_os_schedulers WHERE scheduler_id < 255 AND parent_node_id < 64
SELECT @numa = COUNT(DISTINCT parent_node_id) FROM sys.dm_os_schedulers WHERE scheduler_id < 255 AND parent_node_id < 64;

;WITH bits AS 
(SELECT 7 AS N, 128 AS E UNION ALL SELECT 6, 64 UNION ALL 
SELECT 5, 32 UNION ALL SELECT 4, 16 UNION ALL SELECT 3, 8 UNION ALL 
SELECT 2, 4 UNION ALL SELECT 1, 2 UNION ALL SELECT 0, 1), 
bytes AS 
(SELECT 1 M UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL 
SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9)
-- CPU Affinity is shown highest to lowest CPU ID
SELECT @cpuaffin = CASE WHEN [value] = 0 THEN REPLICATE('1', @cpucount)
	ELSE RIGHT((SELECT RIGHT(((CONVERT(tinyint, SUBSTRING(CONVERT(binary(9), [value]), M, 1)) & E ) / E),16) AS [text()] 
		FROM bits CROSS JOIN bytes
		ORDER BY M, N DESC
		FOR XML PATH('')), (SELECT COUNT(DISTINCT cpu_id) FROM sys.dm_os_schedulers)) END
FROM sys.configurations 
WHERE name = 'affinity mask';

SET @cpuaffin_fixed = @cpuaffin
-- format binary mask by node for better reading
SET @i = @cpucount/@numa + 1
WHILE @i <= @cpucount
BEGIN
	SELECT @cpuaffin_fixed = STUFF(@cpuaffin_fixed, @i, 1, '_' + SUBSTRING(@cpuaffin, @i, 1))
	SET @i = @i + @cpucount/@numa + 1
END
SELECT @cpuaffin_fixed AS 'processor_affinity_mask'
GO
 
--Witness the per scheduler impact        
SELECT scheduler_id, cpu_id, status, is_online, current_tasks_count, 
runnable_tasks_count, active_workers_count, pending_disk_io_count
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE'
GO
 
--Witness the per numa node impact
SELECT osn.memory_node_id AS [numa_node_id], SUM(sc.active_workers_count) AS active_count
FROM sys.dm_os_nodes AS osn
INNER JOIN sys.dm_os_schedulers AS sc ON osn.node_id = sc.parent_node_id 
WHERE sc.status = 'VISIBLE ONLINE' AND sc.scheduler_id < 1048576
GROUP BY osn.memory_node_id
GO
 
--Details of what is being executed via sys.dm_exec_requests        
SELECT a.session_id, a.status, wg.name, a.scheduler_id, b.node_affinity, c.host_name, c.program_name, c.login_name, c.is_user_process, c.group_id
FROM sys.dm_exec_requests a
JOIN sys.dm_exec_connections b ON a.session_id = b.session_id  
JOIN sys.dm_exec_sessions c ON c.session_id = a.session_id 
JOIN sys.dm_resource_governor_workload_groups wg ON c.group_id = wg.group_id
ORDER BY status
GO

--Also show execution of CoreInfo by sysinternals (https://technet.microsoft.com/en-us/sysinternals/cc835722.aspx)
--Coreinfo.exe –m for NUMA speeds



/*Map soft-NUMA nodes to CPUs
Using the Registry Editor program (regedit.exe), add the following registry keys to map soft-NUMA node 0 to CPUs 1 and 2, 
soft-NUMA node 1 to CPUs 3 and 4, and soft-NUMA node 2 to CPUs 5, 6, 7, and 8./*

SQL Server 2005   
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\90\NodeConfiguration\Node0
 
Type - DWORD
Value name - CPUMask
Value data - 0x03
  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\90\NodeConfiguration\Node1

Type - DWORD
Value name - CPUMask
Value data - 0x0c
  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\90\NodeConfiguration\Node2

Type - DWORD
Value name - CPUMask
Value data - 0xf0
 





