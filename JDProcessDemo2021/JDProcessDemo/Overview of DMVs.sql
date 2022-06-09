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

/*List of DMVs related to SQLOS*/
-- This is a partial list
-- To display a list for any sub-system using the script
-- Find DMV Names.sql in the E:\Demos\M01L01Demo01 folder
select cpu_count, hyperthread_ratio, socket_count, cores_per_socket,
hyperthread_ratio/cores_per_socket as HTperCore
from sys.dm_os_sys_info

select * from sys.dm_os_schedulers
select * from sys.dm_os_waiting_tasks
select * from sys.dm_os_wait_stats
select * from sys.dm_os_threads
select * from sys.dm_os_virtual_address_dump
select * from sys.dm_os_latch_stats
select * from sys.dm_os_hosts
select * from sys.dm_os_buffer_descriptors
select * from sys.dm_os_performance_counters
select * from sys.dm_os_ring_buffers
select * from sys.dm_os_tasks
select * from sys.dm_os_workers

-- these will be addressed in the Memory Module of the course
select * from sys.dm_os_memory_clerks
select * from sys.dm_os_memory_cache_counters
select * from sys.dm_os_memory_cache_clock_hands
select * from sys.dm_os_memory_cache_hash_tables
select * from sys.dm_os_memory_cache_entries

/*Other useful DMVs containing SQL Server information*/
select * from sys.dm_os_windows_info
select * from sys.dm_server_registry

-- use numa_node_count from sys.dm_os_sys_info
select * from sys.dm_os_sys_info
select * from sys.dm_server_services
select * from sys.dm_server_memory_dumps

