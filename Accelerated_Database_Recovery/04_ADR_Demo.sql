--Accelerated Database Recovery Demo
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS ADR_Demo;
CREATE DATABASE ADR_Demo ON PRIMARY
	(NAME = ADR_DB,
	FILENAME = 'D:\DATA\ADR_DB.mdf')
LOG ON
	(NAME = ADR_DB_Log, 
	FILENAME = 'D:\DATA\ADR_DB.ldf');
GO

--Create a Filegroup for Accelerated Database Recovery
ALTER DATABASE ADR_DEMO
ADD FILEGROUP ADR_FG
GO
ALTER DATABASE ADR_DEMO
ADD FILE (NAME = ADR_FG1, FILENAME = 'D:\DATA\ADR_DB2.ndf')
	TO FILEGROUP ADR_FG;
GO

--Change Compatability Level to pre-2019
--This is to show recovery without ADR
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
	AcctID = IDENTITY(INT, 1, 1),
	AcctCode = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
			CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65),
	ModifiedDate = GETDATE()
INTO dbo.ADRTest
FROM sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

--Look at the data
SELECT * FROM dbo.ADRTest

--Hey John! DELETE Records from Table. How long does it take? 
--CPU time = 1532 ms,  elapsed time = 10546 ms.
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
DELETE ADRTest
SET STATISTICS TIME OFF
GO

--Look at the data and verify records DELETED.
SELECT * FROM dbo.ADRTest

-- Check Transaction Log Usage Before and After a CHECKPOINT
-- Notice that there is no size difference.
SELECT 'Before Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Without ADR how long does it take to Rollback?
--CPU time = 1828 ms,  elapsed time = 5591 ms.
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Look at the data and verify records exist.
SELECT * FROM dbo.ADRTest

--TURN ADR ON
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = ON
	(PERSISTENT_VERSION_STORE_FILEGROUP = [ADR_FG]);
GO

--Notice the Compatibility Level is still 2017
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()

--DELETE records in table again. How long does it take? 
--Without ADR: CPU time = 3703 ms,  elapsed time = 9265 ms 
--With ADR: CPU time = 3968 ms,  elapsed time = 9737 ms.
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
DELETE ADRTest
SET STATISTICS TIME OFF
GO

--Check Transaction Log Usage
--Before and After a CHECKPOINT
SELECT 'Before Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()


--With ADR how long does it take to Rollback?
--Without ADR: CPU time = 1828 ms,  elapsed time = 5591 ms.
--With ADR: 
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Check that the records are available.
SELECT * FROM dbo.ADRTest

--Check Transaction Log Usage
--Before and After a CHECKPOINT
SELECT 'Before Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()


--Hey John! What about Updates?
--Turn ADR OFF
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = OFF

SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Update records in table.--How long does it take?
--CPU time = 4516 ms,  elapsed time = 15604 ms.
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
UPDATE ADRTest 
	SET [AcctCode] = 'JD',
		[ModifiedDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

--Check that the records are updated.
SELECT * FROM dbo.ADRTest

-- Check Transaction Log Usage Before and After a CHECKPOINT
-- Notice that there is no size difference.
SELECT 'Before Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Without ADR how long does it take to Rollback?
--SQL Server Execution Times:
--CPU time = 4328 ms,  elapsed time = 15306 ms.
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Check that the records are reverted to original.
SELECT * FROM dbo.ADRTest

--TURN ADR ON
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = ON

--Notice the Compatibility Level is still 2017
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Update records in table again. How long does it take? 
--Without ADR: CPU time = 4516 ms,  elapsed time = 15604 ms
--With ADR: CPU time = 13734 ms,  elapsed time = 14116 ms.
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
UPDATE ADRTest 
	SET [AcctCode] = 'JD',
		[ModifiedDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

--Check Transaction Log Usage
--Before and After a CHECKPOINT
SELECT 'Before Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()


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





