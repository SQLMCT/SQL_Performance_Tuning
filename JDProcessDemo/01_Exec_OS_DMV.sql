SELECT *
FROM sys.dm_exec_connections as c
JOIN sys.dm_exec_sessions as s
	ON c.session_id = s.session_id
JOIN sys.dm_exec_requests as r
	ON s.session_id = r.session_id
JOIN sys.dm_os_tasks as t
	ON r.session_id = t.session_id
JOIN sys.dm_os_workers as w
	ON t.task_address = w.task_address
