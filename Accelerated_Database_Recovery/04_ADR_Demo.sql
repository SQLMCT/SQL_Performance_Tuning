--Accelerated Database Recovery Demo
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS ADR_Demo;
CREATE DATABASE ADR_Demo ON
(NAME = ADR_DB,
 FILENAME = 'D:\DATA\ADR_DB.mdf')
LOG ON
(NAME = ADR_DB_Log,
 FILENAME = 'D:\DATA\ADR_DB.ldf');
GO

--Change Compatability Level to pre-2019
ALTER DATABASE ADR_DEMO
SET COMPATIBILITY_LEVEL = 140

--Check that ADR is turned off
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Create ADRTest Table
USE ADR_Demo;
GO
SELECT TOP 750000
	SomeID = IDENTITY(INT, 1, 1),
	SomeInt = ABS(CHECKSUM(NEWID())) % 50000 +1,
	SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
			CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65),
	SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 /100.0 AS MONEY),
	SomeDate = CAST(RAND(CHECKSUM(NEWID())) *3653.0 + 36524.0 AS DATETIME)
INTO dbo.ADRTest
FROM Sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

--Look at the data
SELECT * FROM dbo.ADRTest

--Create Index to slow down Update statement
CREATE NONCLUSTERED INDEX NC_Letters_Date ON 
dbo.ADRTest (SomeLetters2, SomeDate)
GO

--Update records in table
--How long does it take?
BEGIN TRAN
UPDATE ADRTest 
	SET [SomeLetters2] = 'JD',
		[SomeDate] = CURRENT_TIMESTAMP
GO
--Without ADR how long does it take to Rollback?
ROLLBACK

--TURN ADR ON
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = ON

--Notice the Compatibility Level is still 2017
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases

--Update records in table again.
--How long does it take? Should be about the same.
BEGIN TRAN
UPDATE ADRTest 
	SET [SomeLetters2] = 'JD',
		[SomeDate] = CURRENT_TIMESTAMP
GO
--With ADR how long does it take to Rollback?
ROLLBACK




