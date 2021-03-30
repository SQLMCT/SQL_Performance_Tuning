--Add Records for Data Structure Demo
USE AdventureWorks2016
GO
SET IDENTITY_INSERT Accounting.BankAccounts ON
BEGIN TRAN
	INSERT INTO Accounting.BankAccounts
	(AcctID, AcctName, Balance, ModifiedDate)
	VALUES (29,'Kelli', 1250, GETDATE()),
		   (27,'Jessica', 1005, GETDATE()),
		   (18,'Maddison', 745, GETDATE()),
		   (31,'Alicen', 555, GETDATE()),
		   (15,'Molly', 790, GETDATE()),
		   (34,'Amy', 650, GETDATE()),
		   (32,'Logan', 1050, GETDATE()),
		   (33,'Tommy', 450, GETDATE()),
		   (36,'David', 850, GETDATE()),
		   (22,'Reagan', 630, GETDATE()),
		   (14,'Mayleigh', 204, GETDATE())	   
COMMIT TRAN
SET IDENTITY_INSERT Accounting.BankAccounts OFF
SELECT * FROM Accounting.BankAccounts

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