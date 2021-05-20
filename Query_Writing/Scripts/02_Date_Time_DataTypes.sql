--Data and Time Data Type Examples
DECLARE @DateOnly DATETIME = '20140214'
DECLARE @TimeOnly DATETIME = '15:30:45'

SELECT @DateOnly as DateOnly, @TimeOnly as TimeOnly

GO
--Working with Time Precision
DECLARE @Time1 DATETIME = '15:30:45'
DECLARE @Time2 DATETIME2 = '15:30:45'
DECLARE @Time3 TIME = '15:30:45'
DECLARE @Time4 TIME(0) = '15:30:45'
DECLARE @Time5 TIME(7) = '15:30:45'

SELECT @Time1 as DT_Example,
	   @Time2 as DT2_Example,
	   @Time3 as TimeOnly,
	   @Time4 as TimeZero,
	   @Time5 as TimeSeven
GO