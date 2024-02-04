USE [AdventureWorksPTO]
GO
--------------------------------------Index Maintenance -------------------------------------------------------------------
 ---- Pick the  Indexstatement from last Select statement and execute it
Use AdventureWorksPTO;
ALTER INDEX AK_NewPerson_rowguid ON dbo.Newperson REBUILD;
Use AdventureWorksPTO;
ALTER INDEX IX_NewPerson_LastName_FirstName_MiddleName ON dbo.Newperson REBUILD;
Use AdventureWorksPTO;
ALTER INDEX IX_NewPerson_PersonType ON dbo.Newperson REORGANIZE;