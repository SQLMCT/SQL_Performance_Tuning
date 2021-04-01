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



