USE AdventureWorksPTO
GO

CREATE TABLE [Sales].[SalesOrderDetailLab](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[totalforline]  AS ([OrderQty]*[UnitPrice])
 CONSTRAINT [PK_SalesOrderDetailLab_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
(	[SalesOrderID] ASC,	[SalesOrderDetailID] ASC))


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
WHERE ModifiedDate < '2012-12-31'
GO

CREATE PROCEDURE up_getSalesOrderDetail_by_CarrierTrackingNumber (@ctn nvarchar(25))
AS
BEGIN
	SELECT *
	FROM [Sales].[SalesOrderDetailLab]
	WHERE CarrierTrackingNumber = @ctn
END
GO

CREATE NONCLUSTERED INDEX [ix_SalesOrderDetailLab_CarrierTrackingNumber] 
ON [Sales].[SalesOrderDetailLab] ([CarrierTrackingNumber] ASC)

CREATE EVENT SESSION [Recompilations_and_auto_stats] ON SERVER 
ADD EVENT sqlserver.auto_stats(
    WHERE ([database_id]=(5) and [index_id]=(2) and [status] <> 'Loading stats without updating')),
ADD EVENT sqlserver.sql_statement_recompile(SET collect_object_name=(1),collect_statement=(1)
    ACTION(sqlserver.database_name)
	WHERE ([object_name]=N'up_getSalesOrderDetail_by_CarrierTrackingNumber'))
ADD TARGET package0.event_file(SET filename=N'Recompilations_and_auto_stats')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=1 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [Recompilations_and_auto_stats] ON SERVER  
STATE = start;  
GO  