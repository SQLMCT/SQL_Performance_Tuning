/*
For this demonstration first run 02_Create_Database.sql 

Then walk through Auto-Commit Transactions and Batch errors with script 02_Create_Table.sql

Copy the below code to a new query window to demonstrate Explicit Transactions, Statement terminating errors, and error handling.

The completed procedure is on 04_Trans_Finished.sql
*/

		UPDATE Accounting.BankAccounts
		SET Balance -= 2/0
		WHERE AcctID = 1

		UPDATE Accounting.BankAccounts
		SET Balance += 200
		WHERE AcctID = 2




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