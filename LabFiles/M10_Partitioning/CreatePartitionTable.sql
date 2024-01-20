use PartitionDB
go
----------------------------------------------------------------------------------------------------
----Creating Partition function for  5 partitions --------
----------------------------------------------------------------------------------------------------
CREATE PARTITION FUNCTION OrderHeader_TerritoryPartitions_PFN(INT)  
AS   
RANGE RIGHT FOR VALUES (1,2,3,4)    

GO  
----------------------------------------------------------------------------------------------------
-----------creating Partition schema 
----------------------------------------------------------------------------------------------------
CREATE PARTITION SCHEME [OrderHeader_TerritoryPartitions_PS]  
AS   
PARTITION [OrderHeader_TerritoryPartitions_PFN] 
TO (
		SalesOrders_DataPartition1, 
		SalesOrders_DataPartition2,   
		SalesOrders_DataPartition3, 
		SalesOrders_DataPartition4,   
		SalesOrders_DataPartition5 
	    )  
GO 


-----creating table using patition function and schema----
-----------------------------------------------------------------------------------------------------------------------
-------------------------------Data Custom Data type used to create Table ------------------------------
-----------------------------------------------------------------------------------------------------------------------

/****** Object:  Table [Sales].[SalesOrderHeader]    Script Date: 5/9/2018 9:37:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  UserDefinedDataType [dbo].[AccountNumber]    Script Date: 5/9/2018 9:42:31 PM ******/
CREATE TYPE [AccountNumber] FROM [nvarchar](15) NULL
GO
/****** Object:  UserDefinedDataType [dbo].[Flag]    Script Date: 5/9/2018 9:42:42 PM ******/
CREATE TYPE [Flag] FROM [bit] NOT NULL
GO
/****** Object:  UserDefinedDataType [dbo].[OrderNumber]    Script Date: 5/9/2018 9:42:55 PM ******/
CREATE TYPE [OrderNumber] FROM [nvarchar](25) NULL
GO
----------------------------------------------------------------------------------------------------
-----------creating Partition schema 
----------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS [SalesOrderHeader] 
GO
CREATE TABLE [SalesOrderHeader](
	[SalesOrderID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[OnlineOrderFlag] FLAG NOT NULL,
	[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
	[CustomerID] [int] NOT NULL,
	[SalesPersonID] [int] NULL,
	[TerritoryID] [int] NOT NULL,
	[BillToAddressID] [int] NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CreditCardID] [int] NULL,
	[CreditCardApprovalCode] [varchar](15) NULL,
	[CurrencyRateID] [int] NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	[Comment] [nvarchar](128) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
) 	ON [OrderHeader_TerritoryPartitions_PS] (TerritoryID) 
GO
