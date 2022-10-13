
--Remind John to build Build Deadlock XEvent Session
--John DO NOT Filter on AdventureWorks because it breaks stuff

--Jack Deadlock Session 1
USE AdventureWorks2019
GO

BEGIN TRAN
UPDATE Person.Person
SET LastName = 'Deardurff'
WHERE BusinessEntityID = 2

--Now switch to Diane Session

INSERT INTO HumanResources.Department
VALUES ('Training', 'R&D', GETDATE())
COMMIT TRAN

--Cleanup Demo
--DELETE FROM HumanResources.Department
--WHERE DepartmentID > 16

