@ECHO OFF

REM If the %DEBUG% env var is set, don't suppress echo or stdout
IF "%DEBUG%"=="1" (
  @ECHO ON
  SET NULLREDIRECT=
) ELSE (
  SET NULLREDIRECT=^>NUL 2^>NUL
)

REM Clean up stop trigger from prior runs
IF EXIST ..\common\loop.stop DEL ..\common\loop.stop  %NULREDIRECT%

IF "%DEBUG%"=="1" @ECHO Starting loop ^(%*^)  %NULREDIRECT%

:Top
%*
REM Loop until loop.stop is created
..\bin\sleep 1
IF EXIST ..\common\loop.stop GOTO :Exit
GOTO :Top

:Exit
IF "%DEBUG%"=="1" @ECHO Exiting loop ^(%*^)  %NULREDIRECT%
GOTO :eof
