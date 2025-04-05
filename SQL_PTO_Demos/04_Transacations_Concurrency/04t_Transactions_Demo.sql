USE master;

--Build Database for demonstration.
DROP DATABASE IF EXISTS WoodgroveBank;
CREATE DATABASE WoodgroveBank ON
(NAME = WoodgroveBank,
 FILENAME = 'D:\DATA\WoodgroveBank.mdf',
	SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON
(NAME = Test_DB_Log,
 FILENAME = 'D:\DATA\WoodgroveBank.ldf',
	SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB);
GO

--Create Table for demonstration.
USE WoodgroveBank
GO
CREATE SCHEMA Accounting Authorization dbo
CREATE TABLE BankAccounts
 (AcctID int IDENTITY,
  FirstName char(15),
  LastName char(20),
  Balance money,
  ModifiedDate date)
GO

/*********************************************************************
** Walk through Auto-Commit Transactions and Batch errors.
** Notice that VALUSE is not spelled correctly, this is a syntax error.
** Syntax errors will terminate the entire batch.
*********************************************************************/

INSERT INTO Accounting.BankAccounts
VALUES('Jack','Jones',500, GETDATE())
INSERT INTO Accounting.BankAccounts
VALUSE('Diane','Smith', 750, GETDATE())
GO

--Test to see if records were inserted, then fix VALUSE and try again.
SELECT * FROM Accounting.BankAccounts

/*************************************************************
** The below code is used to demonstrate Explicit Transactions,
** Statement terminating errors and error handling. 
**************************************************************/

-- Start with two auto-commit updates without errors.

	UPDATE Accounting.BankAccounts
	SET Balance -= 200
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 200
	WHERE AcctID = 2

-- Test to see if records were updated. (The $200 should transfer.)
	
SELECT * FROM Accounting.BankAccounts

-- Next we have two auto-commit updates WITH a divide by zero error.

	UPDATE Accounting.BankAccounts
	SET Balance -= 2/0
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 200
	WHERE AcctID = 2

-- Test to see if records were updated.
-- The first statement terminates, but the second statement completes.
SELECT * FROM Accounting.BankAccounts

-- Try again with SET XACT_ABORT.
SET XACT_ABORT ON
	UPDATE Accounting.BankAccounts
	SET Balance -= 2/0
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 200
	WHERE AcctID = 2

-- Test to see if records were updated.
-- XACT ABORT will turn statement terminating errors into batch terminating.
-- But only once it hits an error.

SELECT * FROM Accounting.BankAccounts

-- Try the SET XACT_ABORT with the error in the second statement
SET XACT_ABORT ON
	UPDATE Accounting.BankAccounts
	SET Balance -= 200
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 2/0
	WHERE AcctID = 2

-- Test to see if records were updated.
-- The first statement still updated the record, and the second statement had an error.

SELECT * FROM Accounting.BankAccounts

-- To get better error handling and transaction control use Explicit Transactions.

SET XACT_ABORT ON
BEGIN TRANSACTION
	UPDATE Accounting.BankAccounts
	SET Balance -= 200
	WHERE AcctID = 1

	UPDATE Accounting.BankAccounts
	SET Balance += 2/0
	WHERE AcctID = 2
COMMIT TRANSACTION

-- Test to see if records were updated.
-- The Explicit transaction enforces that the entire transaction executes or does not execute.

SELECT * FROM Accounting.BankAccounts

-- However, XACT_ABORT does not give enough control of errors.
-- Let's turn it off and add explicit error handling.
SET XACT_ABORT OFF

-- Now let's add BEGIN/COMMIT TRY and BEGIN/COMMIT CATCH blocks.
-- We will also add explicit error handling to rollback transaction
-- if there is an error.
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE Accounting.BankAccounts
		SET Balance -= 200
		WHERE AcctID = 1

		UPDATE Accounting.BankAccounts
		SET Balance += 2/0
		WHERE AcctID = 2
	COMMIT TRANSACTION
	PRINT 'Transaction Successful'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Divide by Zero Error. Error Number: ' + CAST(ERROR_Number() as char(4))
END CATCH
GO

-- Test to see if records were updated.
SELECT * FROM Accounting.BankAccounts;
GO

-- To make our code reusable, we will create a stored procedure.
-- Also notice SET NOCOUNT ON that will turn off counting rows affected.
-- We will also fix the divide by zero error.

CREATE OR ALTER PROCEDURE dbo.BankTransfer
AS
BEGIN TRY
SET NOCOUNT ON
	BEGIN TRANSACTION
		UPDATE Accounting.BankAccounts
		SET Balance -= 200
		WHERE AcctID = 1

		UPDATE Accounting.BankAccounts
		SET Balance += 200
		WHERE AcctID = 2
	COMMIT TRANSACTION
	PRINT 'Transaction Successful'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Divide by Zero Error. Error Number:' + CAST(ERROR_Number() as char(4))
END CATCH
GO

-- Test the Stored Procedure
EXECUTE dbo.BankTransfer 
GO;

-- Test to see if records were updated.
SELECT * FROM Accounting.BankAccounts;
GO

-- To make the Stored Procedure more flexible and performant,
-- We will add input parameters.

CREATE OR ALTER PROCEDURE dbo.BankTransfer
(@Amount money, @SubAccount int, @AddAccount int)
AS
BEGIN TRY
SET NOCOUNT ON
	BEGIN TRANSACTION
		UPDATE Accounting.BankAccounts
		SET Balance -= @Amount
		WHERE AcctID = @SubAccount

		UPDATE Accounting.BankAccounts
		SET Balance += @Amount
		WHERE AcctID = @AddAccount
	COMMIT TRANSACTION
	PRINT 'Transaction Successful'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Divide by Zero Error. Error Number:' + CAST(ERROR_Number() as char(4))
END CATCH
GO

-- Test the Stored Procedure
EXECUTE dbo.BankTransfer 743.23, 2, 1

-- Test to see if records were updated.
SELECT * FROM Accounting.BankAccounts;


--Clean up demonstration.
DROP DATABASE IF EXISTS WoodgroveBank;


/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/