SETLOCAL
PUSHD E:\LabFiles\M01L03Lab01\CommonFiles\common
REM MD output  %NULLREDIRECT%

IF "%1"=="" (
  SET /A NUMCONN=%NUMBER_OF_PROCESSORS%
) ELSE (
  SET NUMCONN=%1
)
IF %NUMCONN% LSS 1 SET NUMCOMM=1
REM Increase the number of connections running the background workload (or eliminate it entirely) based on the BACKGROUNDLOAD env var
IF DEFINED BACKGROUNDLOAD SET /A NUMCONN=%NUMCONN%*%BACKGROUNDLOAD%

REM Each loop iteration will generally run for 1-2 min
IF %NUMCONN% GTR 0 CALL E:\LabFiles\M01L03Lab01\CommonFiles\common\StartN.cmd /N %NUMCONN% /C E:\LabFiles\M01L03Lab01\CommonFiles\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iE:\LabFiles\M01L03Lab01\CommonFiles\common\BackgroundWorkload.sql -W -h-1 > NUL 2> E:\LabFiles\M01L03Lab01\CommonFiles\common\output\background.err

POPD
ENDLOCAL
GOTO :eof
