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

--Clear Stats
--DBCC SQLPERF("sys.dm_os_wait_stats" , CLEAR)
--Waiting tasks

SELECT w.session_id, w.wait_duration_ms, w.wait_type,
     w.blocking_session_id, w.resource_description,
	 s.program_name, t.text, t.dbid, s.cpu_time,
	 s.memory_usage
 FROM sys.dm_os_waiting_tasks as w
      INNER JOIN sys.dm_exec_sessions as s
         ON w.session_id = s.session_id
      INNER JOIN sys.dm_exec_requests as r 
         ON s.session_id = r.session_id
      OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) as t
  WHERE s.is_user_process = 1;

  
--signal_wait_time percentage_calculation 
SELECT signalwaittimems = Sum(signal_wait_time_ms), 
       '%signal waits' = Cast(100.0 * Sum(signal_wait_time_ms) / Sum(wait_time_ms) AS NUMERIC(20,2)), 
       resourcewaittimems = Sum(wait_time_ms - signal_wait_time_ms), 
       '%resource waits' = Cast(100.0 * Sum(wait_time_ms - signal_wait_time_ms) / Sum(wait_time_ms) AS NUMERIC(20,2)) 
FROM   sys.dm_os_wait_stats

--Track a specific wait type
SELECT  wait_type, 
        waiting_tasks_count, 
        wait_time_ms
FROM	sys.dm_os_wait_stats
WHERE	wait_type LIKE 'PAGEIOLATCH%'  
ORDER BY wait_type

-- Show only wait stats that have an avg of 10ms or higher
-- orderd by count
--
select wait_type, waiting_tasks_count, wait_time_ms/waiting_tasks_count as avg_wait_time_ms
from sys.dm_os_wait_stats
where waiting_tasks_count > 0
and wait_time_ms/waiting_tasks_count >- 10
order by waiting_tasks_count desc
go


/* WAIT STAT DELTAS
   Generate a query plan for AdventureWorks
*/
USE AdventureWorks2016
SELECT 
[ProductID], [SalesOrderID], [CarrierTrackingNumber], [OrderQty], [SpecialOfferID],
[UnitPrice], [UnitPriceDiscount], [LineTotal],[rowguid], [ModifiedDate]
FROM [Sales].[SalesOrderDetail]
GO 3

--Show wait stats
SELECT * FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'DIRTY_PAGE_POLL')
ORDER BY [wait_time_ms] DESC;
GO

-- Isolate top waits for server instance since last restart or statistics clear
SELECT 
wait_type AS [Wait Type], 
wait_time_ms / 1000. AS [Wait Time (s)],
CONVERT(DECIMAL(12,2), wait_time_ms * 100.0 / SUM(wait_time_ms) OVER()) as [Wait Time %]
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'DIRTY_PAGE_POLL')
AND waiting_tasks_count > 0
ORDER BY [Wait Time %] DESC
GO

--Wait Stats over time
--Capture point in time
SELECT wait_type,
	   waiting_tasks_count,
	   wait_time_ms,
	   max_wait_time_ms,
	   signal_wait_time_ms
INTO #InitialWaitStatsSnap
FROM sys.dm_os_wait_stats;

--Wait for X amount of time
WAITFOR DELAY '00:00:02';

--Collect again
SELECT wait_type,
	   waiting_tasks_count,
	   wait_time_ms,
	   max_wait_time_ms,
	   signal_wait_time_ms
INTO #CurrentWaitStatsSnap
FROM sys.dm_os_wait_stats;

--Compare the results
SELECT c.wait_type as [Wait Type],
	   (c.wait_time_ms - i.wait_time_ms) AS [Total Wait (ms)],
	   CONVERT(DECIMAL(12,2), (c.wait_time_ms - i.wait_time_ms) * 100.0 / SUM(c.wait_time_ms - i.wait_time_ms) OVER()) as [Wait Time %]
FROM #InitialWaitStatsSnap i
INNER JOIN #CurrentWaitStatsSnap c
	ON c.wait_type = i.wait_type
WHERE c.wait_time_ms > i.wait_time_ms 
AND c.wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
						'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
						'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
						'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
						'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
						'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'DIRTY_PAGE_POLL')
ORDER BY c.wait_time_ms DESC





