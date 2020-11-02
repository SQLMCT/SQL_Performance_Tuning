--Build script for Joins Demo
--Check if objects exists and drop for new demo
DROP TABLE IF EXISTS Demo.Orders
DROP TABLE IF EXISTS Demo.Customers
DROP TABLE IF EXISTS Demo.Products
DROP SCHEMA IF EXISTS Demo
GO

--Create Schema for Demo tables
CREATE SCHEMA Demo Authorization dbo
GO

--Create three tables
--Customers table will have a Primary Key named CustomerID.
--This table does not have a Foreign Key.
CREATE TABLE Demo.Customers
(CustomerID smallint PRIMARY KEY,
 First_Name varchar(10),
 Last_Name varchar(15),
 Club tinyint)
GO

--Products table will have a Primary Key named ProductID
--This table does not have a Foreign Key.
CREATE TABLE Demo.Products
(ProductID int Primary Key,
 ProductName varchar(30),
 Price smallmoney)
GO

--Orders table will have a Primary Key and a two Foreign Keys 
--The key referencing the Customers table is added at table creation.
--The key referecing the Products table is added after table creation.
CREATE TABLE Demo.Orders
(OrderID int IDENTITY PRIMARY KEY,
 CustID smallint,
 ProductID int,
 Qty tinyint,
 OrderDate date,
 CONSTRAINT FK_Customers_Orders FOREIGN KEY(CustID) --Adding the first FK
	REFERENCES Demo.Customers(CustomerID)
	ON UPDATE CASCADE ON DELETE SET NULL
 )
GO

--ALTER Orders Table to add the second Foriegn Key
ALTER TABLE Demo.Orders
ADD CONSTRAINT FK_Products_Orders FOREIGN KEY(ProductID)
	REFERENCES Demo.Products(ProductID)
GO

--INSERT Records into the Customers table.
INSERT INTO Demo.Customers
VALUES (250, 'Andy', 'Anderson', 1),
	   (255, 'Jeff', 'Rollins', 0),
	   (267, 'Bob', 'Smith', 1),
	   (278, 'Jenny', 'Jefferson', 0),
	   (388, 'Cindy', 'Samuels', 2)
GO

--INSERT Records into the Products table.
INSERT INTO Demo.Products
VALUES (23569, 'Data Science Handbook', 5.60),
	   (29058, 'Hit Refresh', 4.25),
	   (30550, 'Fantasy Football Mistakes', 3.15),
	   (32575, 'Power BI in a Day', 2.45),
	   (32600, 'Writing T-SQL Made Easy', 3.20),
	   (32660, 'Intentionally Left Blank', 3.75),
	   (32667, 'Azure SQL for Beginners', 2.50),
	   (33002, 'The Case of the Missing Syntax', 3.75)
GO	   

--Disable Constraints on Demo.Orders table to allow INSERT.
--This disables referential integrity. For Demo purposes only.
ALTER TABLE Demo.Orders NOCHECK CONSTRAINT FK_Customers_Orders
ALTER TABLE Demo.Orders NOCHECK CONSTRAINT FK_Products_Orders
GO

--INSERT Records into the Orders table.
INSERT INTO Demo.Orders
VALUES (250, 23569, 3, '20161102'),
	   (250, 32575, 3, '20161103'),
	   (250, 32600, 5, '20161104'),
	   (255, 30550, 4, '20161205'),
	   (278, 33002, 6, '20170216'),
	   (290, 32667, 9, '20170317'),
	   (388, 32600, 7, '20170415'),
	   (388, 29058, 5, '20170415'),
	   (402, 32660, 2, '20170501')
GO

--Re-Enable Constraints on the Orders table.
ALTER TABLE Demo.Orders CHECK CONSTRAINT FK_Customers_Orders
ALTER TABLE Demo.Orders CHECK CONSTRAINT FK_Products_Orders
GO




	   









