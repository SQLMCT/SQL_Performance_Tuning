--AutoCommit Transactions
--IF needed, Run 04_Create_BankAccounts_Table.sql

USE AdventureWorks2016
GO

	UPDATE Accounting.BankAccounts
	SET Balance -= 200
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 200
	WHERE AcctID = 2