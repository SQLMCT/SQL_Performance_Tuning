USE AdventureWorks2016
GO

--Create Table fro demonstration
CREATE TABLE dbo.TestTable
 (TestID tinyint IDENTITY,
  TestCode char(2),
  TestName varchar(30),
  TestDate date)
GO

--Example of an INSERT statement
INSERT INTO dbo.TestTable
VALUES ('R1', 'Row 1', '20080612'),
	   ('R2', 'Row 2', '20090713'),
	   ('R3', 'Row 3', '20100814'),
	   ('R4', 'Row 4', '20110915')
GO

--Example of an UPDATE Statement
UPDATE dbo.TestTable
SET TestDate = GETDATE()
WHERE TestID = 3

--Example of a DELETE Statement
DELETE dbo.TestTable
WHERE TestCode IN('R2', 'R4')

--DELETE vs TRUNCATE vs DROP
--DELETE removes records from table.
DELETE dbo.TestTable
--TRUNCATE removes data pages from table.
TRUNCATE TABLE dbo.TestTable
--DROP removes entire table
DROP TABLE dbo.TestTable




