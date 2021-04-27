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

--Create Index to slow down Update statement
CREATE NONCLUSTERED INDEX NC_Letters_Date ON 
dbo.ADRTest (SomeLetters2, SomeDate)
GO

--Look at the data
SELECT * FROM dbo.ADRTest

--Update records in table
--How long does it take?
--SQL Server Execution Times:
--CPU time = 13407 ms,  elapsed time = 31762 ms.
SET STATISTICS TIME ON
BEGIN TRAN
UPDATE ADRTest 
	SET [SomeLetters2] = 'JD',
		[SomeDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

-- Check Transaction Log Usage Before and After a CHECKPOINT
-- Notice that there is no size difference.
SELECT * FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT * FROM sys.dm_db_log_space_usage

--Without ADR how long does it take to Rollback?
--SQL Server Execution Times:
--CPU time = 7906 ms,  elapsed time = 18166 ms.
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--TURN ADR ON
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = ON

--Notice the Compatibility Level is still 2017
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Update records in table again. How long does it take? 
--SQL Server Execution Times:
--CPU time = 36063 ms,  elapsed time = 54612 ms.
SET STATISTICS TIME ON
BEGIN TRAN
UPDATE ADRTest 
	SET [SomeLetters2] = 'JD',
		[SomeDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

--Check Transaction Log Usage
--Before and After a CHECKPOINT
SELECT * FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT * FROM sys.dm_db_log_space_usage

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS persistent_version_store_size_mb,
       pvss.current_aborted_transaction_count,
       pvss.aborted_version_cleaner_start_time,
       pvss.aborted_version_cleaner_end_time
FROM sys.dm_tran_persistent_version_store_stats AS pvss

--With ADR how long does it take to Rollback?
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

 
/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/





