USE AdventureWorks2016
GO

--Character String Function Examples
SELECT ProductID, Name,
	LEFT(Name, 7) as LeftName,
	SUBSTRING(Name, 9, 4) as SubName,
	RIGHT(Name, 1) as RightName
FROM Production.Product
WHERE ProductID BETWEEN 864 AND 866

--Date and Time Function Examples
SELECT GETDATE() as TSQL_Today,
	CURRENT_TIMESTAMP as ANSI_Today,
	YEAR(OrderDate) as OrderYear,
	DATEADD(d, 90, OrderDate) as Pay_90_Days,
	DATEDIFF(d, GETDATE(), '12/25/2020') as Shopping_Days
FROM Sales.SalesOrderHeader

--Aggregate Function Examples
SELECT COUNT(SalesOrderID) as Count_Orders,
	   MAX(OrderDate) as Max_Order_Date,
	   AVG(Freight) as Avg_Freight
FROM Sales.SalesOrderHeader
