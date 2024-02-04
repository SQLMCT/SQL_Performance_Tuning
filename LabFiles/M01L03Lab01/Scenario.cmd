@ECHO OFF

SETLOCAL
SET SCENARIONAME=ConcurrencyLatches

IF "%1"=="" (
  SET SQLSERVER=.
  @ECHO Usage: Scenario.cmd SQLServerToConnect
  @ECHO Assuming Default instance of SQL Server
) ELSE (
  SET SQLSERVER=%1
)

REM ========== Setup ========== 
@ECHO %date% %time% - Starting scenario %SCENARIONAME%...
CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\Cleanup.cmd
IF "%ERRORLEVEL%" NEQ "0" GOTO :eof
@ECHO %date% %time% - %SCENARIONAME% setup...
sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksPTO -oE:\LabFiles\M01L03Lab01\output\Setup.out -iE:\LabFiles\M01L03Lab01\Setup.sql 


REM ========== Start ========== 
REM Kick off a simulated workload so that we have a bit more interesting data to work with
@ECHO %date% %time% - Starting background workload...
CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\BackgroundWorkload.cmd %SQLSERVER%

REM Start expensive query
@ECHO %date% %time% - Starting foreground queries...
SET /A NUMTHREADS=%NUMBER_OF_PROCESSORS%+20
CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\StartN.cmd /N %NUMTHREADS% /C E:\LabFiles\M01L03Lab01\CommonFiles\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iE:\LabFiles\M01L03Lab01\ProblemQuery.sql -dAdventureWorksPTO > NUL 2> E:\LabFiles\M01L03Lab01\output\ProblemQuery.err


@ECHO %date% %time% - Press ENTER to end the scenario. 
pause %NULLREDIRECT%
@ECHO %date% %time% - Shutting down...


REM ========== Cleanup ========== 
CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\Cleanup.cmd
