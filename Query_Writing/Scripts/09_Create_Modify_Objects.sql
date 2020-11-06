--Demonstration on Creating and Modifying SQL Objects
USE AdventureWorks2016
GO

--Create Scalar Function 
--Scalar function retun a single value
CREATE FUNCTION sf_FirstOfMonth
(@StartDate DATE) --Input Parameter
RETURNS Date --The Data Type the function returns
AS
BEGIN --Starts Code Block
	RETURN
		CAST(
			CAST(MONTH(@StartDate) as char(2))
			+ '/1/' +
			CAST(YEAR(@StartDate) as char(4))
		AS DATE)
END --Ends Code Block
GO

--Creating Views Demonstration
CREATE VIEW jd_vwPhoneList
AS
SELECT P.LastName + ', ' + FirstName as Full_Name, 
		PhoneNumber
FROM Person.Person AS P
	JOIN Person.PersonPhone AS PH
		ON P.BusinessEntityID = PH.BusinessEntityID
GO

--Creating Inline Table-Valued Functions Demonstration
--Returns a tabluar base result set
CREATE FUNCTION jd_funPhoneList
(@EmpID as int) --Input Parameter
RETURNS TABLE--The Data Type the function returns
AS
RETURN
	SELECT P.LastName + ', ' + FirstName as Full_Name, 
			PhoneNumber
	FROM Person.Person AS P
		JOIN Person.PersonPhone AS PH
			ON P.BusinessEntityID = PH.BusinessEntityID
	WHERE P.BusinessEntityID = @EmpID
GO

--Derived Table Demonstration
--Does not create a permanent object
SELECT Full_Name, PhoneNumber
FROM
	(SELECT P.LastName + ', ' + FirstName as Full_Name, 
			PhoneNumber
	FROM Person.Person AS P
		JOIN Person.PersonPhone AS PH
			ON P.BusinessEntityID = PH.BusinessEntityID)
	AS Derived_Table --Names the Derived Table
WHERE Full_Name LIKE 'G%'
GO

--Common Table Expression (CTE) Demonstration
--Does not create a permanent object
WITH CTE_PhoneList AS --Names the CTE 

(SELECT P.LastName + ', ' + FirstName as Full_Name, 
			PhoneNumber
FROM Person.Person AS P
	JOIN Person.PersonPhone AS PH
	ON P.BusinessEntityID = PH.BusinessEntityID) 

SELECT Full_Name, PhoneNumber
FROM CTE_PhoneList
WHERE Full_Name LIKE 'G%'
GO