USE AdventureWorks2019
GO

--SHOWPLAN will be Estimated Execution Plan
--STATISTICS will be Actual Execution Plan
--DO NOT DO THIS IN PRODUCTION!!!
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
GO

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