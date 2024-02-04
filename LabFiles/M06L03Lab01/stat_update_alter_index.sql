USE AdventureWorksPTO
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
where ModifiedDate >= '2013-05-01'
GO 

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

ALTER INDEX [ix_SalesOrderDetailLab_CarrierTrackingNumber] 
ON [Sales].[SalesOrderDetailLab]
REORGANIZE  WITH (LOB_COMPACTION = ON )
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

ALTER INDEX [ix_SalesOrderDetailLab_CarrierTrackingNumber] 
ON [Sales].[SalesOrderDetailLab]
REBUILD  
GO

SELECT * 
FROM sys.dm_db_stats_properties (OBJECT_ID('Sales.SalesOrderDetailLab'),2)
GO

