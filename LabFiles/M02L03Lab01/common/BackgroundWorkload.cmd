PUSHD ..\common
MD output  %NULLREDIRECT%

IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.
) ELSE (
  SET SQLSERVER=%1
)

IF "%2"=="" (
  SET /A NUMCONN=%NUMBER_OF_PROCESSORS%*2
) ELSE (
  SET NUMCONN=%2
)

REM Each loop iteration should generally run for 1-2 min
CALL StartN.cmd /N %NUMCONN% /C loop.cmd sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorksPTO -iBackgroundWorkload.sql > NUL 2> output\background.err


POPD
