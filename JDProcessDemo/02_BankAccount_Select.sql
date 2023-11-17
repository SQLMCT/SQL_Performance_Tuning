USE TestDB

SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts

EXECUTE dbo.BankTransfer 

--Reset Amounts
UPDATE Accounting.BankAccounts
SET Balance = 500
WHERE AcctID = 1
	

