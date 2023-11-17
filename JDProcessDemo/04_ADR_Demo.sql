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

--Change Compatability Level to pre-2019
--This is to show recovery without ADR
ALTER DATABASE ADR_DEMO
SET COMPATIBILITY_LEVEL = 140

--Check that ADR is turned off
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--DROP TABLE dbo.ADRTest
--Create ADRTest Table
USE ADR_Demo;
GO
SELECT TOP 1750000
	AcctID = IDENTITY(INT, 1, 1),
	AcctCode = CAST(CAST(RAND(CHECKSUM(NEWID()))* 10000 as int)as char(4))
				+'_JD_INSERT'  ,
	ModifiedDate = GETDATE()
INTO dbo.ADRTest
FROM sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

--Create index to speed up reads
CREATE NONCLUSTERED INDEX ix_jd_adrtest_demo
ON dbo.ADRTEST(AcctCode, ModifiedDate)

--Look at the data! LOOK AT IT NOW!
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

--Hey John! DELETE Records from Table. How long does it take? 
--Be sure to paste results to line 92
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
DELETE ADRTest
SET STATISTICS TIME OFF
GO

--Look at the data and verify records DELETED.
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

-- Check Transaction Log Usage Before and After a CHECKPOINT
-- Notice that there is no size difference.
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Without ADR how long does it take to Rollback?
--Hey John! Be sure to paste results to line 124
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Look at the data and verify records exist.
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

--TURN ADR ON
ALTER DATABASE ADR_DEMO 
SET ACCELERATED_DATABASE_RECOVERY = ON

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
--Without ADR:
--With ADR: 
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
DELETE ADRTest
SET STATISTICS TIME OFF
GO

--Check Transaction Log Usage Before and After a CHECKPOINT
--A lot smaller because all non-versioned operations are in the slog
--Versioned information will be in the Persisted Version Store.
--Transaction log only has activity since Checkpoint
--741MB before ADR
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()

-- THIS IS WHERE THE MAGIC HAPPENS!!!! 

--With ADR how long does it take to Rollback?
--Without ADR: 
--With ADR:    
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Check that the records are available.
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()

--Check Transaction Log Usage Before and After a CHECKPOINT
--The Logical Revert marked the transaction terminated in the PVS.
--Transaction log only has activity since Checkpoint
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Monitor PVS, Might take a minute for the Cleaner to do its job.
--The Cleaner will remove stale rows that were marked as terminated.
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()

--This concludes the short version of the demo.
--Demo cleanup
USE master
DROP DATABASE ADR_Demo


/* 
** This ends the DELETE section of the demonstration.
** If there is time also demonstrate and UPDATES.
*/

--Hey John! What about Updates?
--Turn ADR OFF
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = OFF

SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Update records in table.--How long does it take?
--Paste results to line 220
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
UPDATE ADRTest 
	SET [AcctCode] = 'UPDATE_NO_ADR',
		[ModifiedDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

--Check that the records are updated.
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

-- Check Transaction Log Usage Before and After a CHECKPOINT
-- Notice that there is no size difference.
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, (
	used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

--Without ADR how long does it take to Rollback?
SET STATISTICS TIME ON
ROLLBACK
SET STATISTICS TIME OFF

--Check that the records are reverted to original.
SELECT AcctID, AcctCode, ModifiedDate FROM dbo.ADRTest

--TURN ADR ON
ALTER DATABASE ADR_DEMO
SET ACCELERATED_DATABASE_RECOVERY = ON

--Notice the Compatibility Level is still 2017
SELECT name, compatibility_level, is_accelerated_database_recovery_on
FROM sys.databases
WHERE name = 'ADR_DEMO'

--Update records in table again. How long does it take? 
--Without ADR: CPU time = 14125 ms,  elapsed time = 36967 ms
--With ADR: CPU time = 24969 ms,  elapsed time = 33433 ms
SET STATISTICS TIME ON
BEGIN TRAN --Notice there is no Commit Transaction
UPDATE ADRTest 
	SET [AcctCode] = 'UPD_WITH_ADR',
		[ModifiedDate] = CURRENT_TIMESTAMP
SET STATISTICS TIME OFF
GO

--A lot smaller after checkpoint because
--All non-versioned operations are in the slog
--Versioned information will be in the Persisted Version Store.
--Transaction log only has activity since Checkpoint
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
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

--Monitor PVS
SELECT pvss.persistent_version_store_size_kb / 1024. AS PVS_MB,
       pvss.current_aborted_transaction_count  
FROM sys.dm_tran_persistent_version_store_stats AS pvss
WHERE database_id = DB_ID()

--Check Transaction Log Usage Before and After a CHECKPOINT
--The Logical Revert marked the transaction terminated in the PVS
--Transaction log only has activity since Checkpoint
SELECT 'Before Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage

CHECKPOINT;

SELECT 'After Checkpoint' AS Check_Time, 
	(used_log_space_in_bytes /1024)/ 1024 as space_used_MB, used_log_space_in_percent
FROM sys.dm_db_log_space_usage



 
/* 
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
*/





