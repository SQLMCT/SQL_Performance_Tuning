USE AdventureWorks2016
GO

DROP TABLE IF EXISTS Accounting.BankAccounts
DROP SCHEMA IF EXISTS Accounting
GO

CREATE SCHEMA Accounting Authorization dbo
CREATE TABLE BankAccounts
 (AcctID int IDENTITY,
  AcctName char(15),
  Balance money,
  ModifiedDate date)
GO

INSERT INTO Accounting.BankAccounts
VALUES('Jack',500, GETDATE())
INSERT INTO Accounting.BankAccounts
VALUES('Diane', 750, GETDATE())
GO

