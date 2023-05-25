USE TestDB
GO

CREATE OR ALTER PROCEDURE dbo.BankTransfer
(@Amount money, @SubAccount int, @AddAccount int)
AS
BEGIN TRY
SET NOCOUNT ON
	BEGIN TRANSACTION
		UPDATE Accounting.BankAccounts
		SET Balance -= @Amount
		WHERE AcctID = @SubAccount

		UPDATE Accounting.BankAccounts
		SET Balance += @Amount
		WHERE AcctID = @AddAccount
	COMMIT TRANSACTION
	PRINT 'Transaction Successful'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Divide by Zero Error. Error Number:' + CAST(ERROR_Number() as char(4))
END CATCH