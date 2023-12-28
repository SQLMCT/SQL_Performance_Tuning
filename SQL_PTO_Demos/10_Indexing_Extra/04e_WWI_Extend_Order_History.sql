/*	Create large row mode tables that are based on WideWorldImportersDW
	Credits to Joe Sack from Microsoft for this script
	This assumes you have restored the WideWorldImportersDW full backup.
	This script will take 30 minutes to execute!*/

USE WideWorldImportersDW
GO

-- Build a new rowmode table called OrderHistory based off of Orders
--
DROP TABLE IF EXISTS Fact.OrderHistory
GO

SELECT 'Buliding OrderHistory from Orders...'
GO
SELECT [OrderKey], [CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey]
INTO Fact.OrderHistory
FROM Fact.[Order]
GO

ALTER TABLE Fact.OrderHistory
ADD CONSTRAINT PK_Fact_OrderHistory PRIMARY KEY NONCLUSTERED([OrderKey] ASC, [OrderDateKey] ASC)WITH(DATA_COMPRESSION=PAGE);
GO

CREATE INDEX IX_Stock_Item_Key
ON Fact.OrderHistory([StockItemKey])
INCLUDE(Quantity)
WITH(DATA_COMPRESSION=PAGE)
GO

CREATE INDEX IX_OrderHistory_Quantity
ON Fact.OrderHistory([Quantity])
INCLUDE([OrderKey])
WITH(DATA_COMPRESSION=PAGE)
GO

-- Table should have 231,412 rows
SELECT 'Number of rows in Fact.OrderHistory = ', COUNT(*) FROM Fact.OrderHistory
GO

SELECT 'Increasing number of rows for OrderHistory...'
GO
-- Make the table bigger
INSERT Fact.OrderHistory([CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey])
SELECT [CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey]
FROM Fact.OrderHistory
GO 4

-- Table should have 3,702,592 rows
SELECT 'Number of rows in Fact.OrderHistory = ', COUNT(*) FROM Fact.OrderHistory
GO

SELECT 'Building OrderHistoryExtended from OrderHistory...'
GO
-- Bulid an even bigger rowmode table based on OrderHistory
DROP TABLE IF EXISTS Fact.OrderHistoryExtended
GO
SELECT [OrderKey], [CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey]
INTO Fact.OrderHistoryExtended
FROM Fact.[OrderHistory]
GO

ALTER TABLE Fact.OrderHistoryExtended
ADD CONSTRAINT PK_Fact_OrderHistoryExtended PRIMARY KEY NONCLUSTERED([OrderKey] ASC, [OrderDateKey] ASC)
WITH(DATA_COMPRESSION=PAGE)
GO

CREATE INDEX IX_Stock_Item_Key
ON Fact.OrderHistoryExtended([StockItemKey])
INCLUDE(Quantity);
GO

-- Table should have 3,702,592 rows
SELECT 'Number of rows in Fact.OrderHistoryExtended = ', 
COUNT(*) FROM Fact.OrderHistoryExtended
GO

SELECT 'Increasing number of rows for OrderHistoryExtended...'
GO

-- Make the table bigger
INSERT Fact.OrderHistoryExtended([CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey])
SELECT [CityKey], [CustomerKey], [StockItemKey], [OrderDateKey], [PickedDateKey], [SalespersonKey], [PickerKey], [WWIOrderID], [WWIBackorderID], Description, Package, Quantity, [UnitPrice], [TaxRate], [TotalExcludingTax], [TaxAmount], [TotalIncludingTax], [LineageKey]
FROM Fact.OrderHistoryExtended;
GO 3

-- Fact.OrderHistoryExtended Table should have 29,620,736 rows
SELECT 'Number of rows in Fact.OrderHistoryExtended = ', COUNT(*) FROM Fact.OrderHistoryExtended
GO

UPDATE Fact.OrderHistoryExtended
SET [WWIOrderID] = [OrderKey];
GO