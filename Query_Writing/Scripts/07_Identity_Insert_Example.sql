USE AdventureWorks2016
GO

--Setup table for demonstration
CREATE TABLE dbo.TestTable
(TestID smallint IDENTITY, TestName char(15) NOT NULL)
GO

--Different ways of writing an INSERT statement
INSERT INTO dbo.TestTable VALUES ('First Row')
INSERT INTO dbo.TestTable (TestName)
	VALUES ('Second Row')
INSERT INTO dbo.TestTable VALUES
	('Third Row'), ('Forth Row')
GO

-- Show records from the dbo.TestTable
SELECT TestID, TestName FROM dbo.TestTable

----Inserting a value into an IDENTITY field.
SET IDENTITY_INSERT dbo.TestTable ON
INSERT INTO dbo.TestTable(TestID, TestName)
	VALUES (-99, 'Explicit Row')
SET IDENTITY_INSERT dbo.TestTable OFF

