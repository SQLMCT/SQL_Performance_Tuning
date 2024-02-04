USE WideWorldImporters
GO

ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON
GO

UPDATE STATISTICS Sales.InvoiceLinesExtended
WITH ROWCOUNT = 1
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SELECT si.InvoiceID, sil.StockItemID
FROM Sales.InvoiceLinesExtended sil
JOIN Sales.Invoices si
ON si.InvoiceID = sil.InvoiceID
AND sil.StockItemID >= 225
GO

SELECT st.text, cp.plan_handle, qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE qp.dbid = db_id('WideWorldImporters')
GO

SELECT st.text, cp.plan_handle, qps.query_plan, qps.*
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan_stats(cp.plan_handle) AS qps
WHERE qps.dbid = db_id('WideWorldImporters')
GO

UPDATE STATISTICS Sales.InvoiceLinesExtended
WITH ROWCOUNT = 3652240
GO

DBCC DROPCLEANBUFFERS
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO

SELECT si.InvoiceID, sil.StockItemID
FROM Sales.InvoiceLinesExtended sil
JOIN Sales.Invoices si
ON si.InvoiceID = sil.InvoiceID
AND sil.StockItemID >= 225
GO

SELECT st.text, cp.plan_handle, qps.query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan_stats(cp.plan_handle) AS qps
WHERE qps.dbid = db_id('WideWorldImporters')
GO