USE TestDB
GO

		UPDATE Accounting.BankAccounts
		SET Balance -= 2/0
		WHERE AcctID = 1

		UPDATE Accounting.BankAccounts
		SET Balance += 200
		WHERE AcctID = 2