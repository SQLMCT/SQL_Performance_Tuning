--	create CPU stress. Open a query window in Management Studio and run:

USE AdventureWorksPTO
GO
SELECT top 200000 *
FROM Production.ProductListPriceHistory 
	INNER JOIN Production.ProductCostHistory 
		INNER JOIN Production.Product 
			ON Production.ProductCostHistory.ProductID = Production.Product.ProductID 
		INNER JOIN Production.ProductDocument AS ProductDocument_1 
			ON Production.Product.ProductID = ProductDocument_1.ProductID 
		INNER JOIN Production.ProductInventory 
			ON Production.Product.ProductID = Production.ProductInventory.ProductID 
		ON Production.ProductListPriceHistory.ProductID = Production.Product.ProductID 
	INNER JOIN Production.ProductModel 
		ON Production.Product.ProductModelID = Production.ProductModel.ProductModelID 
	INNER JOIN Production.ProductSubcategory 
		ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID 
	INNER JOIN Production.ProductCategory 
		ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID 
			AND Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID 
	CROSS JOIN Production.ProductDescription Test 
	INNER JOIN Production.ProductDescription 
		ON Test.ProductDescriptionID = Production.ProductDescription.ProductDescriptionID 
	CROSS JOIN Person.Address


-- Open a query window in Management Studio and run:
USE AdventureWorksPTO
GO

SELECT *
FROM Person.Address 
	INNER JOIN Person.BusinessEntityAddress 
		ON Person.Address.AddressID = Person.BusinessEntityAddress.AddressID 
	INNER JOIN Person.BusinessEntity 
		ON Person.BusinessEntityAddress.BusinessEntityID = Person.BusinessEntity.BusinessEntityID 
	INNER JOIN Person.BusinessEntityContact 
		ON Person.BusinessEntity.BusinessEntityID = Person.BusinessEntityContact.BusinessEntityID
GO