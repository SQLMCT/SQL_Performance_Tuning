Echo off
if exist "E:\LabFiles\M04L02Lab01\deadlock.txt" ( del E:\LabFiles\M04L02Lab01\deadlock.txt) 

IF "%SQLSERVER%"=="" (
  SET SQLSERVER=SQLPTO
)


 
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L02Lab01\Update1.sql" -o"E:\LabFiles\M04L02Lab01\DeadLock.txt"
REM pause
start sqlcmd -S%SQLSERVER% -dAdventureWorksPTO -i"E:\LabFiles\M04L02Lab01\update2.sql" -o"E:\LabFiles\M04L02Lab01\DeadLock.txt"
pause
type DeadLock.txt
