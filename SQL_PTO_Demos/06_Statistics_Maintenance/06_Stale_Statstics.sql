USE AdventureWorks2019
GO

SELECT DB_NAME() AS DatabaseName, SCHEMA_NAME(T.[schema_id]) AS SchemaName,
	T.name AS TableName,IX.name AS IndexName,
	STATS_DATE(IX.id,IX.indid) AS 'StatsLastUpdate', 
	IX.rowcnt AS 'RowCount',
	IX.rowmodctr AS '#RowsChanged',
	CAST((CAST(IX.rowmodctr AS DECIMAL(20,8))/CAST(IX.rowcnt AS DECIMAL(20,2)) * 100.0)
		AS DECIMAL(20,2)) AS '%RowsChanged'
FROM sys.sysindexes AS IX
	INNER JOIN sys.tables AS T ON T.[object_id] = IX.[id]
WHERE IX.id > 100 -- excluding system object statistics
	AND IX.indid > 0 -- excluding heaps or tables that do not any indexes
	AND IX.rowcnt >= 500 -- only indexes with more than 500 rows
ORDER BY  [%RowsChanged] DESC

--Cause a Stat Update
SELECT LastName, FirstName, MiddleName FROM Person.Person
WHERE LastName = 'Deardurff'