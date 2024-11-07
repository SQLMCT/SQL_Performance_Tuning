USE AdventureWorks2019
GO

-- MERGE JOIN NOT FORCED: Cost = 2.62738 and 1888kb Memory
-- FORCED MERGE JOIN: Cost = 3.429 and 57MB Memory
-- FORCE MERGE AND MAXDOP 1 and CTOP = 5: Cost = 11.7573 and 11MB Memory
-- FORCE MERGE AND MAXDOP 0 and CTOP = 15: Cost = 11.7573 and 11MB Memory
-- FORCED HASH JOIN: Cost = 4.1715 and 14MB Memory

-- Enable Acutal Execution Plan (CTRL+M)
-- Show Merge vs Hash Match Join.
-- MERGE JOIN NOT FORCED: Cost = 2.62738 and 1888kb Memory (Serial Plan)
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID

-- FORCED MERGE JOIN: Cost = 3.429 and 57MB Memory (Parrallel Plan)
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER MERGE
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID

-- FORCE MERGE AND MAXDOP 1 and CTOP = 5: Cost = 11.7573 and 11MB Memory
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER MERGE
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID
OPTION (MAXDOP 1)

-- Change Cost Threshold for Parallelism to 15
USE master;
GO
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'cost threshold for parallelism', 15;
GO
RECONFIGURE
GO

-- Switch back to AdventureWorks2019
USE AdventureWorks2019;
GO

-- FORCE MERGE using default MAXDOP of 0 and CTOP = 15
-- Value should be same as FORCE MERGE AND MAXDOP 1 
-- Cost = 11.7573 and 11MB Memory
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER MERGE
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID
GO

-- Change Cost Threshold for Parallelism back to 5
USE master;
GO
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'cost threshold for parallelism', 5;
GO
RECONFIGURE
GO

-- Switch back to AdventureWorks2019
USE AdventureWorks2019;
GO

-- FORCED HASH JOIN: Cost = 4.1715 and 14MB Memory
-- Notice the larger table is being force on top.
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Sales.SalesOrderHeader AS SOH
	JOIN Sales.SalesOrderDetail AS SOD 
		ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER HASH
	JOIN Production.Product AS P
		ON P.ProductID = SOD.ProductID
GO


-- Notice the tables have been re-ordered
-- Compare with and without FORCE ORDER option.
-- NOT FORCED: Cost = 2.62738 and 1888kb Memory
-- FORCED ORDER: Cost = 2.70323 and 54MB Memory
SELECT SOH.SalesOrderID, SOH.CustomerID,
	OrderQty, UnitPrice, P.Name
FROM Production.Product AS P
	JOIN Sales.SalesOrderDetail AS SOD
		ON P.ProductID = SOD.ProductID
	JOIN  Sales.SalesOrderHeader AS SOH 
		ON SOH.SalesOrderID = SOD.SalesOrderID
OPTION (FORCE ORDER)
GO


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/



