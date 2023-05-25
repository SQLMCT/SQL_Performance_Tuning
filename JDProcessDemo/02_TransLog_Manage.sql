--Tlog Demo
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS TestDB;
CREATE DATABASE TestDB ON
(NAME = Test_DB,
 FILENAME = 'D:\DATA\TestDB.mdf')
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA\TestDB.ldf');

 --Check Log Space. Should Match Model Database
DBCC SQLPERF(LOGSPACE)

--Demonstrate DBCC LOGINFO
USE TestDB;
DBCC LOGINFO
SELECT * FROM sys.dm_db_log_info(DB_ID());
GO

--Test full backup. Space should not change
BACKUP DATABASE TestDB
TO DISK = 'D:\DATA\TestDB.bak'
WITH INIT;

--Check Log Space. Should Not Change
DBCC SQLPERF(LOGSPACE)

--Create LogTest Table -- Script created by Jeff Moden
USE TestDB;
GO
SELECT TOP 1000000
	SomeID = IDENTITY(INT, 1, 1),
	SomeInt = ABS(CHECKSUM(NEWID())) % 50000 +1,
	SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
			CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65),
	SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 /100.0 AS MONEY),
	SomeDate = CAST(RAND(CHECKSUM(NEWID())) *3653.0 + 36524.0 AS DATETIME)
INTO dbo.LogTest
FROM Sys.all_columns AC1 CROSS JOIN sys.all_columns AC2

 --Check Log Space. Log Space and Usage should be HUGE.
DBCC SQLPERF(LOGSPACE)

--Test full backup. Space should not change
BACKUP DATABASE TestDB
TO DISK = 'D:\DATA\TestDB.bak'
WITH INIT;

 --Check Log Space. Should not see any change. Need a Log Backup
DBCC SQLPERF(LOGSPACE)

--Now Perform a Log Backup. Space should change.
BACKUP LOG TestDB
TO DISK = 'D:\DATA\TestDB_Log.trn'
WITH INIT;

 --Check Log Space. Should see a change
DBCC SQLPERF(LOGSPACE)

--Demonstrate DBCC LOGINFO
USE TestDB;
DBCC LOGINFO

--Demonstrate DMV that is new in SQL Server 2017
SELECT * FROM sys.dm_db_log_info(DB_ID('TestDB'))

USE TestDB;
GO
INSERT INTO dbo.LogTest
SELECT TOP 1000000
	SomeInt = ABS(CHECKSUM(NEWID())) % 50000 +1,
	SomeLetters2 = CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65) + 
			CHAR(ABS(CHECKSUM(NEWID())) % 26 + 65),
	SomeMoney = CAST(ABS(CHECKSUM(NEWID())) % 10000 /100.0 AS MONEY),
	SomeDate = CAST(RAND(CHECKSUM(NEWID())) *3653.0 + 36524.0 AS DATETIME)
FROM Sys.all_columns AC1 CROSS JOIN sys.all_columns AC2
GO

DBCC SHRINKFILE(Test_DB_Log, TRUNCATEONLY)
GO

ALTER DATABASE TestDB
SET RECOVERY FULL
GO

 --Check Log Space. Should see a change
DBCC SQLPERF(LOGSPACE)

--Demonstrate DBCC LOGINFO
USE TestDB;
DBCC LOGINFO


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