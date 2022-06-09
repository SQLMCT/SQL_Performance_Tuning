
DROP DATABASE IF EXISTS LockingDemo

CREATE DATABASE LockingDemo
GO

USE LockingDemo
GO

-- Let's create a partition function
CREATE PARTITION FUNCTION PartFunc1 (int) 
AS RANGE RIGHT FOR VALUES (100,200,300)
GO

--Create partition scheme
CREATE PARTITION SCHEME PartSch1
AS PARTITION PartFunc1
ALL TO ([PRIMARY])
GO

--Create Locking Test Table
CREATE TABLE LockingTest
(
col1 int,
col2 varchar(20),
col3 datetime
)ON PartSch1(col1)


-- Let's insert a 1 record into the table and check the locks being generated
BEGIN TRANSACTION
INSERT INTO LockingTest VALUES (1, 'FirstRecord',getdate())

--John don't run the COMMIT yet!
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- We should see 4 locks in this case 
-- 1 RID Lock (X), 2 IX locks (Object and Page) and 1 S lock on the DB
COMMIT

-- Rerun the sys.dm_tran_locks query 
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- Now we should see only one lock

--- Let's insert a few more records in the table.
SET NOCOUNT ON
DECLARE @count int = 2
WHILE @count <=350
	BEGIN
		INSERT INTO LockingTest 
		VALUES(@count, 'Record'+cast(@count as char(4)),getdate())
		SET @count += 1
	END

-- Let's see the locks held when doing a Select operation
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- This is needed or else the locks would be release immediately after the operation
BEGIN TRAN
SELECT * FROM LockingTest
-- 350 Records Returned

--- How many Locks would be seen?
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID --356 Records
ORDER BY resource_type
-- Why 356??
-- 350 for the RID (Shared Locks)
-- 1 Shared at DB Level 
-- 1 IS at Object Level
-- 4 Page Level (the average record size for the table is 33 Bytes) 
--and there are 4 partitions 

SELECT * FROM sys.partitions 
WHERE object_id = object_id('LockingTest')

--- Each partitition will have one page in this example -- hence 4 pages.
COMMIT
--- What happens if we just select 1 record
BEGIN TRANSACTION
SELECT * FROM LockingTest where col1 = 100

--- how many Locks would be see... 
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
--Don't Commit yet.
COMMIT

--Let's insert some more records to the table 
--(Such that the record count is greater than 5000)
SET NOCOUNT ON
DECLARE @outerloop int = 1
DECLARE @count int
WHILE @outerloop <=200
	BEGIN
		SET @count = 1
		WHILE @count <=350
		BEGIN
			INSERT INTO LockingTest 
			VALUES(@count, 'Record'+cast(@count as char(4)),getdate())
			SET @count += 1
		END
	SET @outerloop +=1
	END


-- Select count(*) from LockingTest
--- Let's create a XE session to monitor Lock Escalations
CREATE EVENT SESSION [Lock Escalation] ON SERVER 
ADD EVENT sqlserver.lock_escalation(SET collect_database_name=(1),collect_statement=(1)) 
ADD TARGET package0.ring_buffer
GO

ALTER EVENT SESSION [Lock Escalation] ON SERVER
STATE = start;
GO

-- Watch Live Data 
--- Run the below Select query 

BEGIN TRAN
SELECT * FROM LockingTest 

-- Check the locks 
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- We should see only 2 locks (1 at the DB Level and another one at the Object Level)
-- Check the LockEscalation XE live Data
COMMIT 

--- Change the Table Lock Escalation to AUTO
ALTER TABLE LockingTest SET (lock_escalation = Auto)

BEGIN TRAN
SELECT * FROM LockingTest 
WHERE col1 > 250 

-- Check the locks 
SELECT resource_type, resource_description, resource_lock_partition,
	request_mode, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

-- We should see  6 locks now (The escalation is now at the Partition Level)
-- check the LockEscalation XE live Data
COMMIT


/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/