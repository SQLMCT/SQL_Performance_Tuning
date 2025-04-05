USE AdventureWorks2019
GO

--Session 80
--Blocking Demo - Session 2
--Diane selects from Person.Person table

SELECT * FROM Person.Person --(NOLOCK)
WHERE BusinessEntityID = 18


--KILL 51