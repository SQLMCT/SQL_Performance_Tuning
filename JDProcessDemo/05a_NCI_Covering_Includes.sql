USE AdventureWorks2019
GO

--List the indexes
EXEC [sp_helpindex] 'Person.Address';
GO

--Find index pages for the table
DBCC IND(0,'Person.Address',-1)

--Look inside the data and index pages
DBCC TRACEON(3604,-1) 
DBCC PAGE(0, 1, 26080, 3)

--New Dynamic Management view from SQL Server 2016
SELECT index_id, allocated_page_page_id
FROM sys.dm_db_database_page_allocations
(DB_ID(), object_ID('Person.Address'), NULL, NULL, 'LIMITED')
WHERE index_id = 4 and allocated_page_iam_file_id IS NOT NULL
GO

--Show IX_Address_StateProvince Index
--SELECT * will need to find all columns
SELECT *
FROM Person.Address
WHERE StateProvinceID = 3

--Show IX_Address_StateProvince Index
--SELECT only columns in Index
--This is an index that covers a query
SELECT AddressID, StateProvinceID
FROM Person.Address
WHERE StateProvinceID = 3

--Show IX_Address_StateProvince Index
--City is not covered in the Index
--Use INCLUDE to add City to Index
SELECT AddressID, StateProvinceID, City
FROM Person.Address
WHERE StateProvinceID = 3

--.0230399 with Key Lookup
--.0032897 with ADD City
--.0032897 with INCLUDE City


--Introduce a Page Split
INSERT INTO Person.Address
(AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, SpatialLocation, rowguid, ModifiedDate)
VALUES ('3548 Combahee Road', NULL, 'Greenbow', 3, '29944', 0xE6100000010C81A75BBCD45C414036C6FAAE20A755C0, NEWID(), CURRENT_TIMESTAMP)

--237
--120
--214

ALTER INDEX [IX_Address_StateProvinceID] 
ON [Person].[Address] 
REBUILD 
WITH (FILLFACTOR = 90)

DELETE FROM Person.Address
WHERE City = 'Greenbow'




/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys� fees, that arise or 
result from the use or distribution of the Sample Code.
*/


