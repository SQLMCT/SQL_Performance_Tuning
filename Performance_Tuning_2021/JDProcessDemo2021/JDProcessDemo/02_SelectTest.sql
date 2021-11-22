USE TestDB

SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts



EXECUTE dbo.BankTransfer 400, 2, 1



--FROM Sales.AcctBal

/*
CREATE SYNONYM Sales.AcctBal
FOR Accounting.BankAccounts
--*/