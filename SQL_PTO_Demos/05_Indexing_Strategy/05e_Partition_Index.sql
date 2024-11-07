
--HEY JOHN! 
--Don't forget to Run 05_Partition_Database to create PartDB
USE PartDB
GO

--Create Partition Function
CREATE PARTITION FUNCTION PartFunc1 (int) 
AS RANGE RIGHT FOR VALUES (10,20,30)
GO

--Create partition scheme
CREATE PARTITION SCHEME PartSch1
AS PARTITION PartFunc1
TO ([PRIMARY], [PartFG1], [PartFG2], [PartFG3])
GO

--Create Table on Partition
CREATE SCHEMA Accounting Authorization dbo
CREATE TABLE BankAccounts
 (AcctID int IDENTITY,
  AcctName char(30),
  Balance money,
  ModifiedDate date)
ON PartSch1(AcctID)-- Adding a Partition to the table
GO

--Insert Records into Table (Mention IDENTITY values)
INSERT INTO Accounting.BankAccounts
VALUES('Jack',500, GETDATE())
INSERT INTO Accounting.BankAccounts
VALUES('Diane', 750, GETDATE())
GO

--Check the number of Partitions
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')

--Add in more records and check partitions again
SET IDENTITY_INSERT Accounting.BankAccounts ON
BEGIN TRAN
	INSERT INTO Accounting.BankAccounts
	(AcctID, AcctName, Balance, ModifiedDate)
	VALUES (29,'Isabel Winkler', 1250, GETDATE()),
		   (27,'Deena Mathis', 1005, GETDATE()),
		   (18,'Zoe Callahan', 745, GETDATE()),
		   (22,'Jacob Howlett', 445, GETDATE()),
		   (21,'Adele Aguilar', 555, GETDATE()),
		   (15,'Henry Barker', 790, GETDATE()),
		   (24,'Susie Nguyen', 650, GETDATE()),
		   (23,'Haris Howlett', 1050, GETDATE()),
		   (33,'Amber Spence', 450, GETDATE()),
		   (36,'Subhan Davidson', 850, GETDATE()),
		   (37,'Seth Sutton', 630, GETDATE()),
		   (12,'Annika Collier', 630, GETDATE()),
		   (14,'Lila Lang', 204, GETDATE()),
		   (25,'Abubakar Keller', 180, GETDATE()),
		   (30,'Juneau Velazquez', 320, GETDATE())
COMMIT TRAN
SET IDENTITY_INSERT Accounting.BankAccounts OFF
SELECT * FROM Accounting.BankAccounts

-- 2 people in the single digits, 4 people in 10 range, 7 people in 20 range,  4 in the 30 range.
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')

--Review Records. Notice they are in a heap by partition.
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

--Create an aligned index on the table
ALTER TABLE Accounting.BankAccounts
ADD  CONSTRAINT [PK_AcctID] 
PRIMARY KEY CLUSTERED (AcctID)
ON PartSch1(AcctID)

--Review Records. Notice they are in a Clustered Index by partition.
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts


--What about adding a new range?
SET IDENTITY_INSERT Accounting.BankAccounts ON
INSERT INTO Accounting.BankAccounts
	(AcctID, AcctName, Balance, ModifiedDate)
VALUES(42,'Lois',500, GETDATE()), 
	(47,'Clarke', 750, GETDATE())
SET IDENTITY_INSERT Accounting.BankAccounts OFF
GO

--Review Records. Notice the two new records for Lois and Clarke
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

--SPLIT the last two partitions 
--Will get an ERROR as there is not an available filegroup
ALTER PARTITION FUNCTION PartFunc1() 
SPLIT RANGE (40)
GO

---Create a new Filegroup and File for the new partition.
ALTER DATABASE PartDB
ADD FILEGROUP [PartFG4];
GO
ALTER DATABASE PartDB
ADD FILE 
(NAME = N'PartFile4', 
	FILENAME = N'D:\DATA\PartDB4.ndf', 
	SIZE = 10, MAXSIZE = 50)
TO FILEGROUP [PartFG4]
GO

--Alter the partition scheme to use the new filegroup
ALTER PARTITION SCHEME PartSch1 NEXT USED [PartFG4]
GO

--Try to SPLIT the last two partitions again. SUCCESS!
ALTER PARTITION FUNCTION PartFunc1() 
SPLIT RANGE (40)
GO

--Check partitions after SPLIT.
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')

--MERGE the first two partitions.
ALTER PARTITION FUNCTION PartFunc1() 
MERGE RANGE (10)
GO

--Check partitions after MERGE.
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')
GO

--Create archive table
CREATE TABLE Accounting.ArchiveAccounts
 (AcctID int IDENTITY 
	CONSTRAINT [pk_archiveID] PRIMARY KEY(AcctID),
  AcctName char(15),
  Balance money,
  ModifiedDate date)
GO

--Review records in first table (Notice Jack and Diane)
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

--SWITCH the first partition from BankAccounts to ArchiveAccounts
ALTER TABLE [PartDB].[Accounting].[BankAccounts] SWITCH PARTITION 1 
TO [PartDB].[Accounting].[ArchiveAccounts] 
GO

--Review records in first table (Jack and Diane are gone).
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

--Review records in second table (Jack and Diane are found).
SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.ArchiveAccounts

--Check partitions after SWITCH on BankAccounts (First Partition is empty).
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')
GO

--Check partitions after SWITCH on ArchiveAccounts (Jack and Diane have moved).
SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.ArchiveAccounts')
GO

--Non-Aligned Index on Non-Clustered Indexes -Thank you Marina
CREATE PARTITION FUNCTION [pf_OrderDate](date) 
AS RANGE RIGHT FOR VALUES (N'2024-09-01', N'2024-10-01', 
	N'2024-11-01')

CREATE PARTITION SCHEME Part_OrderDate
AS PARTITION pf_OrderDate
TO ([PRIMARY], [PartFG1], [PartFG2], [PartFG3])
GO

CREATE NONCLUSTERED INDEX [NCI_pf_Date_Scheme] ON Accounting.BankAccounts(ModifiedDate) ON [Part_OrderDate](ModifiedDate)

SELECT partition_id, object_id, index_id, 
	partition_number, rows	
FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')
GO

--Demo Cleanuup
USE MASTER
DROP DATABASE IF EXISTS PartDB;


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



