--Uset the * to SELECT all the columns from a table
SELECT * FROM SalesLT.Customer

--It is best practice to choose specific columns
--For performance only retrieve what you need.
SELECT FirstName, LastName
FROM SalesLT.Customer

--You can also sort your results with an OrderBy statement
SELECT FirstName, LastName
FROM SalesLT.Customer
ORDER BY LastName DESC, FirstName ASC

--Filtering Records for a single row (Numbers)
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE CustomerID = 4

--Filtering for multiple rows (Numbers)
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE CustomerID = 4 or CustomerID = 6

--Filtering for multiple rows using the IN predicate (Numbers)
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE CustomerID IN (4, 6)

--Filtering Records for a single row (Text)
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE LastName = 'Gates'

--Filtering using the LIKE statement and %
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE LastName LIKE 'G%'

--Filtering using the LIKE statement and _
SELECT FirstName, LastName
FROM SalesLT.Customer
WHERE LastName LIKE '_a%'

--Filtering Records for NULL values
SELECT FirstName, LastName, MiddleName
FROM SalesLT.Customer
WHERE MiddleName IS NULL

--Filtering Records for NULL values
SELECT FirstName, LastName, MiddleName
FROM SalesLT.Customer
WHERE MiddleName IS NOT NULL







