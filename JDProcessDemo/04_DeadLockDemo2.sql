--Diane Deadlock Session 2
USE AdventureWorks2019
GO

BEGIN TRAN
INSERT INTO HumanResources.Department
VALUES ('Training', 'R&D', GETDATE())

--Switch back to Jack

UPDATE Person.Person
SET LastName = 'Deardurff'
WHERE BusinessEntityID = 2
COMMIT TRAN