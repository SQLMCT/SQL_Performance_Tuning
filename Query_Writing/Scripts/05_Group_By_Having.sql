USE AdventureWorks2016
GO

--Group By and Having Example (Starter)
SELECT SalesOrderID, UnitPrice, OrderQty
FROM Sales.SalesOrderDetail

--What is the total for each order?
--Multilplying only get total for each item in order
SELECT SalesOrderID, 
	(UnitPrice * OrderQty) as Order_Total
FROM Sales.SalesOrderDetail

--Use an Aggregate Function to get total
--This will show an error, because SalesOrderID 
--is not aggregated or grouped
SELECT SalesOrderID, 
	SUM(UnitPrice * OrderQty) as Order_Total
FROM Sales.SalesOrderDetail

--Add a Group By statement
SELECT SalesOrderID, 
	SUM(UnitPrice * OrderQty) as Order_Total
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID

--To filter records BEFORE results are grouped
--Use the WHERE statement
--Add the ORDER BY to sort results.
SELECT SalesOrderID, 
	SUM(UnitPrice * OrderQty) as Order_Total
FROM Sales.SalesOrderDetail
WHERE SalesOrderID < 43670
GROUP BY SalesOrderID 
ORDER BY Order_Total

--To filter records AFTER results are grouped
--Use the HAVING statement
SELECT SalesOrderID, 
	SUM(UnitPrice * OrderQty) as Order_Total
FROM Sales.SalesOrderDetail
WHERE SalesOrderID < 43670
GROUP BY SalesOrderID 
HAVING SUM(UnitPrice * OrderQty) > 10000
ORDER BY Order_Total
