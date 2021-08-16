--Add Records for Data Structure Demo
USE TestDB
GO
SET IDENTITY_INSERT Accounting.BankAccounts ON
BEGIN TRAN
	INSERT INTO Accounting.BankAccounts
	(AcctID, AcctName, Balance, ModifiedDate)
	VALUES (29,'Kelli', 1250, GETDATE()),
		   (27,'Jessica', 1005, GETDATE()),
		   (18,'Maddison', 745, GETDATE()),
		   (22,'Bella', 445, GETDATE()),
		   (21,'Alicen', 555, GETDATE()),
		   (15,'Molly', 790, GETDATE()),
		   (24,'Amy', 650, GETDATE()),
		   (23,'Logan', 1050, GETDATE()),
		   (33,'Tommy', 450, GETDATE()),
		   (36,'David', 850, GETDATE()),
		   (37,'Reagan', 630, GETDATE()),
		   (12,'Danny', 630, GETDATE()),
		   (14,'Mayleigh',204, GETDATE()),
		   (25,'Amiyah', 180, GETDATE()),
		   (30,'Baby M', 320, GETDATE())
COMMIT TRAN
SET IDENTITY_INSERT Accounting.BankAccounts OFF
SELECT * FROM Accounting.BankAccounts


/*
DECLARE @AcctID AS tinyint = 1

WHILE @AcctID < 10
	BEGIN
		INSERT INTO Accounting.BankAccounts
			(AcctName, Balance, ModifiedDate)
		SELECT lastname, 100 * @AcctID, GETDATE()
			FROM HR.Employees
			WHERE empid = @AcctID
		SET @AcctID += 1
	END
*/


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