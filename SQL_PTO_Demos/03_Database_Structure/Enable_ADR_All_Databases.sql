/* 
** Declare variable to hold the name of each database.
** Declare variable to hold the SQL Statement to execute.
*/

DECLARE @name VARCHAR(50) 
DECLARE @SQL NVARCHAR(100)

/*
** Create cursor to hold the names of all user databases
** excluding any system databases
*/

DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb')

/*
** Open cursor to populate database name.
** Create SQL Statement to enable ACCELERATED_DATABASE_RECOVERY.
** Execute SQL Statement with sp_executesql.
*/

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER DATABASE [' + @name + '] SET ACCELERATED_DATABASE_RECOVERY = ON;'
    EXEC sp_executesql @SQL

    FETCH NEXT FROM db_cursor INTO @name
END

/*
** Close and Deallocate cursor.
*/
CLOSE db_cursor
DEALLOCATE db_cursor
