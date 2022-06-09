/* Function created by David M. Maxwell and Louis T. Garrett */
CREATE OR ALTER FUNCTION dbo.ConvertLSN
(@lsn nvarchar(22) = '00000035:000000e8:0006',
@IncludeColons bit = 1)
RETURNS nvarchar(22) 
AS
BEGIN
RETURN (SELECT
  RIGHT(REPLICATE('0', 8) + CAST(CONVERT(INT, CONVERT(VARBINARY, left(@lsn,8),2) )
	AS NVARCHAR(8)),8)
+ CASE WHEN @IncludeColons = 1 THEN ':' ELSE '' END
+ RIGHT(REPLICATE('0', 8) + CAST(CONVERT(INT, CONVERT(VARBINARY, substring(@lsn,10,8),2) )
	AS NVARCHAR(8)),8)
+ CASE WHEN @IncludeColons = 1 THEN ':' ELSE '' END
+ RIGHT(REPLICATE('0', 4) + CAST(CONVERT(INT, CONVERT(VARBINARY, right(@lsn,4),2) )
	AS NVARCHAR(4)),4)
)
END
GO

--Get the Max LSN from the Transaction Log
--LSN: 00003162:00000560:0001
SELECT dbo.ConvertLSN (MAX([Current LSN]),1) as maxlsn
FROM fn_dblog(null, null)


SELECT COUNT(*) AS OperationCount, Operation, Context
FROM sys.fn_dblog('00000044:00002743:0018', null)
GROUP by Operation, Context
ORDER BY OperationCount DESC
GO

--Under Construction
--SELECT [Oldest Active Transaction ID]
--FROM fn_dblog('00003150:00001976:0101', NULL)
--GROUP BY [Oldest Active Transaction ID]




