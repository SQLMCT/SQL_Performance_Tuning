-- Cumulative waits from server restart
-- Need to take snapshots and then calculate the Difference
select * from sys.dm_os_wait_stats
order by wait_time_ms desc


-- Example of taking snapshots one minute apart.
DROP TABLE IF EXISTS [#temp]
GO
select getdate() as Runtime, * into #temp from sys.dm_os_wait_stats 
go
waitfor delay '00:01:00'
go
insert into [#temp] (Runtime,wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,signal_wait_time_ms)
select getdate() as RunTime,wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,signal_wait_time_ms from sys.dm_os_wait_stats
go


--- This query will give you the difference in the Waitstats from max snapshot tot he Min snapshot
SELECT MAX(runtime) as StarTime,MIN(runtime) as EndTime, datediff(second,min(runtime),max(runtime)) as Diff_in_seconds 
FROM #temp

Print '**** Server-level waitstats during the data capture *******'
Print '';
WITH WaitCategoryStats (runtime, wait_category, wait_type, wait_time_ms, waiting_tasks_count, max_wait_time_ms) AS 
( SELECT runtime, 
  CASE 
      WHEN wait_type LIKE 'LCK%' THEN 'LOCKS'
	  WHEN wait_type LIKE 'PAGEIO%' THEN 'PAGE I/O LATCH'
	  WHEN wait_type LIKE 'PAGELATCH%' THEN 'PAGE LATCH (non-I/O)'
	  WHEN wait_type LIKE 'LATCH%' THEN 'LATCH (non-buffer)'
	  WHEN wait_type LIKE 'LATCH%' THEN 'LATCH (non-buffer)'
	  ELSE wait_type 
  END AS wait_category, wait_type, wait_time_ms, waiting_tasks_count, max_wait_time_ms
FROM #temp
)
SELECT TOP 15 
  wait_category
    , MAX(wait_time_ms) - MIN(wait_time_ms) as wait_time_ms
    , (MAX(wait_time_ms) - MIN(wait_time_ms)) / (1 + datediff (s, MIN(runtime), MAX(runtime))) as wait_time_ms_per_sec
	, MAX(waiting_tasks_count) max_waiting_tasks
	, (MAX(wait_time_ms) - MIN(wait_time_ms))/ Case (MAX(waiting_tasks_count) - MIN(waiting_tasks_count)) 
	     WHEN 0 THEN 1 ELSE ((MAX(waiting_tasks_count) - MIN(waiting_tasks_count))) 
	    END AS average_wait_time_ms
	, MAX(max_wait_time_ms) AS max_Wait_time_ms
FROM WaitCategoryStats
WHERE runtime IN ( (SELECT MAX(runtime) from #temp),(SELECT MIN(runtime) FROM #temp))
 AND wait_type NOT IN ('WAITFOR', 'LAZYWRITER_SLEEP', 'SQLTRACE_BUFFER_FLUSH', 'CXPACKET', 'EXCHANGE', 
    'REQUEST_FOR_DEADLOCK_SEARCH', 'KSOURCE_WAKEUP', 'BROKER_TRANSMITTER', 'BROKER_EVENTHANDLER', 'ONDEMAND_TASK_QUEUE', 
    'CHKPT', 'DBMIRROR_WORKER_QUEUE', 'DBMIRRORING_CMD', 'DBMIRROR_DBM_EVENT', 'XE_DISPATCHER_WAIT', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
	'ASYNC_NETWORK_IO', 'PREEMPTIVE_OS_WAITFORSINGLEOBJECT', 'DIRTY_PAGE_POLL', 'LOGMGR_QUEUE', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
	'XE_TIMER_EVENT', 'CHECKPOINT_QUEUE', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION', 'SLEEP_TASK', 'BROKER_TO_FLUSH', 'SOS_SCHEDULER_YIELD')
GROUP BY wait_category
ORDER BY wait_time_ms_per_sec DESC


-- Examine waiting tasks

select session_id,wait_type,wait_duration_ms,resource_description,blocking_session_id,*
from sys.dm_os_waiting_tasks
where wait_type like 'PAGELATCH%'




