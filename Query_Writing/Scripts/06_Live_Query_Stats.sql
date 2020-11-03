
USE AdventureWorks2016;
GO
 
SELECT * 
FROM Production.TransactionHistory AS TranHist
INNER JOIN Production.TransactionHistoryArchive AS TranHistArch 
ON TranHist.Quantity = TranHistArch.Quantity;
GO
