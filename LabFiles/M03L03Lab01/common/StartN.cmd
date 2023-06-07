@ECHO OFF

REM If the %DEBUG% env var is set, don't suppress echo or stdout
IF "%DEBUG%"=="1" (
  @ECHO ON
  SET NULLREDIRECT=
) ELSE (
  SET NULLREDIRECT=^>NUL 2^>NUL
)

IF "%1"=="" GOTO :DisplayUsage
IF "%2"=="" GOTO :DisplayUsage
SETLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION


REM Process any "local" param line commands

SET NUMINSTANCES=0
:NextParam
SET FULLPARAM=%1
SET CURPARAM=%FULLPARAM%
REM Params should all start with "/" or "-"
IF "%CURPARAM:~0,1%" NEQ "/" (
  IF "%CURPARAM:~0,1%" NEQ "-" GOTO :DisplayUsage
)

REM Get rid of "/" or "-" 
SET CURPARAM=%CURPARAM:~1%
SHIFT

IF "%CURPARAM%"=="N" (
  SET /A NUMINSTANCES=%1
  SHIFT
  GOTO :NextParam
)

IF "%CURPARAM%" NEQ "C" (
  @ECHO ERROR: Unknown parameter "%FULLPARAM%".
  GOTO :DisplayUsage
)

REM If we get here, we've reached the final /C parameter.  All remaining params are part of 
REM the command that we must execute. 
SET COMMANDTORUN=
:NextCommandParam
IF `%1`==`` GOTO :DoneWithCommand
SET COMMANDTORUN=%COMMANDTORUN% %1
SHIFT
GOTO :NextCommandParam
:DoneWithCommand


REM Validate command line parameters
IF "%NUMINSTANCES%"=="0" (
  @ECHO ERROR: Missing required parameter: /N ^<n^>
  GOTO :DisplayUsage
)

IF NOT DEFINED COMMANDTORUN (
  @ECHO ERROR: Missing required parameter: /C ^<cmd^>
  GOTO :DisplayUsage
)

IF %NUMINSTANCES% GTR 256 (
  @ECHO ERROR: Instance count ^(%NUMINSTANCES%^) exceeds maximum ^(255^)
  GOTO :DisplayUsage
)


IF "%DEBUG%"=="1" @ECHO         Command: %COMMANDTORUN%
IF "%DEBUG%"=="1" @ECHO       Instances: %NUMINSTANCES%

REM Launch N instances of the command in parallel 
SET /A INSTANCENUM=0
FOR /L %%I IN (1,1,%NUMINSTANCES%) DO (
  SET /A INSTANCENUM=!INSTANCENUM!+1
  SET CURCOMMAND=%COMMANDTORUN%
  CALL :RunCmd
)

ENDLOCAL
GOTO :eof


:RunCmd
SET CURCOMMAND=%CURCOMMAND:{INSTANCENUM}=!INSTANCENUM!% 
IF "%DEBUG%"=="1" ECHO Launching instance %INSTANCENUM%...
IF "%DEBUG%"=="1" ECHO START "" /B %CURCOMMAND% ^& exit
REM Use /B to avoid launching a new console for every spawned process
START "" /B cmd.exe /C %CURCOMMAND% ^& exit
GOTO :eof



:DisplayUsage
@ECHO.
@ECHO Usage: StartN.cmd /N ^<n^> [/LOW] [/HIGH] /C ^<cmd^>
@ECHO.
@ECHO     /C ^<cmd^>   Command to execute
@ECHO     /N ^<n^>     Number of instances of the command to run (0-255)
@ECHO.
@ECHO /N and /C are required. /C ^<cmd^> must be the final parameter on the command line. 
@ECHO If the string {INSTANCENUM} appears in ^<cmd^>, it will be replaced with an integer 
@ECHO 1...N, identifying the command instance. 
@ECHO.
@ECHO Examples: 
@ECHO.
@ECHO Run a query on five connections simultaneously: 
@ECHO    StartN.cmd /N 5 /C sqlcmd.exe -E -Q "WAITFOR DELAY '0:0:5' SELECT {INSTANCENUM}, GETDATE()"
@ECHO.
GOTO :eof
