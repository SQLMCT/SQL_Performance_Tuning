USE SUMMIT2018
GO
--DROP TABLE IF EXISTS Accounting.BankAccounts
--DROP SCHEMA IF EXISTS Accounting
--DROP PARTITION SCHEME PartSch1
--DROP PARTITION FUNCTION PartFunc1
--GO

--Create Partition Function
CREATE PARTITION FUNCTION PartFunc1 (int) 
AS RANGE RIGHT FOR VALUES (10,20,30)
GO

--Create partition scheme
CREATE PARTITION SCHEME PartSch1
AS PARTITION PartFunc1
ALL TO ([PRIMARY])
GO

--Create Table on Partition
CREATE SCHEMA Accounting Authorization dbo
CREATE TABLE BankAccounts
 (AcctID int IDENTITY,
  AcctName char(15),
  Balance money,
  ModifiedDate date)
ON PartSch1(AcctID)-- Adding a Partition to the table
GO

--Insert Records into Table (Mention IDENTITY values)
INSERT INTO Accounting.BankAccounts
VALUES('John',500, GETDATE())
INSERT INTO Accounting.BankAccounts
VALUES('Jane', 750, GETDATE())
GO
--Check the number of Partitions
SELECT * FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')

--Add in more records and check partitions again
--Run 03-AddRecords.sql
SELECT * FROM sys.partitions 
where object_id = object_id('Accounting.BankAccounts')



