SET NOCOUNT ON;
USE MASTER
GO
--Build Database for Demo
DROP DATABASE IF EXISTS TLogDemo;
CREATE DATABASE TLogDemo ON
(NAME = Test_DB,
 FILENAME = 'D:\DATA2\TLogDemo.mdf')
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA2\TLogDemo.ldf');
GO

--Switch to TLogDemo and verify files created
USE TLogDemo
SELECT * FROM sys.database_files

 --Check Log Space. Should Match Model Database
DBCC SQLPERF(LOGSPACE)

--Use DMV for logspace
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Log Size(MB)	Log Space Used (%)
--7.99			11.29032 < 24.0958
--71.99			35.96853


--Demonstrate DBCC LOGINFO and db_log_info  
DBCC LOGINFO;
--Demonstrate DMV that is new in SQL Server 2017
SELECT * FROM sys.dm_db_log_info(DB_ID());
GO

-- Create and populate a couple of test tables
SELECT LastName, FirstName, MiddleName, ModifiedDate
INTO dbo.Person
FROM AdventureWorks2022.Person.Person;
GO

--Verify Data --19,972 rows at 40 bytes each = 800kb
SELECT * FROM dbo.Person

--Check Log Space. Should Not Change
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Number of VLFs have not changed
SELECT * FROM sys.dm_db_log_info(DB_ID());
GO

USE TLogDemo;
GO
INSERT INTO dbo.Person 
SELECT TOP 200000
LastName = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65), 
FirstName = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) ,
MiddleName = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65), 
ModifiedDate = CURRENT_TIMESTAMP
FROM Sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

--Verify Data
SELECT * FROM dbo.Person

--Check Log Space. Log should grow.
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Number of VLFs have changed
SELECT * FROM sys.dm_db_log_info(DB_ID());
GO
/*****************************************************************************/
--ALTER DATABASE TLogDemo
--SET RECOVERY SIMPLE
--GO

-- Explain Log Buffer Flushing and Checkpoints

-- What's recorded in the tran log when we...
-- update a single row using auto-commit
-- Don't use CHECKPOINT in production.
CHECKPOINT;
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
--SELECT * FROM sys.fn_dblog(NULL, NULL);
GO 

-- update a single row using an explicit transaction
--CHECKPOINT;
BEGIN TRAN
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
COMMIT TRANSACTION;
SELECT * FROM sys.fn_dblog(NULL, NULL);
GO

-- update 5 rows 
CHECKPOINT;
UPDATE TOP (5) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
SELECT * FROM sys.fn_dblog(NULL, NULL);
GO

-- update 5 rows using 5 separate transactions
CHECKPOINT;
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
UPDATE TOP (1) dbo.Person 
SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
SELECT * FROM sys.fn_dblog(NULL, NULL);
GO

--	This generates a lot more log records - 3 for each row updated, and each 
--separate commit forces a flush of the log buffer so we're doing more and 
--more inefficient I/O.

-- If you must update individual rows, you can still batch them into larger
-- transactions
CHECKPOINT;
BEGIN TRAN
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
	UPDATE TOP (1) dbo.Person 
	SET ModifiedDate = DATEADD(MINUTE, 1, ModifiedDate);
COMMIT
SELECT * FROM sys.fn_dblog(NULL, NULL);
GO

--This gets us back to one transaction that updates 5 rows
--Fewer log records and fewer flushes to disk

--Check Log Space. Should Not Change
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Test full backup. Space should not change
BACKUP DATABASE TLogDemo
TO DISK = 'D:\DATA\TLogDemo.bak'
WITH INIT;

--Check Log Space. Should Not Change
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Demonstrate DBCC LOGINFO
SELECT * FROM sys.dm_db_log_info(DB_ID());

--Now Perform a Log Backup. Space should change.
BACKUP LOG TLogDemo
TO DISK = 'D:\DATA\TLogDemo_Log.trn'
WITH INIT;

 --Check Log Space. Should see a change
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Demonstrate DBCC LOGINFO
SELECT * FROM sys.dm_db_log_info(DB_ID());

--NEVER DO THIS!!!
DBCC SHRINKFILE(Test_DB_Log, TRUNCATEONLY)
GO
 --Check Log Space. Should see a change
SELECT database_id, 
CONVERT(decimal(5,2),total_log_size_in_bytes *1.0/1024/1024) AS [Log Size(MB)], 
used_log_space_in_percent AS [Log Space Used (%)]
FROM sys.dm_db_log_space_usage;

--Demonstrate DBCC LOGINFO
SELECT * FROM sys.dm_db_log_info(DB_ID());

CHECKPOINT
