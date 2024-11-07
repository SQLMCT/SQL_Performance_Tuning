-- Using DMVs to see sessions currently executing.

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

/* This Sample Code is provided for the purpose of illustration only and is not intended
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys fees, that arise or
result from the use or distribution of the Sample Code.*/