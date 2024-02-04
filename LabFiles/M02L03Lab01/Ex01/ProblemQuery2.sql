DECLARE @Flag INT
SET @Flag = 1
WHILE (@Flag < 100000)

BEGIN

SET @SQL = 'SELECT @F = COUNT(*) FROM sys.objects WHERE object_id = ' + CAST( @Flag AS VARCHAR(10) )
EXEC sp_executesql @SQL, N'@F int OUTPUT', @F OUTPUT

SET @Flag = @Flag + 1
END 
GO