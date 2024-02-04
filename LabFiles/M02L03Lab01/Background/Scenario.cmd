@@ECHO OFF

SETLOCAL
SET SCENARIONAME=Background

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


REM ========== Start ========== 
REM Kick off a simulated workload so that we have a bit more interesting data to work with
@ECHO %date% %time% - Starting background workload...
CALL ..\common\BackgroundWorkload.cmd %SQLSERVER% %NUMTHREADS% %NULLREDIRECT%

@ECHO %date% %time% - Press ENTER to end the scenario. 
pause %NULLREDIRECT%
@ECHO %date% %time% - Shutting down...


REM ========== Cleanup ========== 
CALL ..\common\Cleanup.cmd %SQLSERVER%
