USE [AdventureWorksPTO]
GO
SET NOCOUNT ON
----------------------------Create a table names NewPerson and its related  indexes --------------------------------------
If Exists( Select 1 from sys.tables where name ='NewPerson')
DROP TABLE dbo.newperson 
Go
SELECT * INTO Dbo.Newperson FROM Person.Person
----Create Clustered Index-----
/******Create  Index [PK_newPerson_BusinessEntityID]    ******/
ALTER TABLE [dbo].[NewPerson] ADD  CONSTRAINT [PK_newPerson_BusinessEntityID] PRIMARY KEY CLUSTERED 
(
	[BusinessEntityID] ASC
)
GO
---Create 4 Non Clustered Indexes----
/****** 1 Create  Index Index [AK_Person_rowguid] ******/
IF EXISTS ( Select 1 from Sys.indexes where name ='AK_NewPerson_rowguid' ) 
DROP INDEX [AK_newPerson_rowguid] ON [dbo].[NewPerson]
GO
/****** Create  Index Index [AK_Person_rowguid]    Script Date: 2/29/2020 11:21:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_NewPerson_rowguid] ON [dbo].[NewPerson]
(
	[rowguid] ASC
)
GO
/****** 2 Create  Index  Index [IX_Person_LastName_FirstName_MiddleName]   ******/
IF EXISTS ( Select 1 from Sys.indexes where name ='IX_NewPerson_LastName_FirstName_MiddleName' ) 
DROP INDEX [IX_NewPerson_LastName_FirstName_MiddleName] ON [dbo].[NewPerson]
GO
SET ANSI_PADDING ON
GO
/******3  Create  Index  Index [IX_Person_LastName_FirstName_MiddleName] ******/
CREATE NONCLUSTERED INDEX [IX_NewPerson_LastName_FirstName_MiddleName] ON [dbo].[NewPerson]
(
	[LastName] ASC,
	[FirstName] ASC,
	[MiddleName] ASC
)
GO
/****** 4 Create  Index  Index [IX_NewPerson_PersonType]  ******/
IF EXISTS ( Select 1 from Sys.indexes where name ='IX_NewPerson_PersonType' ) 
DROP INDEX [IX_NewPerson_PersonType] ON [dbo].[NewPerson]
GO
CREATE NONCLUSTERED INDEX [IX_NewPerson_PersonType] ON [dbo].[NewPerson]
(
	[PersonType] ASC
)
GO