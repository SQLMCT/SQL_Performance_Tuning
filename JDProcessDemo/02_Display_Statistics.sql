USE AdventureWorks2019
GO

--SHOWPLAN will be Estimated Execution Plan
--STATISTICS will be Actual Execution Plan
--DO NOT DO THIS IN PRODUCTION!!!
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO

--John, Show the Statistics Parser!
--http://statisticsparser.com/

SET STATISTICS IO ON
GO
SET STATISTICS TIME ON
	SELECT SOH.SalesOrderID, SOH.CustomerID,
		OrderQty, UnitPrice, P.Name
	FROM Sales.SalesOrderHeader AS SOH
		JOIN Sales.SalesOrderDetail AS SOD
			ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product AS P
			ON P.ProductID = SOD.ProductID
SET STATISTICS IO, TIME OFF
