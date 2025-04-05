-- Clear Stats
--DBCC SQLPERF("sys.dm_os_wait_stats" , CLEAR)

-- Open Blocking_1.sql and Execute Query
-- Open Blocking_2.sql and Execute Query

-- Waiting tasks
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
WHERE s.is_user_process = 1 


-- To see history of waits stats
SELECT * FROM sys.dm_os_wait_stats

/* Signal_wait_time percentage_calculation 
** Signal wait time is the time a task waits to be signaled there is a CPU ready to execute its task
** Resource wait time is the time spent waiting on things like IO, network etc.
** If the percentage of signal wait time is high, there may be CPU pressure
*/

SELECT signalwaittimems    = SUM(signal_wait_time_ms)
       ,'%signal waits'    = CAST(100.0 * SUM(signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2))
       ,resourcewaittimems = SUM(wait_time_ms - signal_wait_time_ms)
       ,'%resource waits'  = CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2))
FROM
  sys.dm_os_wait_stats; 


--Track a specific wait type
SELECT wait_type
       ,waiting_tasks_count
       ,wait_time_ms
FROM
  sys.dm_os_wait_stats
WHERE  wait_type LIKE 'PAGEIOLATCH%'
ORDER  BY
  wait_type; 


-- Show only wait stats that have an avg of 10ms or higher
-- ordered by count
--
SELECT wait_type
       ,waiting_tasks_count
       ,wait_time_ms / waiting_tasks_count AS avg_wait_time_ms
FROM
  sys.dm_os_wait_stats
WHERE  waiting_tasks_count > 0
       AND wait_time_ms / waiting_tasks_count >= 10
ORDER  BY
  waiting_tasks_count DESC;
go 

-- Isolate top waits for server instance since last restart or statistics clear
SELECT wait_type                                                 AS [Wait Type]
       ,wait_time_ms / 1000.                                     AS [Wait Time (s)]
       ,CONVERT(DECIMAL(12, 2), wait_time_ms * 100.0 / SUM(wait_time_ms)
                                                         OVER()) AS [Wait Time %]
FROM
  sys.dm_os_wait_stats
WHERE  wait_type NOT IN ( 'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
                          'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
                          'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
                          'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
                          'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
                          'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'DIRTY_PAGE_POLL' )
       AND waiting_tasks_count > 0
ORDER  BY
  [Wait Time %] DESC;
GO 

 
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