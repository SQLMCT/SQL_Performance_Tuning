--TempDB Metadeta cache demonstration

--Step 1: Open Windows Performance Monitor
--Watch %ProcessorTime

--Step 2: Create Database and TempTable
USE MASTER;
GO
DROP DATABASE IF EXISTS PressureDemo;
GO
CREATE DATABASE PressureDemo;
GO
USE PressureDemo;
GO
CREATE OR ALTER PROCEDURE jd_temp_demo
AS
CREATE TABLE #This_Table (col1 INT);
GO

--Step 3: Run the following in a command prompt under C:\temp
--OSTRESS -E -S.\JDSQL19 -i"tempstress.sql" -n100 -r5000 -dPressureDemo -o"Temp01"

--Step 4: Check current activity of TempDB
USE master;
GO
SELECT 
er.session_id, er.wait_type, er.wait_resource,
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

--Step 5: Observe the total duration of the workload
--OSTRESS exiting normally, elapsed time: hh:mm:ss.ms

--Step 6: Turn on Memory_Optimized TempDB_MetaData 
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
GO

--Step 7: Restart SQL Server
--Required to enable Memory_Optimized TempDB_MetaData 

--Step 8: Run the following in a command prompt under C:\temp
--OSTRESS -E -S.\JDSQL19 -i"tempstress.sql" -n100 -r5000 -dPressureDemo -o"Temp01"

--Step 9: Open Windows Performance Monitor
--Watch %ProcessorTime Again

--Step 10: Check current activity of TempDB
USE master;
GO
SELECT 
er.session_id, er.wait_type, er.wait_resource,
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

--Step 11: Look for memory_optimized tables
USE tempdb;
go
SELECT OBJECT_NAME(object_id) as [object_name], * FROM sys.dm_db_xtp_object_stats;
go

--Step 12: Observe the total duration of the workload
--OSTRESS exiting normally, elapsed time: hh:mm:ss.ms

--Step 13: Turn on Memory_Optimized TempDB_MetaData 
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = OFF;
GO

--Step 14: Restart SQL Server
--Required to enable Memory_Optimized TempDB_MetaData 