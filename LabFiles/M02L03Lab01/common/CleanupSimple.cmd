@ECHO OFF

IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.
) ELSE (
  SET SQLSERVER=%1
)

REM If the %DEBUG% env var is set, don't suppress echo or stdout
IF "%DEBUG%"=="1" (
  @ECHO ON
  SET NULLREDIRECT=
) ELSE (
  SET NULLREDIRECT=^>NUL 2^>NUL
)

@ECHO %date% %time% - Running cleanup...

REM Create an output folder in the scenario directory
MD output >NUL 2>NUL

PUSHD ..\common

REM Create an output folder in the common directory
MD output >NUL 2>NUL

REM Signal any loop.cmd instances to exit
ECHO stop > loop.stop

REM Kill any sqlcmd.exe instances
taskkill /F /IM sqlcmd.exe  %NULLREDIRECT%

REM Kill any cscript.exe instances
taskkill /F /IM cscript.exe  %NULLREDIRECT%

MD output  %NULLREDIRECT%

POPD
EXIT /B %RETVAL%
