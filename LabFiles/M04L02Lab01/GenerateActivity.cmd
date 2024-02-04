@echo off
IF "%SQLSERVER%"=="" (
  SET SQLSERVER=SQLPTO
)

 
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L05Lab01\LoopingQueries.sql"
REM pause
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L05Lab01\BlockedQuery.sql"
REM pause
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L05Lab01\LoopingQueries.sql"
REM pause
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L05Lab01\BlockingTransaction.sql"
REM pause
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L05Lab01\LoopingQueries.sql"


