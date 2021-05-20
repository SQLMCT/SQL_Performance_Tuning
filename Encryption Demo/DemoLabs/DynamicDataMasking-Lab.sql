--Dynamic Data Masking - Lab

--Create a table with three different types of dynamic data masks and populate few records

USE AdventureWorks
go

CREATE TABLE Membership
  (MemberID int IDENTITY PRIMARY KEY,
   FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)') NULL,
   LastName varchar(100) NOT NULL,
   Phone# varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
   Email varchar(100) MASKED WITH (FUNCTION = 'email()') NULL);
go

INSERT Membership (FirstName, LastName, Phone#, Email) VALUES 
('Andre', 'Wayne', '123.456.7890', 'awayne@contoso.com'),
('Nathan', 'Star', '500.500.5000', 'nstar@contoso.biz'),
('Ryan', 'Bolt', '321.123.9999', 'rbolt@contoso.net');
go

SELECT * FROM Membership;
go

--A masking rule may be defined on a column in a table, to help protect the data in that column. Four types of masks are available. Default, Email, Custom String, Random.

--Create a new User and Grant SELECT permission on the table.

CREATE USER TestUser WITHOUT LOGIN;
go

GRANT SELECT ON Membership TO TestUser;
go

--Execute as the new User and the output shows data in masked format

EXECUTE AS USER = 'TestUser';
go

SELECT * FROM Membership;
go

REVERT;
go

--Use the ALTER TABLE statement to add masks to an existing column in the table, or to edit the mask on that column.

ALTER TABLE Membership
ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)');
go

ALTER TABLE Membership
ALTER COLUMN LastName varchar(100) MASKED WITH (FUNCTION = 'default()');
go

--Granting the UNMASK permission allows TestUser to see the data unmasked.

GRANT UNMASK TO TestUser;
go

EXECUTE AS USER = 'TestUser';
go

SELECT * FROM Membership;
go

REVERT; 
go

-- Removing the UNMASK permission

REVOKE UNMASK TO TestUser;
go

--Use the sys.masked_columns view to query for table-columns that have a masking function applied to them. This view inherits from the sys.columns view. It returns all columns in the sys.columns view, plus the is_masked and masking_function columns, indicating if the column is masked, and if so, what masking function is defined. 

SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function
FROM sys.masked_columns AS c
JOIN sys.tables AS tbl ON c.[object_id] = tbl.[object_id]
WHERE is_masked = 1;
go

--The following statement drops the mask on the LastName column created in the previous example:

ALTER TABLE Membership 
ALTER COLUMN LastName DROP MASKED;
go

--Cleanup
DROP Table Membership  
DROP User Testuser
go
