use AdventureWorksPTO;
go
DECLARE @Country nvarchar(30) = N'GB';
SELECT *
    FROM Sales.SalesOrderHeader h,
    Sales.Customer c,
    Sales.SalesTerritory t
    WHERE h.CustomerID = c.CustomerID 
        AND c.TerritoryID = t.TerritoryID 
        AND CountryRegionCode = @Country;
GO
SELECT a.AddressID
       ,a.AddressLine1
       ,a.City
       ,a.PostalCode
       ,a.StateProvinceID
FROM
  [Person].[Address] AS a
WHERE  City = N'London'; 
GO
DECLARE @Country nvarchar(30) = N'US';
SELECT *
    FROM Sales.SalesOrderHeader h,
    Sales.Customer c,
    Sales.SalesTerritory t
    WHERE h.CustomerID = c.CustomerID 
        AND c.TerritoryID = t.TerritoryID 
        AND CountryRegionCode = @Country;
GO

GO
SELECT a.AddressID
       ,a.AddressLine1
       ,a.City
       ,a.PostalCode
       ,a.StateProvinceID
FROM
  [Person].[Address] AS a
WHERE  City = N'Paris'; 
GO
SELECT a.AddressID
       ,a.AddressLine1
       ,a.City
       ,a.PostalCode
       ,a.StateProvinceID
FROM
  [Person].[Address] AS a
WHERE  City = N'Burien'; 
GO
SELECT a.AddressID
       ,a.AddressLine1
       ,a.City
       ,a.PostalCode
       ,a.StateProvinceID
FROM
  [Person].[Address] AS a
WHERE  City = N'Redmond'; 
GO
DECLARE @stateProvinceID int = 67;
SELECT *
FROM
  Person.Address AS a
WHERE  a.StateProvinceID = @stateProvinceID;
GO
DECLARE @stateProvinceID int = 7;
SELECT *
FROM
  Person.Address AS a
WHERE  a.StateProvinceID = @stateProvinceID
GO
DECLARE @stateProvinceID int = 19;
SELECT *
FROM
  Person.Address AS a
WHERE  a.StateProvinceID = @stateProvinceID
go
