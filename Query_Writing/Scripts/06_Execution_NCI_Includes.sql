USE AdventureWorks2016
GO

--Show IX_Address_StateProvince Index
--SELECT * will need to find all columns
SELECT *
FROM Person.Address
WHERE StateProvinceID = 119

--Show IX_Address_StateProvince Index
--SELECT only columns in Index
--This is an index that covers a query
SELECT AddressID, StateProvinceID
FROM Person.Address
WHERE StateProvinceID = 119

--Show IX_Address_StateProvince Index
--City is not covered in the Index
--Use INCLUDE to add City to Index
SELECT AddressID, StateProvinceID, City
FROM Person.Address
WHERE StateProvinceID = 119

