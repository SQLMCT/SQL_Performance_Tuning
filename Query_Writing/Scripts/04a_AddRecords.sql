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

