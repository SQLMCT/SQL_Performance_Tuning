--Explicit Transaction with Error Handling
--IF needed, Run 04_Create_BankAccounts_Table.sql

USE AdventureWorks2016
GO

BEGIN TRY
	BEGIN TRANSACTION BankUpdate
		UPDATE Accounting.BankAccounts
		SET Balance -= 200
		WHERE AcctID = 1

		UPDATE Accounting.BankAccounts
		SET Balance += 200
		WHERE AcctID = 2
	COMMIT TRANSACTION
	PRINT 'Transaction Complete'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Error: Transaction not complete'
END CATCH
GO

--SELECT * FROM Accounting.BankAccounts

