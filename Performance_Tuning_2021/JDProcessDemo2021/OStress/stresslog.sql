-- The following update generates about 5MB of log content
-- Run in OSTRESS

UPDATE dbo.Numbers 
SET IntCounter = REPLICATE('a', 2000) 
WHERE [Number] >= @@spid * 1000
AND [Number] <= @@spid * 1000 + 900