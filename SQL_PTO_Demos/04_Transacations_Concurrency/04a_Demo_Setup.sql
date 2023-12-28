--Database Demo
USE master;

--Build Database for Demo
DROP DATABASE IF EXISTS WoodgroveBank;
CREATE DATABASE WoodgroveBank ON
(NAME = WoodgroveBank,
 FILENAME = 'D:\DATA\WoodgroveBank.mdf',
	SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA\WoodgroveBank.ldf',
	SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB);
GO

USE WoodgroveBank
SELECT * 
FROM sys.database_files
GO

/*
DROP TABLE IF EXISTS Accounting.BankAccounts
DROP SCHEMA IF EXISTS Accounting
GO
--*/

CREATE SCHEMA Accounting Authorization dbo
CREATE TABLE BankAccounts
 (AcctID int IDENTITY,
  FirstName char(15),
  LastName char(20),
  Balance money,
  ModifiedDate date)
GO

INSERT INTO Accounting.BankAccounts
VALUES('Jack','Jones',500, GETDATE())
INSERT INTO Accounting.BankAccounts
VALUES('Diane','Smith', 750, GETDATE())
GO

SELECT * FROM Accounting.BankAccounts



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