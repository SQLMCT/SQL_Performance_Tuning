USE AdventureWorks2019
GO

--Blocking Demo - Session 1
--Jack updates the Person.Person table

BEGIN TRAN
UPDATE Person.Person
SET FirstName = 'Jack', LastName = 'Frost'
WHERE BusinessEntityID = 18













