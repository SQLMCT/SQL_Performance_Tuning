Use master
go
SELECT 	  CASE 
			WHEN er.session_id IS NULL THEN es.session_id
			ELSE er.session_id
		  END AS session_id
		, er.blocking_session_id
		, er.wait_time
		, er.wait_resource
		, er.wait_type
		, er.last_wait_type
		, er.status
		, CASE 
			WHEN er.session_id IS NULL THEN (SELECT text 
											 FROM sys.dm_exec_sql_text(ec.most_recent_sql_handle))
			ELSE (SELECT text 
				  FROM sys.dm_exec_sql_text(er.sql_handle))
		  END AS QueryText
FROM sys.dm_exec_connections ec 
	JOIN sys.dm_exec_sessions es 
		ON ec.session_id = es.session_id
	LEFT JOIN sys.dm_exec_requests er 
		ON es.session_id = er.session_id
WHERE	er.blocking_session_id > 0 
		OR 
		es.session_id IN (SELECT blocking_session_id 
						  FROM sys.dm_exec_requests 
						  WHERE blocking_session_id > 0)
