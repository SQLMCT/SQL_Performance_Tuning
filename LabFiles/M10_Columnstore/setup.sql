/* 
This Sample Code is provided for the purpose of illustration only and is not 
	intended to be used in a production environment. THIS SAMPLE CODE AND ANY
	RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
	EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
	WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
We grant You a nonexclusive, royalty-free right to use and modify the Sample 
	Code and to reproduce and distribute the object code form of the Sample 
	Code, provided that You agree: 
	(i) to not use Our name, logo, or trademarks to market Your software 
		product in which the Sample Code is embedded; 
	(ii) to include a valid copyright notice on Your software product in 
		which the Sample Code is embedded; and 
	(iii) to indemnify, hold harmless, and defend Us and Our suppliers from 
		and against any claims or lawsuits, including attorneys fees, that 
		arise or result from the use or distribution of the Sample Code.
*/

USE master;
go

DROP DATABASE IF EXISTS ncci;
go

CREATE DATABASE [ncci] CONTAINMENT = NONE ON PRIMARY ( NAME = N'ncci_data', FILENAME = N'F:\SQLdata\ncci_Data.mdf', SIZE = 102400KB, MAXSIZE = 5GB, FILEGROWTH = 1024000KB ) LOG ON ( NAME = N'ncci_log', FILENAME = N'G:\SQLLog\ncci_Log.ldf ', SIZE = 52400KB, MAXSIZE = 5GB, FILEGROWTH = 102400KB )
GO

USE ncci;
go
DROP TABLE IF EXISTS orders;
go
-- create the table
CREATE TABLE orders
  (
     AccountKey      INT NOT NULL,
     customername    NVARCHAR (50),
     OrderNumber     BIGINT,
     PurchasePrice   DECIMAL (9, 2),
     OrderStatus     SMALLINT NOT NULL,
     OrderStatusDesc NVARCHAR (50)
  )

-- OrderStatusDesc
-- 0 => 'Order Started'
-- 1 => 'Order Closed'
-- 2 => 'Order Paid'
-- 3 => 'Order Fullfillment Wait'
-- 4 => 'Order Shipped'
-- 5 => 'Order Received'

CREATE CLUSTERED INDEX orders_ci
  ON orders(OrderStatus)

SET nocount ON;
go

SET statistics time OFF;
go
SET statistics IO OFF;
go

-- insert into the main table load 3 million rows
-- took 55 seconds (IO bound)
DECLARE @outerloop INT = 0;
DECLARE @i INT = 0;
DECLARE @purchaseprice DECIMAL (9, 2)
DECLARE @customername NVARCHAR (50)
DECLARE @accountkey INT;
DECLARE @orderstatus SMALLINT;
DECLARE @orderstatusdesc NVARCHAR(50)
DECLARE @ordernumber BIGINT;
WHILE ( @outerloop < 3000000 )
  BEGIN
      SELECT @i = 0;
      BEGIN TRAN;
      WHILE ( @i < 2000 )
        BEGIN
            SET @ordernumber = @outerloop + @i;
            SET @purchaseprice = RAND() * 1000.0;
            SET @accountkey = CONVERT (INT, RAND () * 1000)
            SET @orderstatus = 5;
            SET @orderstatusdesc = CASE @orderstatus
                                     WHEN 0 THEN 'Order Started'
                                     WHEN 1 THEN 'Order Closed'
                                     WHEN 2 THEN 'Order Paid'
                                     WHEN 3 THEN 'Order Fullfillment'
                                     WHEN 4 THEN 'Order Shipped'
                                     WHEN 5 THEN 'Order Received'
                                   END;

            INSERT orders
            VALUES (@accountkey,
                    ( CONVERT(VARCHAR(6), @accountkey)
                      + 'firstname' ),
                    @ordernumber,
                    @purchaseprice,
                    @orderstatus,
                    @orderstatusdesc)
            SET @i += 1;
        END;
      COMMIT;

      SET @outerloop = @outerloop + 2000;
      SET @i = 0;
  END;
go

CHECKPOINT;
go

SELECT COUNT(*), OrderStatusDesc FROM orders GROUP BY OrderStatusDesc

--create NCCI (note, not including PK column)
-- took 14 secs
CREATE NONCLUSTERED COLUMNSTORE INDEX orders_ncci ON orders  (accountkey, customername, purchaseprice, orderstatus)

-- look at the rowgroups
SELECT OBJECT_NAME(object_id)
       ,index_id
       ,row_group_id
       ,delta_store_hobt_id
       ,state_desc
       ,total_rows
       ,trim_reason_desc
       ,transition_to_compressed_state_desc
FROM
  sys.dm_db_column_store_row_group_physical_stats
WHERE  object_id = OBJECT_ID('orders')


-- set stats off
SET statistics time OFF;
go
SET statistics IO OFF;
go

--insert additional 200k rows
DECLARE @outerloop INT = 3000000;
DECLARE @i INT = 0;
DECLARE @purchaseprice DECIMAL (9, 2)
DECLARE @customername NVARCHAR (50)
DECLARE @accountkey INT;
DECLARE @orderstatus SMALLINT;
DECLARE @orderstatusdesc NVARCHAR(50)
DECLARE @ordernumber BIGINT;
WHILE ( @outerloop < 3200000 )
  BEGIN
      SELECT @i = 0;
      BEGIN TRAN;
      WHILE ( @i < 2000 )
        BEGIN
            SET @ordernumber = @outerloop + @i;
            SET @purchaseprice = RAND() * 1000.0;
            SET @accountkey = CONVERT (INT, RAND () * 1000)
            SET @orderstatus = CONVERT (SMALLINT, RAND() * 5)
            IF ( @orderstatus = 5 )
              SET @orderstatus = 4;;;
            SET @orderstatusdesc = CASE @orderstatus
                                     WHEN 0 THEN 'Order Started'
                                     WHEN 1 THEN 'Order Closed'
                                     WHEN 2 THEN 'Order Paid'
                                     WHEN 3 THEN 'Order Fullfillment'
                                     WHEN 4 THEN 'Order Shipped'
                                     WHEN 5 THEN 'Order Received'
                                   END;

            INSERT orders
            VALUES (@accountkey,
                    ( CONVERT(VARCHAR(6), @accountkey)
                      + 'firstname' ),
                    @ordernumber,
                    @purchaseprice,
                    @orderstatus,
                    @orderstatusdesc)
            SET @i += 1;
        END;
      COMMIT;

      SET @outerloop = @outerloop + 2000;
      SET @i = 0;
  END;
go 

checkpoint
go