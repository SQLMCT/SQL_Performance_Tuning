--Jack Deadlock Session 1

BEGIN TRAN
UPDATE SalesLT.Address
SET City = 'Indianapolis'
WHERE AddressID = 9

--Switch back to DIANE

UPDATE SalesLT.Customer
SET LastName = 'Deardurff'
WHERE CustomerID = 5
COMMIT TRAN