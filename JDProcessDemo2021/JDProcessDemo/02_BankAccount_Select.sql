USE TestDB

SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

EXECUTE dbo.BankTransfer 400, 2, 1

---Check Transaction Log

CHECKPOINT;

SELECT * FROM sys.fn_dblog(NULL, NULL);
GO
