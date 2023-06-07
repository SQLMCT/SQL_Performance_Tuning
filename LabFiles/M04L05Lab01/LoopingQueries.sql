/*============================================================================
	SQL Server Module 04  
	LoopingQueries.sql
	

	SQL Server 
------------------------------------------------------------------------------

	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/
use AdventureworksPTO
go

SET NOCOUNT ON
go
Select 'Looping'
WHILE 1=1
BEGIN


					SELECT /* 1 */ City, count(*) AS NumberOfOrders
					FROM NewAddress a JOIN NewSalesOrderHeader sh ON a.AddressID = sh.ShipToAddressID
					WHERE StateProvinceID = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'CA')
					GROUP BY City
					ORDER BY NumberOfOrders DESC;

					SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
					FROM
						(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
						FROM NewSalesOrderDetail d,
							(SELECT SalesOrderID
							FROM dbo.NewSalesOrderHeader
							WHERE OnlineOrderFlag = 'True') s
						WHERE d.SalesOrderID = s.SalesOrderID
						GROUP BY d.SalesOrderID ) x,
						dbo.NewSalesOrderHeader h,
						dbo.NewCustomer c,
						dbo.NewAddress a
					WHERE x.SalesOrderID = h.SalesOrderID
					AND h.CustomerID = c.CustomerID
					AND c.TerritoryID = a.AddressID;

					SELECT /* 2 */ c.CustomerID, c.ModifiedDate, City
					FROM NewCustomer c JOIN NewAddress a ON a.AddressID = c.TerritoryID
					WHERE c.CustomerID > 13000
					AND c.CustomerID < 22000;

					SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
					FROM
						(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
						FROM NewSalesOrderDetail d,
							(SELECT SalesOrderID
							FROM dbo.NewSalesOrderHeader
							WHERE OnlineOrderFlag = 'True') s
						WHERE d.SalesOrderID = s.SalesOrderID
						GROUP BY d.SalesOrderID ) x,
						dbo.NewSalesOrderHeader h,
						dbo.NewCustomer c,
						dbo.NewAddress a
					WHERE x.SalesOrderID = h.SalesOrderID
					AND h.CustomerID = c.CustomerID
					AND c.TerritoryID = a.AddressID;

					SELECT /* 3 */ c.CustomerID, c.ModifiedDate, City
					FROM NewCustomer c JOIN NewAddress a ON a.AddressID = c.TerritoryID
					WHERE c.CustomerID = 16701;

					SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
					FROM
						(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
						FROM NewSalesOrderDetail d,
							(SELECT SalesOrderID
							FROM dbo.NewSalesOrderHeader
							WHERE OnlineOrderFlag = 'True') s
						WHERE d.SalesOrderID = s.SalesOrderID
						GROUP BY d.SalesOrderID ) x,
						dbo.NewSalesOrderHeader h,
						dbo.NewCustomer c,
						dbo.NewAddress a
					WHERE x.SalesOrderID = h.SalesOrderID
					AND h.CustomerID = c.CustomerID
					AND c.TerritoryID = a.AddressID;

					SELECT /* 4 */ c.CustomerID, c.TerritoryID, City
					FROM NewCustomer c JOIN NewAddress a ON a.AddressID = c.TerritoryID
					ORDER BY c.CustomerID, City;

					SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
					FROM
						(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
						FROM NewSalesOrderDetail d,
							(SELECT SalesOrderID
							FROM dbo.NewSalesOrderHeader
							WHERE OnlineOrderFlag = 'True') s
						WHERE d.SalesOrderID = s.SalesOrderID
						GROUP BY d.SalesOrderID ) x,
						dbo.NewSalesOrderHeader h,
						dbo.NewCustomer c,
						dbo.NewAddress a
					WHERE x.SalesOrderID = h.SalesOrderID
					AND h.CustomerID = c.CustomerID
					AND c.TerritoryID = a.AddressID;

					SELECT /* 6 */ AddressLine1, AddressLine2, City
					FROM NewAddress
					WHERE
					((StateProvinceID > 0 AND StateProvinceID < 12)
					OR
					(StateProvinceID > 49 AND StateProvinceID < 76))
					AND City LIKE '%x%';
		
					SELECT /* 5 */ x.total_price, a.AddressLine1, a.AddressLine2, a.City
					FROM
						(SELECT sum(d.UnitPrice) total_price, d.SalesOrderID
						FROM NewSalesOrderDetail d,
							(SELECT SalesOrderID
							FROM dbo.NewSalesOrderHeader
							WHERE OnlineOrderFlag = 'True') s
						WHERE d.SalesOrderID = s.SalesOrderID
						GROUP BY d.SalesOrderID ) x,
						dbo.NewSalesOrderHeader h,
						dbo.NewCustomer c,
						dbo.NewAddress a
					WHERE x.SalesOrderID = h.SalesOrderID
					AND h.CustomerID = c.CustomerID
					AND c.TerritoryID = a.AddressID;
END
go