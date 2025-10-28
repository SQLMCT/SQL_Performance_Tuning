
SELECT p.Title + ' ' + p.FirstName + ' ' + p.LastName AS FullName, 
	c.AccountNumber, s.Name
FROM Person.Person AS p 
INNER JOIN Sales.Customer AS c 
	ON c.PersonID = p.BusinessEntityID 
INNER JOIN Sales.Store AS s 
	ON s.BusinessEntityID = c.StoreID
WHERE p.LastName = 'Koski'


-- Run without changes
-- Cost: 0.277519 
-- Include Title to IX_Person_LastName_FirstName_MiddleName
-- Cost: 0.272314
-- Include PersonID to AK_Customer_AccountNumber
-- Cost: 0.272314 (No Change)
-- Include StoreID to AK_Customer_AccountNumber
-- Cost: 0.239920
-- Create IX_PersonID_StoreID_AccountNumber Index
-- Cost: 0.012084



