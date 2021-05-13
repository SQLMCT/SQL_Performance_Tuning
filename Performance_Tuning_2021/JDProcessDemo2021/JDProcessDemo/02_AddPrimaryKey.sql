USE TestDB
GO
---Adding a Primary Key will also create a clustered index.
ALTER TABLE Accounting.BankAccounts
ADD CONSTRAINT pk_acctID PRIMARY KEY (AcctID)