-- Module 8 - Demo 3

-- Step 1: Connect Object Explorer to the MIA-SQL instance.
-- In Object Explorer, expand the node for the TSQL database to show that it has no Query Store node

-- Step 2: Enable and confgigure the Query Store
-- Select and execute the following query to enable the Query Store feature
ALTER DATABASE [TSQL] SET QUERY_STORE = ON;

--make sure the Query Store has no data 
ALTER DATABASE [TSQL] SET QUERY_STORE CLEAR;

--make the interval length and data flush interval as small as possible
ALTER DATABASE [TSQL] SET QUERY_STORE (INTERVAL_LENGTH_MINUTES = 1, DATA_FLUSH_INTERVAL_SECONDS = 60)


-- Step 3: Start a workload
-- In Windows Explorer, right-click D:\Demofiles\Mod08\start_load_1.ps1 and click Run with PowerShell

-- Step 4: In Object Explorer, right click on the TSQL database and open the Properties window.
-- On the Query Store page, show that the Operation Mode option is now set to ON.
-- Close the window


-- Step 5: In Object Explorer, refresh the list of objects under the TSQL database to display the new Query Store node
-- Expand the node to show the queries being tracked 

-- Step 6: Select and execute the following query to increase the size of the Query Store storage
ALTER DATABASE [TSQL]
SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 150);

-- Step 7: From Object Explorer, double-click the Overall Resource Consumption Query Store report
-- In the report, click Configure (top right). Change Time Interval to Last Hour, then click OK.
-- You should see some bars at the right-hand side of each graph caused by the workload

-- Step 8: From Object Explorer, double-click the Top Resource Consuming Queries Query Store report
-- Change the Metric (top left) to Execution Count
-- The largest bar in the list should be for the workload query with text starting "SELECT	so.custid, so.orderdate, so.orderid, so.shipaddress..."
-- If it isn't the largest bar, locate the bar for this query. 
-- Note the query id (x-axis of the chart)

-- Step 9: From Object Explorer, double-click the Tracked Queries Query Store report
-- In the tracking query search box, type the query id you identified in step 8 and then type Enter.
-- This shows the query plan history for the query

-- Step 10: Create a temp table and double the number of rows in the Sales.Orders table (this should prompt a statistics update and a new query plan)
CREATE TABLE ##wideplan (id int)
INSERT TSQL.Sales.Orders (custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry)
SELECT custid,empid,orderdate,requireddate,shippeddate,shipperid,freight,shipname,shipaddress,shipcity,shipregion,shippostalcode,shipcountry
FROM TSQL.Sales.Orders

-- Step 11: After a minute has passed, refresh the Tracked Queries reports (F5)
-- You should see that a new query plan has been compiled. If you don't see a new plan, rerun the insert statement from Step 10 and check again.

-- Step 12: From Object Explorer, double-click the Regressed Queries Query Store report
-- In the report, click Configure (top right). Change Time Interval - Recent to Last 5 minutes, then click OK.
-- The SELECT statement with text starting "SELECT	so.custid, so.orderdate, so.orderid, so.shipaddress..." should appear in the report

-- Step 13: Return to the Tracked Queries report
-- Pick one of the query plans (the dots shown on the graph), then click Force Plan.
-- In the Confirmation window, click Yes

-- Step 14: Return to the Top Resource Consumers report and refresh it (F5)
-- Notice that executions using the forced plan have a tick in the scatter graph

-- Step 15: Return to the Tracked Queries report
-- Click the ticked dot (representing the forced plan)
-- Click Unforce Plan.
-- In the Confirmation window, click Yes

-- Step 16: Stop the workload 
CREATE TABLE ##stopload (id int)

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