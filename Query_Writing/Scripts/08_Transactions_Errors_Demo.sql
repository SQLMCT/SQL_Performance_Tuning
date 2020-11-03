--Demonstrate Transactions
--Run 04_Create_BankAccounts_Table.sql

USE AdventureWorks2016
GO

--Auto-Commit Transactions
UPDATE Accounting.BankAccounts
SET Balance -= 200
WHERE AcctID = 1

UPDATE Accounting.BankAccounts
SET Balance += 200
WHERE AcctID = 2
GO

SELECT * FROM Accounting.BankAccounts
