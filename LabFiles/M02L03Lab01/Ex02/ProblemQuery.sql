USE AdventureWorksPTO
GO
 
DROP TABLE IF EXISTS dbo.BigTable;
GO
 
;WITH
    l0 AS (select 0 AS c union all select 0),
    l1 AS (select 0 AS c from l0 as a cross join l0 as b),
    l2 AS (select 0 AS c from l1 as a cross join l1 as b),
    l3 AS (select 0 AS c from l2 as a cross join l2 as b),
    l4 AS (select 0 AS c from l3 as a cross join l3 as b),
    l5 AS (select 0 AS c from l4 as a cross join l4 as b),
    nums as (select row_number() over(order by (select null)) as n from l5)
SELECT TOP (100000000) *, NEWID() AS ID, GETDATE() AS Today, n % 100000 AS SampleColumn
INTO BigTable
FROM nums 
ORDER BY n
GO 

DROP TABLE IF EXISTS dbo.BigTable;
GO
 
;WITH
    l0 AS (select 0 AS c union all select 0),
    l1 AS (select 0 AS c from l0 as a cross join l0 as b),
    l2 AS (select 0 AS c from l1 as a cross join l1 as b),
    l3 AS (select 0 AS c from l2 as a cross join l2 as b),
    l4 AS (select 0 AS c from l3 as a cross join l3 as b),
    l5 AS (select 0 AS c from l4 as a cross join l4 as b),
    nums as (select row_number() over(order by (select null)) as n from l5)
SELECT TOP (100000000) *, NEWID() AS ID, GETDATE() AS Today, n % 100000 AS SampleColumn
INTO BigTable
FROM nums 
ORDER BY n
GO 

DROP TABLE IF EXISTS dbo.BigTable;
GO
 
;WITH
    l0 AS (select 0 AS c union all select 0),
    l1 AS (select 0 AS c from l0 as a cross join l0 as b),
    l2 AS (select 0 AS c from l1 as a cross join l1 as b),
    l3 AS (select 0 AS c from l2 as a cross join l2 as b),
    l4 AS (select 0 AS c from l3 as a cross join l3 as b),
    l5 AS (select 0 AS c from l4 as a cross join l4 as b),
    nums as (select row_number() over(order by (select null)) as n from l5)
SELECT TOP (100000000) *, NEWID() AS ID, GETDATE() AS Today, n % 100000 AS SampleColumn
INTO BigTable
FROM nums 
ORDER BY n
GO 

DROP TABLE IF EXISTS dbo.BigTable;
GO
 
;WITH
    l0 AS (select 0 AS c union all select 0),
    l1 AS (select 0 AS c from l0 as a cross join l0 as b),
    l2 AS (select 0 AS c from l1 as a cross join l1 as b),
    l3 AS (select 0 AS c from l2 as a cross join l2 as b),
    l4 AS (select 0 AS c from l3 as a cross join l3 as b),
    l5 AS (select 0 AS c from l4 as a cross join l4 as b),
    nums as (select row_number() over(order by (select null)) as n from l5)
SELECT TOP (100000000) *, NEWID() AS ID, GETDATE() AS Today, n % 100000 AS SampleColumn
INTO BigTable
FROM nums 
ORDER BY n
GO 