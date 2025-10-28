USE AdventureWorks2022
GO

--Session 56
--Blocking Demo - Session 1
--Jack updates the Person.Person table

BEGIN TRAN
UPDATE Person.Person
SET FirstName = 'Jack', LastName = 'Frost'
WHERE BusinessEntityID = 18
--ROLLBACK
--COMMIT

DBCC OPENTRAN()















