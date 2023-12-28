--First identify the Query Store query_id of the query statement you with to modify.

-- Adding a query store hints.
EXEC sys.sp_query_store_set_hints @query_id = 51, @query_hints = N'OPTION(RECOMPILE)';

--Updatig or adding additional query store hints.
EXEC sys.sp_query_store_set_hints @query_id = 51, 
	@query_hints = N'OPTION(RECOMPILE, MAXDOP 8, USE HINT(''DISALLOW_BATCH_MODE''))';

--Removing query store hints.
EXEC sys.sp_query_store_clear_hints @query_id = 51;

--Viewing configured query store hints.
SELECT * FROM sys.query_store_query_hints
