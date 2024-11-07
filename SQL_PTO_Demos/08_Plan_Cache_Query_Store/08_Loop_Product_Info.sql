DECLARE @counter INT = 1, @subcounter INT = 1, @exCounter TINYINT = 1;
WHILE (@counter <= 25000)
BEGIN
	BEGIN
	-- Run the stored procedure with parameters that will return 
	-- a range of rows
		IF @exCounter = 1
			EXECUTE dbo.getProductInfo 870	-- 4688 Rows
			EXECUTE dbo.getProductInfo 897	-- 2 Rows
			EXECUTE dbo.getProductInfo 945	-- 257 Rows
			EXECUTE dbo.getProductInfo 768	-- 441 Rows
		IF @exCounter = 2
			EXECUTE dbo.getProductInfo 897	-- 2 Rows
			EXECUTE dbo.getProductInfo 945	-- 257 Rows
			EXECUTE dbo.getProductInfo 768	-- 441 Rows
			EXECUTE dbo.getProductInfo 870	-- 4688 Rows
		IF @excounter >= 3
			SET @excounter += 1;
		ELSE 
			SET @excounter = 1 
		END
	

	SET @counter += 1;
	
	WAITFOR DELAY '00:00:02';
	    
END