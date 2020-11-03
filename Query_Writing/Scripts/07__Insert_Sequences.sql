--Demonstrate working with Sequences
USE AdventureWorks2016
GO

--Create a Sequence object to increment values
--across multiple tables
CREATE SEQUENCE dbo.SeqOrders
AS int START with 100 INCREMENT by 100
GO

--Create two tables for demonstration.
CREATE TABLE North_Orders
(OrderID int Primary Key, Store char(5))
CREATE TABLE South_Orders
(OrderID int Primary Key, Store char(5))
GO

--INSERT Sequence values
INSERT INTO North_Orders
VALUES (NEXT VALUE FOR dbo.SeqOrders, 'North')
INSERT INTO South_Orders
VALUES (NEXT VALUE FOR dbo.SeqOrders, 'South')
GO 5 --Runs this insert batch five times

SELECT OrderID, Store FROM North_Orders
UNION
SELECT OrderID, Store FROM South_Orders




