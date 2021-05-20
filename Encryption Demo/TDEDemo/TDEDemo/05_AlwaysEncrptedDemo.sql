/* 
DROP DATABASE IF EXISTS EncryptedDB
GO
--*/
--Check that the Connection parameters are cleared.

CREATE DATABASE EncryptedDB
GO
USE EncryptedDB
GO

--Build a table with sensitive data
CREATE SCHEMA Sales Authorization dbo
CREATE TABLE Customers
(CustomerID int IDENTITY NOT NULL,
 FirstName varchar(20) NOT NULL,
 LastName varchar(20) NOT NULL,
 SSN varchar(20) NOT NULL,
 City varchar(20) NOT NULL)
GO

INSERT INTO Sales.Customers VALUES
('Lois', 'Lane', '555-47-8909', 'Metropolis'),
('Martha', 'Kent', '457-88-9993', 'Smallville'),
('May', 'Parker', '303-55-7654', 'Brooklyn'),
('Peggy', 'Carter', '606-99-3456', 'London'),
('Diana', 'Prince','986-10-1942', 'Themyscira')

--View sensitive data, unecrypted
SELECT * FROM Sales.Customers

--Always Encypted catalog views
SELECT * FROM sys.column_master_keys
SELECT * FROM sys.column_encryption_keys
SELECT * FROM sys.column_encryption_key_values

--Find columns protected by Always Encrypted
SELECT c.name as E_Column, c.column_encryption_key_id,
	   cek.name as E_Key, encryption_type_desc,
	   encryption_algorithm_name
FROM sys.columns as c
JOIN sys.column_encryption_keys as cek
	ON c.column_encryption_key_id = 
	   cek.column_encryption_key_id
WHERE c.column_encryption_key_id IS NOT NULL

--Hey John! 
--This class is AWESOME!
--Hide Your Thumbprint!!!!!!!
--Look for the encryption keys under Database Security

--Encrypt two columns. Can't be done with T-SQL
--(But you can with Powershell.) We will use SSMS.
	--LastName (Randomized)
	--SSN (Deterministic)
--Script Table to New Query Window to see changes.

--To read data decrypted
--Change database connection to use
-- "column encryption setting = enabled"
--View sensitive data, unecrypted
SELECT * FROM Sales.Customers
GO
--Search on Randomized Column (Should get error.)
DECLARE @Name varchar(20) = 'Lane'

SELECT * FROM Sales.Customers
WHERE LastName = @Name
GO
--Search on Deterministic Column (Should be allowed, Maybe...)
DECLARE @SSN varchar(20) = '555-47-8909'

SELECT * FROM Sales.Customers
WHERE SSN = @SSN
GO

--Hey, go look for the keys again using the DMV's.
--Look under Database Security for the Always Encrypted Keys.







