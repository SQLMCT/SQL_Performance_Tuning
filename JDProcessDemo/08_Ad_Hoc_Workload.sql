SET NOCOUNT ON;

-- Disable the "optimize for ad hoc workload" server configuration option
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
-- NEW SYNTAX:
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZE_FOR_AD_HOC_WORKLOADS = OFF;
-- OLD SYNTAX:
EXEC sp_configure 'Optimize for ad hoc workload', 0;
RECONFIGURE;
GO


/*
	Optimize for ad hoc workload prevents caching of plans the first time a
	query is executed.  It applies to *all* statements, not just ad hoc SQL.

	It's generally recommended that it be enabled on your servers to prevent
	bloating of the plan cache by single-use ad hoc queries, but it	complicates 
	demonstrations (as you have to execute all your queries at least twice to 
	get them into the cache) so we're disabling it here.
*/

/*****************************************************************************/

-- Clear the plan cache for this database only, execute four very similar ad hoc 
-- SQL statements then take a look at the plan cache contents

USE AdventureWorks2016
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SELECT p.LastName, p.MiddleName, p.FirstName, e.NationalIDNumber
FROM Person.Person p INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName LIKE N'M%';	/* baseline */
GO

SELECT p.LastName, p.MiddleName, p.FirstName, e.NationalIDNumber
FROM Person.Person p INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.lastname LIKE N'M%';	/* lower case column name (lastname) */
GO 

SELECT p.LastName, p.MiddleName, p.FirstName, e.NationalIDNumber
FROM Person.Person p INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName LIKE	N'M%';	/* extra white space after LIKE */
GO 

SELECT p.LastName, p.MiddleName, p.FirstName, e.NationalIDNumber
FROM Person.Person p INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName LIKE N'Mil%';	/* different literal value */
GO 

-- What's in the plan cache? 
SELECT p.objtype, p.size_in_bytes, OBJECT_SCHEMA_NAME(st.objectid) + N'.' + OBJECT_NAME(st.objectid) AS object_name, st.text,
    qs.query_hash, qs.sql_handle, qs.query_plan_hash, qs.execution_count AS exec_count,
    qs.total_worker_time / ( qs.execution_count * 1000 ) AS avg_CPU_ms,
    ( qs.total_elapsed_time / ( qs.execution_count * 1000 )) AS avg_time_ms,
    ( qs.total_logical_reads / qs.execution_count ) AS avg_logical_reads,
    qp.query_plan
FROM sys.dm_exec_cached_plans p 
	 INNER JOIN sys.dm_exec_query_stats qs ON qs.plan_handle = p.plan_handle
     CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
     CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE st.dbid = DB_ID() AND st.text LIKE N'%NationalIdNumber%'
OPTION ( RECOMPILE );	/* prevents the query plan for this statement from being cached*/
GO

/*
	There are 4 entries in the plan cache, one for each of the SELECTs - and each
	was executed just once.  An accumulation of many such single-use plans bloats 
	the plan cache and can reduce the size of the buffer pool.

	Any small difference in the statement text - case, white space, literals - 
	prevents plan reuse since a hash of the statement won't match that for SQL
	associated with previously cached plans.  
*/

/*****************************************************************************/

-- Now create a stored procedure that executes the same query, but substitutes a
-- parameter for the literal search terms
CREATE OR ALTER PROC dbo.GetPersonInfo (@last_name_partial NVARCHAR(50))
AS
BEGIN
	SELECT p.LastName, p.FirstName, e.NationalIDNumber
	FROM Person.Person p INNER JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
	WHERE p.LastName LIKE  @last_name_partial + N'%';
END
GO

/*
	Note that since the text of the query is fixed in a stored procedure variations
	in case and white space can't interfere with plan reuse.

	The use of parameters instead of literals in stored procedures also facilitates
	reuse.  They same is true of prepared and parameterized SQL statements.

	Execute the stored procedure passing in the same test values we used above, 
	then check the plan cache contents again.
*/

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

EXEC dbo.GetPersonInfo @last_name_partial = 'M'
GO
EXEC dbo.GetPersonInfo @last_name_partial = 'm'
GO
EXEC dbo.GetPersonInfo @last_name_partial = 'Mil'
GO

SELECT p.objtype, p.size_in_bytes, OBJECT_SCHEMA_NAME(st.objectid) + N'.' + OBJECT_NAME(st.objectid) AS object_name, st.text,
    qs.query_hash, qs.query_plan_hash, qs.execution_count AS exec_count,
    qs.total_worker_time / ( qs.execution_count * 1000 ) AS avg_CPU_ms,
    ( qs.total_elapsed_time / ( qs.execution_count * 1000 )) AS avg_time_ms,
    ( qs.total_logical_reads / qs.execution_count ) AS avg_logical_reads,
    qp.query_plan
FROM sys.dm_exec_cached_plans p 
	 INNER JOIN sys.dm_exec_query_stats qs ON qs.plan_handle = p.plan_handle
     CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
     CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE st.dbid = DB_ID() AND st.text LIKE N'%NationalIdNumber%'
OPTION ( RECOMPILE );
GO

/*
	This time there's only one entry in the cache - it's for our stored procedure
	and shows an exec_count value of 3 - we reused the plan saving time and CPU!  

	The downside of plan caching and reuse is that the cached plan may not be 
	optimimal for the full range of parameters used.

	The cached plan is optimized for whichever parameter values were used the 
	first time the stored proc was executed.  The Optimizer's ability to see
	these parameters is referred to as "parameter sniffing", and more often
	than not this is a good thing.

	We'll look at how parameter sniffing can be problematic in the next demo.
*/

/*****************************************************************************/

-- Clean up
DROP PROC dbo.GetPersonInfo;

-- Reenable this option
-- NEW SYNTAX:
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZE_FOR_AD_HOC_WORKLOADS = ON;
-- OLD SYNTAX:
EXEC sp_configure 'Optimize for ad hoc workload', 1;
RECONFIGURE;
GO




