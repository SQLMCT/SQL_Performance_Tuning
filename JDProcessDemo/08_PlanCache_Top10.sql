SELECT TOP 10 
qt.TEXT, qp.query_plan,
qs.execution_count,
qs.total_logical_reads, 
qs.total_logical_writes, 
qs.total_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_execution_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC 