USE AdventureWorksPTO;
GO
SET NOCOUNT ON
SET LOCK_TIMEOUT 7526
GO

SELECT h.RevisionNumber, d.CarrierTrackingNumber, p.BusinessEntityID, 
p.JobTitle, p.City, p.SalesQuota, sfy.[2003], sfy.FullName, sfy.JobTitle, sfy.SalesTerritory 
FROM Sales.SalesOrderHeader h
LEFT OUTER JOIN Sales.SalesOrderDetail d 
  ON h.SalesOrderID = d.SalesOrderID 
LEFT OUTER JOIN Sales.vSalesPerson p 
  ON h.SalesPersonID = p.BusinessEntityID 
LEFT OUTER JOIN Sales.vSalesPersonSalesByFiscalYears sfy 
  ON sfy.SalesPersonID = h.SalesPersonID 
WHERE h.OrderDate BETWEEN '20060101' AND '20060110'  
  AND h.SalesPersonID = 275
GO


SELECT a.CustomerID, C.LastName 
  AS Store, CA.City, SP.Name AS
  State, CR.Name AS CountryRegion
FROM 
--Sales.Store S 
 Sales.SalesOrderHeader a 
JOIN Person.Person C  ON C.BusinessEntityID = a.CustomerID
JOIN Person.BusinessEntityAddress b on b.BusinessEntityID = c.BusinessEntityID
JOIN Person.Address CA ON CA.AddressID =  b.AddressID
JOIN Person.StateProvince AS SP 
ON SP.StateProvinceID =  CA.StateProvinceID
JOIN Person.CountryRegion AS CR
ON CR.CountryRegionCode = SP.CountryRegionCode
GROUP BY a.CustomerID, c.LastName, 
    CA.City, SP.Name, CR.Name
ORDER BY a.CustomerID;

GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO


DECLARE @x int
SET @x = 1
WHILE (@x < 78) BEGIN
EXEC ('SELECT Name, GroupName
FROM HumanResources.Department;')
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductNumber, MakeFlag
FROM Production.Product
ORDER BY Name ASC ;

GO
SELECT ProductNumber, MakeFlag
FROM Production.Product p
ORDER BY Name ASC ;
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='S'
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC ;
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R'
AND DaysToManufacture < 4
ORDER BY Name ASC ;
GO

DECLARE @P1 int
EXEC sp_cursoropen @P1 output, '
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC ;'
DECLARE @x int
SET @x=1
WHILE @x<=386 BEGIN
  EXEC sp_cursorfetch @P1
  SET @x=@x+1
END
EXEC sp_cursorclose @P1
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC master.dbo.sp_who2
GO
EXEC master.dbo.sp_who2 'active'
GO

GO

EXEC sp_columns 'sysobjects'
EXEC sp_columns 'syscolumns'
EXEC sp_columns 'syscomments'
EXEC sp_columns 'sysindexes'
EXEC sp_columns 'systypes'
EXEC sp_columns 'sysobjects'
EXEC sp_columns 'syscolumns'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO
EXEC sp_columns 'syscomments'
EXEC sp_columns 'sysindexes'
EXEC sp_columns 'systypes'
EXEC sp_columns 'sysobjects'
EXEC sp_columns 'syscolumns'
EXEC sp_columns 'syscomments'
EXEC sp_columns 'sysindexes'
EXEC sp_columns 'systypes'
EXEC sp_columns 'syscolumns'
EXEC sp_columns 'syscomments'
EXEC sp_columns 'sysindexes'
EXEC sp_columns 'systypes'
GO

SELECT DISTINCT JobTitle
FROM HumanResources.Employee
ORDER BY JobTitle ;
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='R'
GO

SELECT p.Name AS ProductName, 
NonDiscountSales = (OrderQty * UnitPrice),
Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
ORDER BY ProductName DESC ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT h.RevisionNumber, d.CarrierTrackingNumber, p.BusinessEntityID, 
p.JobTitle, p.City, p.SalesQuota, sfy.[2003], sfy.FullName, sfy.JobTitle, sfy.SalesTerritory 
FROM Sales.SalesOrderHeader h
LEFT OUTER JOIN Sales.SalesOrderDetail d 
  ON h.SalesOrderID = d.SalesOrderID 
LEFT OUTER JOIN Sales.vSalesPerson p 
  ON h.SalesPersonID = p.BusinessEntityID 
LEFT OUTER JOIN Sales.vSalesPersonSalesByFiscalYears sfy 
  ON sfy.SalesPersonID = h.SalesPersonID 
WHERE h.OrderDate BETWEEN '20060101' AND '20060110'  
  AND h.SalesPersonID = 275
GO


DECLARE @x int
SET @x = 1
WHILE (@x <= 76) BEGIN
EXEC sp_executesql N'SELECT Name, AVG(ListPrice) AS ''Average List Price''
FROM Production.Product
GROUP BY Name
HAVING Name LIKE @P1
ORDER BY Name ;', N'@P1 varchar(30)', @P1 = 'Mountain%'
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT a.CustomerID, C.LastName 
  AS Store, CA.City, SP.Name AS
  State, CR.Name AS CountryRegion
FROM 
--Sales.Store S 
 Sales.SalesOrderHeader a 
JOIN Person.Person C  ON C.BusinessEntityID = a.CustomerID
JOIN Person.BusinessEntityAddress b on b.BusinessEntityID = c.BusinessEntityID
JOIN Person.Address CA ON CA.AddressID =  b.AddressID
JOIN Person.StateProvince AS SP 
ON SP.StateProvinceID =  CA.StateProvinceID
JOIN Person.CountryRegion AS CR
ON CR.CountryRegionCode = SP.CountryRegionCode
GROUP BY a.CustomerID, c.LastName, 
    CA.City, SP.Name, CR.Name
ORDER BY a.CustomerID;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO


!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT Name, GroupName
FROM HumanResources.Department;
GO

SELECT ProductNumber, MakeFlag
FROM Production.Product
ORDER BY Name ASC ;

GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR%'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO


DECLARE @x int
SET @x = 1
WHILE (@x <= 31)
BEGIN
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
    EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
    SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO

SELECT p.ProductNumber, MakeFlag
FROM Production.Product p
ORDER BY Name ASC ;
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='S'
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC ;
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' 
AND DaysToManufacture < 4
ORDER BY Name ASC ;
GO

DECLARE @x int
SET @x = 1
WHILE (@x < 78) BEGIN
EXEC ('SELECT Name, GroupName
FROM HumanResources.Department;')
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='R'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='Y'
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='M'
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 76) BEGIN
EXEC sp_executesql N'SELECT Name, AVG(ListPrice) AS ''Average List Price''
FROM Production.Product
GROUP BY Name
HAVING Name LIKE @P1
ORDER BY Name ;', N'@P1 varchar(30)', @P1 = 'Mountain%'
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

DECLARE @x int
SET @x = 1
WHILE @x <= 36 BEGIN 
  EXEC sp_executesql N'SELECT p.[Name], AVG (pch.StandardCost) AS AvgCost, SUM (pi.Quantity) AS qty
     FROM Production.Product p
     INNER JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
     INNER JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
     WHERE p.ProductLine <> @P1
     GROUP BY p.[Name]
     ORDER BY [Name] ASC ;', 
    N'@P1 char(1)', @P1='R'
  SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductNumber, MakeFlag
FROM Production.Product
ORDER BY Name ASC ;

GO
SELECT p.ProductNumber, MakeFlag
FROM Production.Product p
ORDER BY Name ASC ;
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='S'
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC ;
GO

SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' 
AND DaysToManufacture < 4
ORDER BY Name ASC ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO


EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='R'
GO

DECLARE @x int
SET @x = 1
WHILE @x <= 36 BEGIN 
  EXEC sp_executesql N'SELECT p.[Name], AVG (pch.StandardCost) AS AvgCost, SUM (pi.Quantity) AS qty
     FROM Production.Product p
     INNER JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
     INNER JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
     WHERE p.ProductLine <> @P1
     GROUP BY p.[Name]
     ORDER BY [Name] ASC ;', 
    N'@P1 char(1)', @P1='R'
  SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='Y'
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='M'
GO

DECLARE @x int
SET @x = 1
WHILE @x <= 76 BEGIN 
  EXEC sp_executesql N'SELECT p.[Name], AVG (pch.StandardCost) AS AvgCost, SUM (pi.Quantity) AS qty
     FROM Production.Product p
     INNER JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
     INNER JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
     WHERE p.ProductLine <> @P1
     GROUP BY p.[Name]
     ORDER BY [Name] ASC ;', 
    N'@P1 char(1)', @P1='R'
  SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC sp_executesql N'SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = @P1 
AND DaysToManufacture < 4
ORDER BY Name ASC ;', 
  N'@P1 char(1)', @P1='R'
GO

SELECT 'Total income is', ((OrderQty * UnitPrice) * (1.0 - UnitPriceDiscount)), ' for ',
p.Name AS ProductName 
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
ORDER BY ProductName ASC ;
GO

SELECT DISTINCT JobTitle
FROM HumanResources.Employee
ORDER BY JobTitle ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductNumber, MakeFlag 
FROM Production.Product p
GO

DECLARE @x int
SET @x = 1
WHILE @x<17 BEGIN 
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
  EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
  SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='AR'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='BA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SO'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='HL'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='CA'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='LJ'
GO
EXEC sp_executesql N'SELECT ProductNumber, MakeFlag FROM Production.Product WHERE ProductNumber LIKE @P1', N'@P1 varchar(10)', @P1='SL'
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductNumber, MakeFlag 
FROM Production.Product
WHERE ListPrice > $25 
AND ListPrice < $100
GO

SELECT DISTINCT Name
FROM Production.Product p 
WHERE EXISTS
(SELECT *
FROM Production.ProductModel pm 
WHERE p.ProductModelID = pm.ProductModelID
AND pm.Name = 'Long-sleeve logo jersey') ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT DISTINCT Name
FROM Production.Product
WHERE ProductModelID IN
(SELECT ProductModelID 
FROM Production.ProductModel
WHERE Name = 'Long-sleeve logo jersey') ;
GO

SELECT DISTINCT c.PersonID 
FROM Person.BusinessEntityContact c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID WHERE 5000.00 IN
(SELECT Bonus
FROM Sales.SalesPerson sp
WHERE e.BusinessEntityID = sp.BusinessEntityID) 
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 74) BEGIN
EXEC ('SELECT p1.ProductModelID
FROM Production.Product p1
GROUP BY p1.ProductModelID
HAVING MAX(p1.ListPrice) >= ALL
(SELECT 2 * AVG(p2.ListPrice)
FROM Production.Product p2
WHERE p1.ProductModelID = p2.ProductModelID)')
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

select * 
FROM  
HumanResources.Employee e 
JOIN Person.BusinessEntityContact c ON e.BusinessEntityID = c.BusinessEntityID 
WHERE e.BusinessEntityID IN 
(SELECT SalesPersonID 
FROM Sales.SalesOrderHeader
WHERE SalesOrderID IN 
(SELECT SalesOrderID 
FROM Sales.SalesOrderDetail
WHERE ProductID IN 
(SELECT ProductID 
FROM Production.Product p 
WHERE ProductNumber = 'BK-M68B-42'))) 
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT SalesOrderID, SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail sod
GROUP BY SalesOrderID
ORDER BY SalesOrderID
GO

DECLARE @x int
SET @x = 1
WHILE @x <= 76 BEGIN 
  EXEC sp_executesql N'SELECT p.[Name], AVG (pch.StandardCost) AS AvgCost, SUM (pi.Quantity) AS qty
     FROM Production.Product p
     INNER JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID
     INNER JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
     WHERE p.ProductLine <> @P1
     GROUP BY p.[Name]
     ORDER BY [Name] ASC ;', 
    N'@P1 char(1)', @P1='R'
  SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, SpecialOfferID, AVG(UnitPrice) AS 'Average Price', 
    SUM(LineTotal) AS SubTotal
FROM Sales.SalesOrderDetail
GROUP BY ProductID, SpecialOfferID
ORDER BY ProductID
GO

SELECT ProductModelID, AVG(ListPrice) AS 'Average List Price'
FROM Production.Product
WHERE ListPrice > $1000
GROUP BY ProductModelID
ORDER BY ProductModelID 
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 74) BEGIN
EXEC ('SELECT p1.ProductModelID
FROM Production.Product p1
GROUP BY p1.ProductModelID
HAVING MAX(p1.ListPrice) >= ALL
(SELECT 2 * AVG(p2.ListPrice)
FROM Production.Product p2
WHERE p1.ProductModelID = p2.ProductModelID)')
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT AVG(OrderQty) AS 'Average Quantity', 
NonDiscountSales = (OrderQty * UnitPrice)
FROM Sales.SalesOrderDetail sod
GROUP BY (OrderQty * UnitPrice)
ORDER BY (OrderQty * UnitPrice) DESC 
GO

SELECT ProductID, AVG(UnitPrice) AS 'Average Price'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 10
GROUP BY ProductID
ORDER BY ProductID ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, AVG(UnitPrice) AS 'Average Price'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 10
GROUP BY ALL ProductID
ORDER BY ProductID ;
GO

SELECT ProductID, AVG(UnitPrice) AS 'Average Price'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 10
GROUP BY ProductID
ORDER BY AVG(UnitPrice)
GO

SELECT ProductID 
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID ;
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 76) BEGIN
EXEC sp_executesql N'SELECT Name, AVG(ListPrice) AS ''Average List Price''
FROM Production.Product
GROUP BY Name
HAVING Name LIKE @P1
ORDER BY Name ;', N'@P1 varchar(30)', @P1 = 'Mountain%'
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID 
FROM Sales.SalesOrderDetail
WHERE UnitPrice < 25.00
GROUP BY ProductID
HAVING AVG(OrderQty) > 5
ORDER BY ProductID 
GO

SELECT ProductID, AVG(OrderQty) AS AverageQuantity, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $1000000.00
AND AVG(OrderQty) < 3 ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, Total = SUM(LineTotal)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(LineTotal) > $2000000.00 ;
GO

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 1500 ;
GO

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, LineTotal
COMPUTE SUM(LineTotal) BY ProductID ;
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 76) BEGIN
EXEC sp_executesql N'SELECT Name, AVG(ListPrice) AS ''Average List Price''
FROM Production.Product
GROUP BY Name
HAVING Name LIKE @P1
ORDER BY Name ;', N'@P1 varchar(30)', @P1 = 'Mountain%'
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, LineTotal
COMPUTE SUM(LineTotal), MAX(LineTotal) BY ProductID ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $2.00
COMPUTE SUM(OrderQty), SUM(LineTotal) ;
GO

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
COMPUTE SUM(OrderQty), SUM(LineTotal) BY ProductID
COMPUTE SUM(OrderQty), SUM(LineTotal) ;
GO

SELECT ProductID, OrderQty, LineTotal
FROM Sales.SalesOrderDetail
COMPUTE SUM(OrderQty), SUM(LineTotal) ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, OrderQty, UnitPrice, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID, OrderQty, LineTotal
COMPUTE SUM(LineTotal) BY ProductID, OrderQty
COMPUTE SUM(LineTotal) BY ProductID ;
GO

SELECT ProductID, LineTotal
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
ORDER BY ProductID
COMPUTE SUM(LineTotal) BY ProductID ;
GO

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID
ORDER BY ProductID ;
GO

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
COMPUTE SUM(SUM(LineTotal)) BY ProductID, OrderQty
COMPUTE SUM(SUM(LineTotal)) ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
WITH CUBE
ORDER BY ProductID ;
GO

IF OBJECT_ID ('tempdb..#CubeExample', 'U') IS NOT NULL
DROP TABLE #CubeExample ;
GO
CREATE TABLE #CubeExample(
ProductName VARCHAR(30) NULL,
CustomerName VARCHAR(30) NULL,
Orders INT NULL
)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Wilman Kala', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 20)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Wilman Kala', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Wilman Kala', 20)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Wilman Kala', 30)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Eastern Connection', 40)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Eastern Connection', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Wilman Kala', 40)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 50) ;
GO

SELECT ProductName, CustomerName, SUM(Orders)
FROM #CubeExample
GROUP BY ProductName, CustomerName
ORDER BY ProductName ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductName, CustomerName, SUM(Orders)
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH CUBE ;
GO

SELECT ProductModelID, p.Name AS ProductName, SUM(OrderQty)
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY ProductModelID, p.Name
WITH CUBE ;
GO

SELECT ProductModelID, GROUPING(ProductModelID), p.Name AS ProductName, GROUPING(p.Name), SUM(OrderQty)
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY ProductModelID, p.Name
WITH CUBE ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductName, CustomerName, SUM(Orders) AS 'Sum orders'
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH ROLLUP ;
GO

INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', NULL, 0)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES (NULL, NULL, 50)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES (NULL, 'Wilman Kala', NULL)
GO
SELECT ProductName AS Prod, CustomerName AS Cust, 
SUM(Orders) AS 'Sum Orders',
GROUPING(ProductName) AS 'Group ProductName',
GROUPING(CustomerName) AS 'Group CustomerName'
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH ROLLUP ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

DROP TABLE #CubeExample 
GO

SELECT pm.Name AS ProductModel, p.Name AS ProductName, SUM(OrderQty)
FROM Production.ProductModel pm
INNER JOIN Production.Product p 
ON pm.ProductModelID = p.ProductModelID
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY pm.Name, p.Name
WITH ROLLUP ;
GO

SELECT e.BusinessEntityID, e.JobTitle
FROM HumanResources.Employee e 
JOIN Person.BusinessEntityContact c on e.BusinessEntityID = c.BusinessEntityID
WHERE e.BusinessEntityID = 3 ;
GO


SELECT d.LastName, d.FirstName, e.JobTitle
FROM HumanResources.Employee e WITH (INDEX = 0) 
JOIN Person.BusinessEntity c
ON e.BusinessEntityID = c.BusinessEntityID
join Person.Person d on d.BusinessEntityID = c.BusinessEntityID
WHERE  LastName = 'Johnson' ;
GO

!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

DECLARE @x int
SET @x = 1
WHILE (@x <= 76) BEGIN
EXEC sp_executesql N'SELECT Name, AVG(ListPrice) AS ''Average List Price''
FROM Production.Product
GROUP BY Name
HAVING Name LIKE @P1
ORDER BY Name ;', N'@P1 varchar(30)', @P1 = 'Mountain%'
SET @x = @x + 1
END
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP, FAST 10) ;
GO

SELECT NationalIDNumber, ContactID
FROM HumanResources.Employee e1
UNION
SELECT NationalIDNumber, ContactID
FROM HumanResources.Employee e2
OPTION (MERGE UNION) ;
GO

SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 66 ;
GO
SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 66 ;
GO
SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 66 ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

IF OBJECT_ID ('tempdb..#CubeExample', 'U') IS NOT NULL
DROP TABLE #CubeExample ;
GO
CREATE TABLE #CubeExample(
ProductName VARCHAR(30) NULL,
CustomerName VARCHAR(30) NULL,
Orders INT NULL
)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Wilman Kala', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 20)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Wilman Kala', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Wilman Kala', 20)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Wilman Kala', 30)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Eastern Connection', 40)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Outback Lager', 'Eastern Connection', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Wilman Kala', 40)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', 'Romero y tomillo', 10)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Filo Mix', 'Romero y tomillo', 50) ;
GO

SELECT ProductName, CustomerName, SUM(Orders)
FROM #CubeExample
GROUP BY ProductName, CustomerName
ORDER BY ProductName ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductName, CustomerName, SUM(Orders)
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH CUBE ;
GO

SELECT ProductModelID, p.Name AS ProductName, SUM(OrderQty)
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY ProductModelID, p.Name
WITH CUBE ;
GO

SELECT ProductModelID, GROUPING(ProductModelID), p.Name AS ProductName, GROUPING(p.Name), SUM(OrderQty)
FROM Production.Product p 
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY ProductModelID, p.Name
WITH CUBE ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductName, CustomerName, SUM(Orders) AS 'Sum orders'
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH ROLLUP ;
GO

INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES ('Ikura', NULL, 0)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES (NULL, NULL, 50)
GO
INSERT #CubeExample (ProductName, CustomerName, Orders)
VALUES (NULL, 'Wilman Kala', NULL)
GO
SELECT ProductName AS Prod, CustomerName AS Cust, 
SUM(Orders) AS 'Sum Orders',
GROUPING(ProductName) AS 'Group ProductName',
GROUPING(CustomerName) AS 'Group CustomerName'
FROM #CubeExample
GROUP BY ProductName, CustomerName
WITH ROLLUP ;
GO

DROP TABLE #CubeExample 
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT pm.Name AS ProductModel, p.Name AS ProductName, SUM(OrderQty)
FROM Production.ProductModel pm
INNER JOIN Production.Product p 
ON pm.ProductModelID = p.ProductModelID
INNER JOIN Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID 
GROUP BY pm.Name, p.Name
WITH ROLLUP ;
GO

SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 3 ;
GO


SELECT d.LastName, d.FirstName, e.JobTitle
FROM HumanResources.Employee e WITH (INDEX = 0) 
JOIN Person.BusinessEntity c
ON e.BusinessEntityID = c.BusinessEntityID
join Person.Person d on d.BusinessEntityID = c.BusinessEntityID
WHERE  LastName = 'Johnson' ;
GO

Select * from Person.Person

select * from Person.BusinessEntityContact
select * from Person.Person

!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP, FAST 10) ;
GO

SELECT NationalIDNumber, e1.BusinessEntityID
FROM HumanResources.Employee e1
UNION
SELECT NationalIDNumber, e2.BusinessEntityID
FROM HumanResources.Employee e2
OPTION (MERGE UNION) ;
GO
!!E:\LabFiles\M01L03Lab01\CommonFiles\bin\sleep 1
GO

SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 66 ;
GO

SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 46 ;
GO

SELECT *
FROM Person.BusinessEntity c JOIN HumanResources.Employee e
ON e.BusinessEntityID = c.BusinessEntityID
WHERE c.BusinessEntityID = 27 ;
GO

