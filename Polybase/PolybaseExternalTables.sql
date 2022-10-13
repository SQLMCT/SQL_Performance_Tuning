CREATE SCHEMA [asb];
GO


-- Now let's create the external tables. All we are doing here is defining column names and data types, 
-- and binding them to the location and format of the Azure blob storage files. The location is the folder 
-- under the root directory of the Azure Storage Blob.

--DimAccount
CREATE EXTERNAL TABLE [asb].DimAccount 
(
	[AccountKey] [int] NOT NULL,
	[ParentAccountKey] [int] NULL,
	[AccountLabel] [nvarchar](100) NULL,
	[AccountName] [nvarchar](50) NULL,
	[AccountDescription] [nvarchar](50) NULL,
	[AccountType] [nvarchar](50) NULL,
	[Operator] [nvarchar](50) NULL,
	[CustomMembers] [nvarchar](300) NULL,
	[ValueType] [nvarchar](50) NULL,
	[CustomMemberOptions] [nvarchar](200) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH 
(
    LOCATION='/DimAccount/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimChannel
CREATE EXTERNAL TABLE [asb].DimChannel 
(
	[ChannelKey] [int] NOT NULL,
	[ChannelLabel] [nvarchar](100) NOT NULL,
	[ChannelName] [nvarchar](20) NULL,
	[ChannelDescription] [nvarchar](50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimChannel/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimCurrency
CREATE EXTERNAL TABLE [asb].DimCurrency 
(
	[CurrencyKey] [int] NOT NULL,
	[CurrencyLabel] [nvarchar](10) NOT NULL,
	[CurrencyName] [nvarchar](20) NOT NULL,
	[CurrencyDescription] [nvarchar](50) NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimCurrency/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--DimCustomer
CREATE EXTERNAL TABLE [asb].DimCustomer 
(
	[CustomerKey] [int]  NOT NULL,
	[GeographyKey] [int] NOT NULL,
	[CustomerLabel] [nvarchar](100) NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[NameStyle] [bit] NULL,
	[BirthDate] [datetime] NULL,
	[MaritalStatus] [nchar](1) NULL,
	[Suffix] [nvarchar](10) NULL,
	[Gender] [nvarchar](1) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[YearlyIncome] [money] NULL,
	[TotalChildren] [tinyint] NULL,
	[NumberChildrenAtHome] [tinyint] NULL,
	[Education] [nvarchar](40) NULL,
	[Occupation] [nvarchar](100) NULL,
	[HouseOwnerFlag] [nchar](1) NULL,
	[NumberCarsOwned] [tinyint] NULL,
	[AddressLine1] [nvarchar](120) NULL,
	[AddressLine2] [nvarchar](120) NULL,
	[Phone] [nvarchar](20) NULL,
	[DateFirstPurchase] [datetime] NULL,
	[CustomerType] [nvarchar](15) NULL,
	[CompanyName] [nvarchar](100) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimCustomer/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--DimDate
CREATE EXTERNAL TABLE [asb].DimDate
(
	[Datekey] [datetime] NOT NULL,
	[FullDateLabel] [nvarchar](20) NOT NULL,
	[DateDescription] [nvarchar](20) NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarYearLabel] [nvarchar](20) NOT NULL,
	[CalendarHalfYear] [int] NOT NULL,
	[CalendarHalfYearLabel] [nvarchar](20) NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarQuarterLabel] [nvarchar](20) NULL,
	[CalendarMonth] [int] NOT NULL,
	[CalendarMonthLabel] [nvarchar](20) NOT NULL,
	[CalendarWeek] [int] NOT NULL,
	[CalendarWeekLabel] [nvarchar](20) NOT NULL,
	[CalendarDayOfWeek] [int] NOT NULL,
	[CalendarDayOfWeekLabel] [nvarchar](10) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FiscalYearLabel] [nvarchar](20) NOT NULL,
	[FiscalHalfYear] [int] NOT NULL,
	[FiscalHalfYearLabel] [nvarchar](20) NOT NULL,
	[FiscalQuarter] [int] NOT NULL,
	[FiscalQuarterLabel] [nvarchar](20) NOT NULL,
	[FiscalMonth] [int] NOT NULL,
	[FiscalMonthLabel] [nvarchar](20) NOT NULL,
	[IsWorkDay] [nvarchar](20) NOT NULL,
	[IsHoliday] [int] NOT NULL,
	[HolidayName] [nvarchar](20) NOT NULL,
	[EuropeSeason] [nvarchar](50) NULL,
	[NorthAmericaSeason] [nvarchar](50) NULL,
	[AsiaSeason] [nvarchar](50) NULL
)
WITH
(
    LOCATION='/DimDate/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimEmployee
CREATE EXTERNAL TABLE [asb].DimEmployee 
(
	[EmployeeKey] [int]  NOT NULL,
	[ParentEmployeeKey] [int] NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[Title] [nvarchar](50) NULL,
	[HireDate] [datetime] NULL,
	[BirthDate] [datetime] NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[Phone] [nvarchar](25) NULL,
	[MaritalStatus] [nchar](1) NULL,
	[EmergencyContactName] [nvarchar](50) NULL,
	[EmergencyContactPhone] [nvarchar](25) NULL,
	[SalariedFlag] [bit] NULL,
	[Gender] [nchar](1) NULL,
	[PayFrequency] [tinyint] NULL,
	[BaseRate] [money] NULL,
	[VacationHours] [smallint] NULL,
	[CurrentFlag] [bit] NOT NULL,
	[SalesPersonFlag] [bit] NOT NULL,
	[DepartmentName] [nvarchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimEmployee/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimEntity
CREATE EXTERNAL TABLE [asb].DimEntity 
(
	[EntityKey] [int] NOT NULL,
	[EntityLabel] [nvarchar](100) NULL,
	[ParentEntityKey] [int] NULL,
	[ParentEntityLabel] [nvarchar](100) NULL,
	[EntityName] [nvarchar](50) NULL,
	[EntityDescription] [nvarchar](100) NULL,
	[EntityType] [nvarchar](100) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimEntity/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimGeography
CREATE EXTERNAL TABLE [asb].DimGeography 
(
	[GeographyKey] [int] NOT NULL,
	[GeographyType] [nvarchar](50) NOT NULL,
	[ContinentName] [nvarchar](50) NOT NULL,
	[CityName] [nvarchar](100) NULL,
	[StateProvinceName] [nvarchar](100) NULL,
	[RegionCountryName] [nvarchar](100) NULL,
--	[Geometry] [geometry] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimGeography/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimMachine
CREATE EXTERNAL TABLE [asb].DimMachine 
(
	[MachineKey] [int] NOT NULL,
	[MachineLabel] [nvarchar](100) NULL,
	[StoreKey] [int] NOT NULL,
	[MachineType] [nvarchar](50) NOT NULL,
	[MachineName] [nvarchar](100) NOT NULL,
	[MachineDescription] [nvarchar](200) NOT NULL,
	[VendorName] [nvarchar](50) NOT NULL,
	[MachineOS] [nvarchar](50) NOT NULL,
	[MachineSource] [nvarchar](100) NOT NULL,
	[MachineHardware] [nvarchar](100) NULL,
	[MachineSoftware] [nvarchar](100) NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[ServiceStartDate] [datetime] NOT NULL,
	[DecommissionDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimMachine/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimOutage
CREATE EXTERNAL TABLE [asb].DimOutage (
	[OutageKey] [int]  NOT NULL,
	[OutageLabel] [nvarchar](100) NOT NULL,
	[OutageName] [nvarchar](50) NOT NULL,
	[OutageDescription] [nvarchar](200) NOT NULL,
	[OutageType] [nvarchar](50) NOT NULL,
	[OutageTypeDescription] [nvarchar](200) NOT NULL,
	[OutageSubType] [nvarchar](50) NOT NULL,
	[OutageSubTypeDescription] [nvarchar](200) NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimOutage/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimProduct
CREATE EXTERNAL TABLE [asb].DimProduct (
	[ProductKey] [int] NOT NULL,
	[ProductLabel] [nvarchar](255) NULL,
	[ProductName] [nvarchar](500) NULL,
	[ProductDescription] [nvarchar](400) NULL,
	[ProductSubcategoryKey] [int] NULL,
	[Manufacturer] [nvarchar](50) NULL,
	[BrandName] [nvarchar](50) NULL,
	[ClassID] [nvarchar](10) NULL,
	[ClassName] [nvarchar](20) NULL,
	[StyleID] [nvarchar](10) NULL,
	[StyleName] [nvarchar](20) NULL,
	[ColorID] [nvarchar](10) NULL,
	[ColorName] [nvarchar](20) NOT NULL,
	[Size] [nvarchar](50) NULL,
	[SizeRange] [nvarchar](50) NULL,
	[SizeUnitMeasureID] [nvarchar](20) NULL,
	[Weight] [float] NULL,
	[WeightUnitMeasureID] [nvarchar](20) NULL,
	[UnitOfMeasureID] [nvarchar](10) NULL,
	[UnitOfMeasureName] [nvarchar](40) NULL,
	[StockTypeID] [nvarchar](10) NULL,
	[StockTypeName] [nvarchar](40) NULL,
	[UnitCost] [money] NULL,
	[UnitPrice] [money] NULL,
	[AvailableForSaleDate] [datetime] NULL,
	[StopSaleDate] [datetime] NULL,
	[Status] [nvarchar](7) NULL,
	[ImageURL] [nvarchar](150) NULL,
	[ProductURL] [nvarchar](150) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimProduct/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimProductCategory
CREATE EXTERNAL TABLE [asb].DimProductCategory (
	[ProductCategoryKey] [int]  NOT NULL,
	[ProductCategoryLabel] [nvarchar](100) NULL,
	[ProductCategoryName] [nvarchar](30) NOT NULL,
	[ProductCategoryDescription] [nvarchar](50) NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimProductCategory/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimProductSubcategory
CREATE EXTERNAL TABLE [asb].DimProductSubcategory (
	[ProductSubcategoryKey] [int]  NOT NULL,
	[ProductSubcategoryLabel] [nvarchar](100) NULL,
	[ProductSubcategoryName] [nvarchar](50) NOT NULL,
	[ProductSubcategoryDescription] [nvarchar](100) NULL,
	[ProductCategoryKey] [int] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimProductSubcategory/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimPromotion
CREATE EXTERNAL TABLE [asb].DimPromotion (
	[PromotionKey] [int]  NOT NULL,
	[PromotionLabel] [nvarchar](100) NULL,
	[PromotionName] [nvarchar](100) NULL,
	[PromotionDescription] [nvarchar](255) NULL,
	[DiscountPercent] [float] NULL,
	[PromotionType] [nvarchar](50) NULL,
	[PromotionCategory] [nvarchar](50) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[MinQuantity] [int] NULL,
	[MaxQuantity] [int] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimPromotion/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
 
--DimSalesTerritory
CREATE EXTERNAL TABLE [asb].DimSalesTerritory (
	[SalesTerritoryKey] [int]  NOT NULL,
	[GeographyKey] [int] NOT NULL,
	[SalesTerritoryLabel] [nvarchar](100) NULL,
	[SalesTerritoryName] [nvarchar](50) NOT NULL,
	[SalesTerritoryRegion] [nvarchar](50) NOT NULL,
	[SalesTerritoryCountry] [nvarchar](50) NOT NULL,
	[SalesTerritoryGroup] [nvarchar](50) NULL,
	[SalesTerritoryLevel] [nvarchar](10) NULL,
	[SalesTerritoryManager] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimSalesTerritory/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--DimScenario
CREATE EXTERNAL TABLE [asb].DimScenario (
	[ScenarioKey] [int] NOT NULL,
	[ScenarioLabel] [nvarchar](100) NOT NULL,
	[ScenarioName] [nvarchar](20) NULL,
	[ScenarioDescription] [nvarchar](50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimScenario/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--DimStore
CREATE EXTERNAL TABLE [asb].DimStore 
(
	[StoreKey] [int] NOT NULL,
	[GeographyKey] [int] NOT NULL,
	[StoreManager] [int] NULL,
	[StoreType] [nvarchar](15) NULL,
	[StoreName] [nvarchar](100) NOT NULL,
	[StoreDescription] [nvarchar](300) NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
	[OpenDate] [datetime] NOT NULL,
	[CloseDate] [datetime] NULL,
	[EntityKey] [int] NULL,
	[ZipCode] [nvarchar](20) NULL,
	[ZipCodeExtension] [nvarchar](10) NULL,
	[StorePhone] [nvarchar](15) NULL,
	[StoreFax] [nvarchar](14) NULL,
	[AddressLine1] [nvarchar](100) NULL,
	[AddressLine2] [nvarchar](100) NULL,
	[CloseReason] [nvarchar](20) NULL,
	[EmployeeCount] [int] NULL,
	[SellingAreaSize] [float] NULL,
	[LastRemodelDate] [datetime] NULL,
	[GeoLocation]	NVARCHAR(50)  NULL,
	[Geometry]		NVARCHAR(50) NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/DimStore/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--FactExchangeRate
CREATE EXTERNAL TABLE [asb].FactExchangeRate 
(
	[ExchangeRateKey] [int]  NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[AverageRate] [float] NOT NULL,
	[EndOfDayRate] [float] NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactExchangeRate/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--FactInventory
CREATE EXTERNAL TABLE [asb].FactInventory (
	[InventoryKey] [int]  NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[OnHandQuantity] [int] NOT NULL,
	[OnOrderQuantity] [int] NOT NULL,
	[SafetyStockQuantity] [int] NULL,
	[UnitCost] [money] NOT NULL,
	[DaysInStock] [int] NULL,
	[MinDayInStock] [int] NULL,
	[MaxDayInStock] [int] NULL,
	[Aging] [int] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactInventory/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--FactITMachine
CREATE EXTERNAL TABLE [asb].FactITMachine (
	[ITMachinekey] [int] NOT NULL,
	[MachineKey] [int] NOT NULL,
	[Datekey] [datetime] NOT NULL,
	[CostAmount] [money] NULL,
	[CostType] [nvarchar](200) NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactITMachine/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;


--FactITSLA
CREATE EXTERNAL TABLE [asb].FactITSLA 
(
	[ITSLAkey] [int]  NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[MachineKey] [int] NOT NULL,
	[OutageKey] [int] NOT NULL,
	[OutageStartTime] [datetime] NOT NULL,
	[OutageEndTime] [datetime] NOT NULL,
	[DownTime] [int] NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactITSLA/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--FactOnlineSales
CREATE EXTERNAL TABLE [asb].FactOnlineSales 
(
	[OnlineSalesKey] [int]  NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[SalesOrderNumber] [nvarchar](20) NOT NULL,
	[SalesOrderLineNumber] [int] NULL,
	[SalesQuantity] [int] NOT NULL,
	[SalesAmount] [money] NOT NULL,
	[ReturnQuantity] [int] NOT NULL,
	[ReturnAmount] [money] NULL,
	[DiscountQuantity] [int] NULL,
	[DiscountAmount] [money] NULL,
	[TotalCost] [money] NOT NULL,
	[UnitCost] [money] NULL,
	[UnitPrice] [money] NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactOnlineSales/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--FactSales
CREATE EXTERNAL TABLE [asb].FactSales 
(
	[SalesKey] [int]  NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[channelKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[PromotionKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[UnitCost] [money] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[SalesQuantity] [int] NOT NULL,
	[ReturnQuantity] [int] NOT NULL,
	[ReturnAmount] [money] NULL,
	[DiscountQuantity] [int] NULL,
	[DiscountAmount] [money] NULL,
	[TotalCost] [money] NOT NULL,
	[SalesAmount] [money] NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactSales/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;

--FactSalesQuota
CREATE EXTERNAL TABLE [asb].FactSalesQuota (
	[SalesQuotaKey] [int]  NOT NULL,
	[ChannelKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[ScenarioKey] [int] NOT NULL,
	[SalesQuantityQuota] [money] NOT NULL,
	[SalesAmountQuota] [money] NOT NULL,
	[GrossMarginQuota] [money] NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactSalesQuota/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
 
--FactStrategyPlan
CREATE EXTERNAL TABLE [asb].FactStrategyPlan 
(
	[StrategyPlanKey] [int]  NOT NULL,
	[Datekey] [datetime] NOT NULL,
	[EntityKey] [int] NOT NULL,
	[ScenarioKey] [int] NOT NULL,
	[AccountKey] [int] NOT NULL,
	[CurrencyKey] [int] NOT NULL,
	[ProductCategoryKey] [int] NULL,
	[Amount] [money] NOT NULL,
	[ETLLoadID] [int] NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
)
WITH
(
    LOCATION='/FactStrategyPlan/' 
,   DATA_SOURCE = AzureStorage_west_public
,   FILE_FORMAT = TextFileFormat
,   REJECT_TYPE = VALUE
,   REJECT_VALUE = 0
)
;
