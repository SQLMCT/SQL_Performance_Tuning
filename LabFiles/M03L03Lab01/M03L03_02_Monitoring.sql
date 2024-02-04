/* 
This Sample Code is provided for the purpose of illustration only and is not intended
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or
result from the use or distribution of the Sample Code.
*/

-- #1 Start the scenario
--From 'E:\LabFiles\M02L03Lab01', start M02L03_01_Scenario.bat to generate some OLTP background workload. 

-- During the day the application loads high amounts of data as part of a batch process.
-- The batch process has increased the number of processed records over the last weeks and it takes to long to finish.
-- Investigate the problem.

-- #2 Review the exec requests and notice the sessions in suspended state.
SELECT 
er.session_id, er.status, er.wait_type, er.wait_resource, er.wait_time,
er.blocking_session_id, er.command,
SUBSTRING(st.text, (er.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
        WHEN -1 THEN DATALENGTH(ST.text)  
        ELSE er.statement_end_offset END   
            - er.statement_start_offset)/2) + 1) AS statement_text,er.*
FROM sys.dm_exec_requests  as er
  INNER JOIN sys.dm_exec_sessions as es on er.session_id=es.session_id
  CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as st
WHERE es.is_user_process=1 and er.session_id<>@@SPID
GO


-- #3 Open M02L03_03_view_Waits.sql and review the waits over the last 30 sec.
-- What is the most notable wait type?
-- You will see the following wait types on TOP, lest investigate more about WRITELOG

--CXPACKET
--WRITELOG


-- #4 Analyze Pending IOS
-- View pending IOs, execute the following query multiple times and observe the pending requests and the io_pending_ms_ticks.
SELECT iop.io_type, iop.io_pending, iop.io_pending_ms_ticks, iop.io_completion_request_address, iop.io_handle, iop.scheduler_address, DB_NAME(vfs.database_id) AS database_name, 
	smf.name AS logical_filename, smf.physical_name AS physical_filename, 
	vfs.io_stall_read_ms, vfs.io_stall_write_ms, vfs.io_stall
FROM sys.dm_io_pending_io_requests iop
INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) vfs ON iop.io_handle = vfs.file_handle
INNER JOIN sys.master_files smf ON vfs.database_id = smf.database_id AND vfs.file_id = smf.file_id
GO

-- Check the physical file name and start performance counters to measure the physical disk.


-- #5 Open E:\LabFiles\M02L03Lab01\M02L03_04_PerfCounters_LogFile.PerfmonCfg and review the performance metrics for disk G:\

-- What is the average size of the individual disk requests (IO size) in bytes?
-- Avg. Disk Bytes/Write is in avg 4kb, we should expect this counter close to 60kb for data loading processes, this could mean that a lot of small write transactions are running

-- Write Transactions/sec shows in average 800 transactions that are written to the database and committed, in the last second.

-- Review the write latency for the drive G:\ where is stored the Log File for the AdventureworksPTO database
--Avg. Disk sec/Write


-- #6 Open E:\LabFiles\M02L03Lab01\M02L03_05_PerfCounters_DataFile.PerfmonCfg and review the performance metrics for disk F:\
-- What is the latency for drive F.\ ?

--
-- How could you improve performance?
--