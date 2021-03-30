USE AdventureWorks2016

SELECT AcctID, AcctName, Balance, ModifiedDate
FROM Accounting.BankAccounts
--FROM Sales.AcctBal

/*
CREATE SYNONYM Sales.AcctBal
FOR Accounting.BankAccounts
--*/