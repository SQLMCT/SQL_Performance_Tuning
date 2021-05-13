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
 

