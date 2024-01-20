USE master;
GO

-- # 1 Review the current executions, review the sessions in suspended state and the assciated wait type and wait duration
SELECT 
er.session_id, er.status, er.wait_type, er.wait_resource, er.wait_time,
er.blocking_session_id, er.command,
SUBSTRING(st.text, (er.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
        WHEN -1 THEN DATALENGTH(ST.text)  
        ELSE er.statement_end_offset END   
            - er.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_requests  as er
  INNER JOIN sys.dm_exec_sessions as es on er.session_id=es.session_id
  CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as st
WHERE es.is_user_process=1
GO

-- # 2 Use the newest DMVs to obtain the detail of the object allocation contention by decompose the data page and its associated database object.
SELECT 
er.session_id, er.status, er.wait_type, er.wait_resource, er.wait_time,
OBJECT_NAME(page_info.[object_id],page_info.[database_id]) as [object_name], 
er.blocking_session_id, er.command,
SUBSTRING(st.text, (er.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
        WHEN -1 THEN DATALENGTH(ST.text)  
        ELSE er.statement_end_offset END   
            - er.statement_start_offset)/2) + 1) AS statement_text,
			page_info.database_id,
			page_info.[file_id],
			page_info.page_id,
			page_info.[object_id],
			page_info.index_id,
			page_info.page_type_desc
FROM sys.dm_exec_requests AS er
  CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as st
  CROSS APPLY sys.fn_PageResCracker(er.page_resource) AS r
  CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id,'DETAILED') AS page_info;
GO

