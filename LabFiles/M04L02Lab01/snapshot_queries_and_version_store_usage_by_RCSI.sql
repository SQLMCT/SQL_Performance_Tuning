Use master
go
Select 'Tempdbusage'  
go
SELECT  SS.session_id ,        SS.database_id , db_name(SS.database_id) DatabaseName, T.text [Query Text],
        CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation User Objects MB] ,
        CAST(( SS.user_objects_alloc_page_count
               - SS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects MB] ,
        CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation Internal Objects MB] ,
        CAST(( SS.internal_objects_alloc_page_count
               - SS.internal_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Net Allocation Internal Objects MB] ,
        CAST(( SS.user_objects_alloc_page_count
               + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15, 2)) [Total Allocation MB] ,
        CAST(( SS.user_objects_alloc_page_count
               + SS.internal_objects_alloc_page_count
               - SS.internal_objects_dealloc_page_count
               - SS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15, 2)) [Net Allocation MB] 
 
FROM    sys.dm_db_session_space_usage SS
        LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
        OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T
	  where ss.session_id>50
go
USE AdventureworksPTO
GO
-------------------------------------
--Determining the Longest Running Transaction
Select 'Active Database snapshot  Transaction with Longest Running queries'
go
SELECT transaction_id,  T.text [Query Text],is_snapshot,first_snapshot_sequence_num,
max_version_chain_traversed,
average_version_chain_traversed,
elapsed_time_seconds
FROM sys.dm_tran_active_snapshot_database_transactions ST
   LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = ST.session_id
        OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T
ORDER BY elapsed_time_seconds DESC;
---------Version store and space usage by Adventureworks
----Over period of time space usage can grow or shrink by versions
Select 'Version store usage by Databases'
GO
SELECT 
  DB_NAME(database_id) as 'Database Name',
  reserved_page_count,
  reserved_space_kb
FROM sys.dm_tran_version_store_space_usage 
where db_name(database_id)='AdventureWorksPTO'
-----version store details ---
Select 'Version store Details'
go
SELECT  
*
  FROM sys.dm_tran_version_store 
  ---
