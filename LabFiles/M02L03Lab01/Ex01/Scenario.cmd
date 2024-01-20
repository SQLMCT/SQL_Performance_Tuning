@ECHO OFF

SETLOCAL
SET SCENARIONAME=MemoryPressure

IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.
) ELSE (
  SET SQLSERVER=%1
)

REM ========== Setup ========== 
@ECHO %date% %time% - Starting scenario %SCENARIONAME%...
CALL ..\common\Cleanup.cmd %SQLSERVER%
IF "%ERRORLEVEL%" NEQ "0" GOTO :eof
@ECHO %date% %time% - %SCENARIONAME% setup...
sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksPTO -ooutput\Setup.out -iSetup.sql %NULLREDIRECT%


REM ========== Start ========== 
@ECHO %date% %time% - Starting Plan Cache intensive queries...
SET /A NUMTHREADS=%NUMBER_OF_PROCESSORS%
@ECHO %date% %time% - Running ON %NUMTHREADS% threads
CALL ..\common\StartN.cmd /N %NUMTHREADS% /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iProblemQuery.sql -dAdventureWorksPTO 2^> output\ProblemQuery_{INSTANCENUM}.err > NUL
CALL ..\common\StartN.cmd /N %NUMTHREADS% /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iProblemQuery2.sql -dAdventureWorksPTO 2^> output\ProblemQuery2_{INSTANCENUM}.err > NUL
CALL ..\common\StartN.cmd /N %NUMTHREADS%/2 /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iProblemQuery3.sql -dAdventureWorksPTO 2^> output\ProblemQuery3_{INSTANCENUM}.err > NUL

@ECHO %date% %time% - Starting Buffer Pool intensive queries...
CALL ..\common\StartN.cmd /N %NUMTHREADS% /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iAllTbls_AdvWorksPTO.sql -dAdventureWorksPTO 2^> output\AllTbls_AdvWorks2014{INSTANCENUM}.err > NUL
CALL ..\common\StartN.cmd /N %NUMTHREADS% /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iAllTbls_WWI_DW.sql -dWideWorldImportersDW 2^> output\AllTbls_AdvWorksDW2014{INSTANCENUM}.err > NUL

@ECHO %date% %time% - Press ENTER to end the scenario. 
pause %NULLREDIRECT%
@ECHO %date% %time% - Shutting down...


REM ========== Cleanup ========== 
@ECHO %date% %time% - %SCENARIONAME% reset...
sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksPTO -ooutput\Reset.out -iReset.sql %NULLREDIRECT%
CALL ..\common\Cleanup.cmd %SQLSERVER%
