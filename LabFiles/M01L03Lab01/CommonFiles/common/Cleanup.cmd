@ECHO OFF

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

PUSHD E:\LabFiles\M01L03Lab01\CommonFiles\common

REM Create an output folder in the common directory
MD output >NUL 2>NUL

REM Signal any loop.cmd instances to exit
ECHO stop > E:\LabFiles\M01L03Lab01\CommonFiles\common\loop.stop

REM Kill any sqlcmd.exe instances
taskkill /F /IM sqlcmd.exe  %NULLREDIRECT%

REM Kill any cscript.exe instances
taskkill /F /IM cscript.exe  %NULLREDIRECT%

REM Run cleanup script
sqlcmd.exe -S%SQLSERVER% -E -iE:\LabFiles\M01L03Lab01\CommonFiles\common\Cleanup.sql -dAdventureWorksPTO > E:\LabFiles\M01L03Lab01\CommonFiles\common\output\Cleanup.out 2>&1

REM Check for prerequisites

CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\CheckPrerequisites.cmd
SET RETVAL=%ERRORLEVEL%

MD output  %NULLREDIRECT%

POPD
EXIT /B %RETVAL%
