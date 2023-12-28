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


SELECT * FROM sys.dm_os_wait_stats

/* Signal_wait_time percentage_calculation 
** Signal wait time is the time a task waits to be signalled there is a CPU ready to execute its task
** Resource wait time is the time spent waiting on things like IO, network etc.
** If the percentage of signal wait time is high, there may be CPU pressure
*/

SELECT signalwaittimems    = SUM(signal_wait_time_ms)
       ,'%signal waits'    = CAST(100.0 * SUM(signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2))
       ,resourcewaittimems = SUM(wait_time_ms - signal_wait_time_ms)
       ,'%resource waits'  = CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2))
FROM
  sys.dm_os_wait_stats; 


-- Tracking a specific wait type
SELECT wait_type
       ,waiting_tasks_count
       ,wait_time_ms
FROM
  sys.dm_os_wait_stats
WHERE  wait_type LIKE 'PAGEIOLATCH%'
ORDER  BY
  wait_type; 

 

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