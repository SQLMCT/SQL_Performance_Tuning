/*	Make to run 07_Order_History_Extended for demo setup. 30 minutes */

/*	Step 1: Warm the buffer pool cache to make it a fair comparison */

USE [WideWorldImportersDW]
GO
SELECT COUNT(*) FROM Fact.OrderHistoryExtended
GO

/*	Step 2: Clear the procedure cache and change 
	database compatibility to 130 to show previous behavior */

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 130
GO

/*	Step 3: Run the query
	IMPORTANT:  Enable the option to 
	"Include Actual Execution Plan" (Ctrl+M) */


SELECT [Tax Rate], [Lineage Key], [Salesperson Key], SUM(Quantity) AS SUM_QTY, 
SUM([Unit Price]) AS SUM_BASE_PRICE, COUNT(*) AS COUNT_ORDER
FROM Fact.OrderHistoryExtended
WHERE [Order Date Key]<=DATEADD(dd, -73, '2015-11-13')
GROUP BY [Tax Rate], [Lineage Key], [Salesperson Key]
ORDER BY [Tax Rate], [Lineage Key], [Salesperson Key]
GO

/*	Note the execution time: around 10 seconds
	See the execution plan:
	Notice the Actual Execution Mode for the Table Scan Operator 
	on the OrderHistoryExtended table = Row
	Notice the cost of the query 755.858 */

/*	Step 4: Clear the procedure cache and change
	database compatibility to 150 to enable batch mode */

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
GO
ALTER DATABASE WideWorldImportersDW SET COMPATIBILITY_LEVEL = 150
GO

/* Step 5: Now let's run it again */


SELECT [Tax Rate], [Lineage Key], [Salesperson Key], SUM(Quantity) AS SUM_QTY, 
SUM([Unit Price]) AS SUM_BASE_PRICE, COUNT(*) AS COUNT_ORDER
FROM Fact.OrderHistoryExtended
WHERE [Order Date Key]<=DATEADD(dd, -73, '2015-11-13')
GROUP BY [Tax Rate], [Lineage Key], [Salesperson Key]
ORDER BY [Tax Rate], [Lineage Key], [Salesperson Key]
GO

/*	Note the execution time: around 2 seconds. It is much faster
	See the execution plan:
	Notice the Actual Execution Mode for the Table Scan Operator on the OrderHistoryExtended table = Batch
	Notice the cost of the query 681.05 */


	
/* This Sample Code is provided for the purpose of illustration only and is not intended 
to be used in a production environment.  THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE 
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR 
PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify the Sample Code
and to reproduce and distribute the object code form of the Sample Code, provided that You 
agree: (i) to not use Our name, logo, or trademarks to market Your software product in which
the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product
in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and
Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or 
result from the use or distribution of the Sample Code.
*/
