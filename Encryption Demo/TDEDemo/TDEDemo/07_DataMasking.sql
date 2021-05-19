--Use database from the Row-Level Security Demo
USE RLS_DEMO
GO

--Create a new table with data masks
CREATE TABLE EmployeePersonalData
(EmpID int NOT NULL PRIMARY KEY,
 Salary int  MASKED WITH (FUNCTION = 'default()') NOT NULL,
 EmailAddress varchar(255)  MASKED WITH (FUNCTION = 'email()')  NULL,
 VoiceMailPin smallint MASKED WITH (FUNCTION = 'random(0, 9)') NULL,
 CompanyCard varchar(30) MASKED WITH (FUNCTION = 'partial(0,"XXXX",4)') NULL,
 HomePhone varchar(30) NULL
);
GO

--Create test user and grant permission 
CREATE USER test_user WITHOUT LOGIN
GO
GRANT SELECT ON EmployeePersonalData TO test_user;
GO

--Insert test data 
INSERT EmployeePersonalData
(EmpID, Salary, EmailAddress, VoiceMailPin, CompanyCard, HomePhone)
VALUES (1,25000,'Jack@adventure-works.net',9991,'9999-5656-4433-2211', '234-5678'),
(2,35000,'Diane@adventure-works.org',1151,'9999-7676-5566-3141', '345-3142'),
(3,35000,'Manager@adventure-works.com',6514,'9999-7676-5567-2444', '456-7772')

--Currently logged in with an admin account
--Adminstrator can see the unmasked data
SELECT * FROM EmployeePersonalData

--User with only SELECT permission sees masked data  
EXECUTE AS USER = 'test_user'
SELECT * FROM EmployeePersonalData
REVERT
GO

--Alter the home_phone_number column to add a mask
ALTER TABLE EmployeePersonalData 
ALTER COLUMN HomePhone
ADD MASKED WITH (FUNCTION = 'partial(3,"-XXX",0)');
GO

--Demonstrate the new mask  
EXECUTE AS USER = 'test_user'
SELECT HomePhone FROM EmployeePersonalData
REVERT
GO

--Remove the mask from the salary column
ALTER TABLE EmployeePersonalData 
ALTER COLUMN Salary
DROP MASKED;
GO

--Show that salary is now unmasked 
EXECUTE AS USER = 'test_user'
SELECT Salary FROM EmployeePersonalData
REVERT
GO

--Grant the UNMASK permission to the test user
GRANT UNMASK TO test_user;

--Show that the UNMASK permission disables masking
EXECUTE AS USER = 'test_user'
SELECT * FROM EmployeePersonalData
REVERT
GO

--Remove test table
DROP TABLE EmployeePersonalData;
GO
