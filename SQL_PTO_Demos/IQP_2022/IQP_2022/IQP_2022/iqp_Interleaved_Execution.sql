/*Interleaved Execution Demo */

/* Change compatibility level to show previous behavior. */

USE [master]
GO
ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 130;
GO

USE AdventureWorks2019;
GO
SET NOCOUNT ON;


/* Check the current compatibility level */
SELECT compatibility_level 
FROM sys.databases WHERE database_id = DB_ID();
GO

/* Check whether interleaved execution is enabled */
SELECT name, value
FROM sys.database_scoped_configurations
WHERE name = N'INTERLEAVED_EXECUTION_TVF';
GO

DROP TABLE IF EXISTS dbo.Person
GO
/* Create a copy of the Person table without the XML columns */
SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName,
       LastName, Suffix, EmailPromotion, rowguid, ModifiedDate
INTO dbo.Person
FROM Person.Person;
GO
CREATE CLUSTERED INDEX PK_Person ON dbo.Person (BusinessEntityID);
GO
CREATE NONCLUSTERED INDEX ix_LastFirst_Middle ON dbo.Person (LastName, FirstName) INCLUDE (MiddleName);
GO

/*****************************************************************************/

/* Create a multistatement table valued function that's going to return
	a lot of rows */

CREATE OR ALTER FUNCTION dbo.getPersons ()
RETURNS @returntable TABLE ( BusinessEntityID INT, LastName NVARCHAR(25), FirstName NVARCHAR(25))
AS
BEGIN
    INSERT @returntable
    SELECT TOP ( 12345 ) BusinessEntityID, LastName, FirstName
    FROM dbo.Person;

    RETURN;
END
GO

/* Clear procedure cache and turn on STATISTICS IO */

SET STATISTICS IO ON;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/* Turn on the option to Include Actual Query Plan (Ctrl+M) */

/* Execute a test query */ 
SELECT DISTINCT p.Title, b.LastName, b.FirstName
FROM dbo.Person p
     INNER JOIN dbo.getPersons() b ON b.BusinessEntityID = p.BusinessEntityID;
GO

/*	The MS TVF and dbo.Person are joined using a Nested Loops join 
	because the	estimated row count for the MS TVF is only 100 rows.

	Unfortunately, the actual row count is 12345, so this a very 
	expensive way to join the 2 tables as it requires 12345 lookups 
	into the clustered index.

	Notice that the plan includes a Sort operator.  DISTINCT requires 
	that the data be ordered to exclude duplicate values.  
	Also notice that we've got a sort warning.  Because of the low 
	estimated row count we weren't allocated adequate memory to sort 
	the output of the Nested Loops join in memory, so it had to do 
	some of the work of sorting on disk adding physical I/O to the 
	query execution.  I/O is slow, physical I/O is really slow.

	---------------------------------------------------------------------------

	If you aren't yet on SQL Server 2017, try to address problematic 
	MS TVFs by	leveraging CTEs, views or temp tables instead - or by
	replacing them with inline TVFs.  */

/* ---------------------------------------------------------------------------
	Let's jump up to the 2017 compatibility level then 
	try the test query again...
*/

ALTER DATABASE AdventureWorks2019 SET COMPATIBILITY_LEVEL = 140;
GO

SELECT DISTINCT p.Title, b.LastName, b.FirstName
FROM dbo.Person p
     INNER JOIN dbo.getPersons() b ON b.BusinessEntityID = p.BusinessEntityID;
GO

/*
	Looking at the estimated and actual row counts for the Table scan we 
	find that they're both 12345!  This is Interleaved Execution in action.
	The higher estimated row count leads the Optimizer to use a hash match
	join (a cheaper	choice) and to request a larger memory grant so 
	we don't spill to disk this	time.  

	Another indication that the Optimzer knows we're working with higher
	row counts is the use of a Hash Match (Aggregate) operator to do the
	DISTINCT work. This is a more efficient means of sorting large amounts
	of data.*/

/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/