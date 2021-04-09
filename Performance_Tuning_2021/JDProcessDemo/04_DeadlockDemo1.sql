
--Remind John to build Build Deadlock XEvent Session

--Jack Deadlock Session 1
USE AdventureWorks2016
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

