USE AdventureWorks2016
GO

SELECT * FROM Accounting.BankAccounts

DBCC TRACEON(3604) 
DBCC PAGE(0, 4, 8, 3)
--DBCC IND(0,'Accounting.BankAccounts',-1)