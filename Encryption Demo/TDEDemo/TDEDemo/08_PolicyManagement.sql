--Policy Management Demo
--Find Databases that are not owned by sa

SELECT *
FROM sys.databases
WHERE suser_sname(owner_sid) <> 'sa'

--Hey, John! Go make a Policy Management thing.
--Policy Name: Verify Database Owner
--New Condition: Check Database Owner
--Facet: Database
--Expression: @Owners = 'sa'
--Assign Targets: @Name NotLike system databases

--Change ownership and check policy.
--ALTER AUTHORIZATION ON DATABASE:: AdventureWorks2016 TO SA;

--Schedule policy and check jobs.