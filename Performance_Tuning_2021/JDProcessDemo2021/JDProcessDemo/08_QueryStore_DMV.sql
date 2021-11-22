USE AdventureWorks2016
GO

--Find query plan for specific query
SELECT q.query_id,
       q.query_hash,
	   t.query_sql_text,
       CAST(p.query_plan AS XML) AS QueryPlan
FROM sys.query_store_query AS q
    JOIN sys.query_store_plan AS p
        ON p.query_id = q.query_id
    JOIN sys.query_store_query_text AS t
        ON t.query_text_id = q.query_text_id
WHERE t.query_sql_text LIKE 
  '%SELECT   ProductID, OrderQty, UnitPrice
    FROM     Sales.SalesOrderDetail
    WHERE    ProductID = @ProductID';
GO


--Find the TOP 10 most frequently executed queries
SELECT TOP 10 t.query_sql_text, q.query_id
FROM sys.query_store_query_text as t
	JOIN sys.query_store_query as q
		ON t.query_text_id = q.query_text_id
	JOIN sys.query_store_plan as p
		ON q.query_id = p.query_id
	JOIN sys.query_store_runtime_stats as rs
		ON p.plan_id = rs.plan_id
WHERE rs.count_executions >1
GROUP BY t.query_sql_text, q.query_id
ORDER BY SUM(rs.count_executions)







