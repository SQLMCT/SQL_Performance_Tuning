USE AdventureWorksPTO
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

-- IMPORTANT: Click on Include Actual Execution Plan or press Ctrl+M

EXEC up_getSalesOrderDetail_by_CarrierTrackingNumber 'A14C-49FF-A8'
GO

INSERT INTO [Sales].[SalesOrderDetailLab]
           ([SalesOrderID],[SalesOrderDetailID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [SalesOrderID],[SalesOrderDetailID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
FROM  [Sales].[SalesOrderDetail]
WHERE ModifiedDate >= '2012-12-31' 
      AND
	  ModifiedDate < '2013-04-01' 
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

EXEC up_getSalesOrderDetail_by_CarrierTrackingNumber 'A14C-49FF-A8'
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

INSERT INTO [Sales].[SalesOrderDetailLab]
           ([SalesOrderID],[SalesOrderDetailID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [SalesOrderID],[SalesOrderDetailID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate]
FROM [Sales].[SalesOrderDetail]
WHERE ModifiedDate >= '2013-04-01' AND ModifiedDate < '2013-05-01' 
GO

EXEC up_getSalesOrderDetail_by_CarrierTrackingNumber 'A14C-49FF-A8'
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO