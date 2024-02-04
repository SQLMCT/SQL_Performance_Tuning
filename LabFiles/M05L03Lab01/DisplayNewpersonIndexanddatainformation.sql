USE [AdventureWorksPTO]
GO
SET NOCOUNT ON
GO
-------------------------------------------Display  the table information with Indexes -------------------------------------------------------
Exec Sp_helpindex [NewPerson]
GO

-----------Show Data in table ---------------------
Select Count(*) TotalRows From dbo.Newperson
-----------------------------------------------------------
SELECT PersonType,count(*)  Total
FROM Newperson 
	GROUP BY PersonType
-------------------------------------------------------------------
SELECT [LastName],FirstName,MiddleName,count(*)  Total
FROM Newperson 
	GROUP BY  [LastName],FirstName,MiddleName
---------------------------------------------------------------------
SELECT [rowguid],count(*) Total
FROM Newperson 
	GROUP BY [rowguid]