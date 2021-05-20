USE AdventureWorks2016
GO

--SHOWPLAN will be Estimated Execution Plan
--STATISTICS will be Actual Execution Plan
--DBCC DROPCLEANBUFFERS
--DBCC FREEPROCCACHE

SET STATISTICS IO, TIME ON
	SELECT SOH.SalesOrderID, SOH.CustomerID,
		OrderQty, UnitPrice, P.Name
	FROM Sales.SalesOrderHeader AS SOH
		JOIN Sales.SalesOrderDetail AS SOD
			ON SOH.SalesOrderID = SOD.SalesOrderID
		JOIN Production.Product AS P
			ON P.ProductID = SOD.ProductID
SET STATISTICS IO, TIME OFF

--SET SHOWPLAN_TEXT ON
--GO
--	SELECT SOH.SalesOrderID, SOH.CustomerID,
--		OrderQty, UnitPrice, P.Name
--	FROM Sales.SalesOrderHeader AS SOH
--		JOIN Sales.SalesOrderDetail AS SOD
--			ON SOH.SalesOrderID = SOD.SalesOrderID
--		JOIN Production.Product AS P
--			ON P.ProductID = SOD.ProductID
--GO
--SET SHOWPLAN_TEXT OFF
--GO

--SET SHOWPLAN_ALL ON
--GO
--	SELECT SOH.SalesOrderID, SOH.CustomerID,
--		OrderQty, UnitPrice, P.Name
--	FROM Sales.SalesOrderHeader AS SOH
--		JOIN Sales.SalesOrderDetail AS SOD
--			ON SOH.SalesOrderID = SOD.SalesOrderID
--		JOIN Production.Product AS P
--			ON P.ProductID = SOD.ProductID
--GO
--SET SHOWPLAN_ALL OFF
--GO

--SET STATISTICS PROFILE ON
--GO
--	SELECT SOH.SalesOrderID, SOH.CustomerID,
--		OrderQty, UnitPrice, P.Name
--	FROM Sales.SalesOrderHeader AS SOH
--		JOIN Sales.SalesOrderDetail AS SOD
--			ON SOH.SalesOrderID = SOD.SalesOrderID
--		JOIN Production.Product AS P
--			ON P.ProductID = SOD.ProductID
--GO
--SET STATISTICS PROFILE OFF
--GO

--SET SHOWPLAN_XML ON
--GO
--	SELECT SOH.SalesOrderID, SOH.CustomerID,
--		OrderQty, UnitPrice, P.Name
--	FROM Sales.SalesOrderHeader AS SOH
--		JOIN Sales.SalesOrderDetail AS SOD
--			ON SOH.SalesOrderID = SOD.SalesOrderID
--		JOIN Production.Product AS P
--			ON P.ProductID = SOD.ProductID
--GO
--SET SHOWPLAN_XML OFF
--GO

--SET STATISTICS XML ON
--GO
--	SELECT SOH.SalesOrderID, SOH.CustomerID,
--		OrderQty, UnitPrice, P.Name
--	FROM Sales.SalesOrderHeader AS SOH
--		JOIN Sales.SalesOrderDetail AS SOD
--			ON SOH.SalesOrderID = SOD.SalesOrderID
--		JOIN Production.Product AS P
--			ON P.ProductID = SOD.ProductID
--GO
--SET STATISTICS XML OFF
--

