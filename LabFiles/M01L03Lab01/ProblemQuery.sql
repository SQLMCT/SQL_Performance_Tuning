SET NOCOUNT ON
GO
DECLARE @x int
SET @x = 1
WHILE (@x <= 100000)
BEGIN
  EXEC usp_DoSomeWork
  SET @x = @x + 1
END
GO
