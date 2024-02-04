-- Select from all tables in AdventureWorksPTO
USE [AdventureWorksPTO]
GO
BEGIN TRAN
SELECT * FROM [Production].[ScrapReason] 
--GO
SELECT * FROM [HumanResources].[Shift] 
--GO
SELECT * FROM [Production].[ProductCategory] 
--GO
SELECT * FROM [Purchasing].[ShipMethod] 
--GO
SELECT * FROM [Production].[ProductCostHistory] 
--GO
SELECT * FROM [Production].[ProductDescription] 
--GO
SELECT * FROM [Sales].[ShoppingCartItem] 
--GO
SELECT * FROM [Production].[ProductDocument] 
--GO
SELECT * FROM [dbo].[DatabaseLog] 
--GO
SELECT * FROM [Production].[ProductInventory] 
--GO
SELECT * FROM [Sales].[SpecialOffer] 
--GO
SELECT * FROM [dbo].[ErrorLog] 
--GO
SELECT * FROM [Production].[ProductListPriceHistory] 
--GO
SELECT * FROM [Person].[Address] 
--GO
SELECT * FROM [Sales].[SpecialOfferProduct] 
--GO
SELECT * FROM [Production].[ProductModel] 
--GO
SELECT * FROM [Person].[AddressType] 
--GO
SELECT * FROM [Person].[StateProvince] 
--GO
SELECT * FROM [Production].[ProductModelIllustration] 
--GO
SELECT * FROM [dbo].[AWBuildVersion] 
--GO
SELECT * FROM [Production].[ProductModelProductDescriptionCulture] 
--GO
SELECT * FROM [Production].[BillOfMaterials] 
--GO
SELECT * FROM [Sales].[Store] 
--GO
SELECT * FROM [Production].[ProductPhoto] 
--GO
SELECT * FROM [Production].[ProductProductPhoto] 
--GO
SELECT * FROM [Production].[TransactionHistory] 
--GO
SELECT * FROM [Production].[ProductReview] 
--GO
SELECT * FROM [Person].[BusinessEntity] 
--GO
SELECT * FROM [Production].[TransactionHistoryArchive] 
--GO
SELECT * FROM [Production].[ProductSubcategory] 
--GO
SELECT * FROM [Person].[BusinessEntityAddress] 
--GO
SELECT * FROM [Purchasing].[ProductVendor] 
--GO
SELECT * FROM [Person].[BusinessEntityContact] 
--GO
SELECT * FROM [Production].[UnitMeasure] 
--GO
SELECT * FROM [Purchasing].[Vendor] 
--GO
SELECT * FROM [Person].[ContactType] 
--GO
SELECT * FROM [Sales].[CountryRegionCurrency] 
--GO
SELECT * FROM [Person].[CountryRegion] 
--GO
SELECT * FROM [Production].[WorkOrder] 
--GO
SELECT * FROM [Purchasing].[PurchaseOrderDetail] 
--GO
SELECT * FROM [Sales].[CreditCard] 
--GO
SELECT * FROM [Production].[Culture] 
--GO
SELECT * FROM [Production].[WorkOrderRouting] 
--GO
SELECT * FROM [Sales].[Currency] 
--GO
SELECT * FROM [Purchasing].[PurchaseOrderHeader] 
--GO
SELECT * FROM [Sales].[CurrencyRate] 
--GO
SELECT * FROM [Sales].[Customer] 
--GO
SELECT * FROM [HumanResources].[Department] 
--GO
SELECT * FROM [Production].[Document] 
--GO
SELECT * FROM [Sales].[SalesOrderDetail] 
--GO
SELECT * FROM [Person].[EmailAddress] 
--GO
SELECT * FROM [HumanResources].[Employee] 
--GO
SELECT * FROM [Sales].[SalesOrderHeader] 
--GO
SELECT * FROM [HumanResources].[EmployeeDepartmentHistory] 
--GO
SELECT * FROM [HumanResources].[EmployeePayHistory] 
--GO
SELECT * FROM [Sales].[SalesOrderHeaderSalesReason] 
--GO
SELECT * FROM [Sales].[SalesPerson] 
--GO
SELECT * FROM [Production].[Illustration] 
--GO
SELECT * FROM [HumanResources].[JobCandidate] 
--GO
SELECT * FROM [Production].[Location] 
--GO
SELECT * FROM [Person].[Password] 
--GO
SELECT * FROM [Sales].[SalesPersonQuotaHistory] 
--GO
SELECT * FROM [Person].[Person] 
--GO
SELECT * FROM [Sales].[SalesReason] 
--GO
SELECT * FROM [Sales].[SalesTaxRate] 
--GO
SELECT * FROM [Sales].[PersonCreditCard] 
--GO
SELECT * FROM [Person].[PersonPhone] 
--GO
SELECT * FROM [Sales].[SalesTerritory] 
--GO
SELECT * FROM [Person].[PhoneNumberType] 
--GO
SELECT * FROM [Production].[Product] 
--GO
SELECT * FROM [Sales].[SalesTerritoryHistory] 
--GO
COMMIT;

WAITFOR DELAY '00:00:01';
