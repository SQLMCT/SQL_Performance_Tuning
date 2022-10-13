--Diane Deadlock Session 2

BEGIN TRAN
UPDATE SalesLT.Customer
SET LastName = 'Deardurff'
WHERE CustomerID = 5

--Switch back to Jack

UPDATE SalesLT.Address
SET City = 'Indianapolis'
WHERE AddressID = 9
COMMIT TRAN


