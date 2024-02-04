
USE [AdventureWorksPTO]
GO
Set NoCount On
------------------------------------DML Operation on table ----------------------------------------------------------
Declare @NBusinessEntityID int
SELECT	 @NBusinessEntityID = max(BusinessEntityID) FROM dbo.Newperson
--------Insert data into NewPerson-----------------------
INSERT INTO dbo.Newperson
	SELECT 
	BusinessEntityID+@NBusinessEntityID, PersonType,NameStyle,'Mr' Title,
	'FirstName' FirstName,'M' MiddleName,'Lname' LastName,Suffix,
	EmailPromotion,AdditionalContactInfo,Demographics,newid()  rowguid,Getdate() ModifiedDate
FROM Newperson 
	WHERE PersonType in ('IN', 'GC')
----------------Update data in NewPerson-----------------------------
Update dbo.Newperson
			Set MiddleName ='M'
-----------------------Insert few more data rows into NewPerson----------------------
Select @NBusinessEntityID = max(BusinessEntityID) FROM dbo.Newperson
INSERT INTO dbo.Newperson
	SELECT 
BusinessEntityID+@NBusinessEntityID, PersonType,NameStyle,'Ms' Title,
	'FirstName' FirstName,'M' MiddleName,'Lname' LastName, Suffix,
	EmailPromotion,  AdditionalContactInfo,Demographics,newid()  rowguid,Getdate() ModifiedDate
FROM Newperson 
	WHERE PersonType in ('IN', 'GC')
