@echo off

rem ============================================================
rem status.bat
rem
rem Commands:
rem
rem   call status.bat init "path\to\log.txt"
rem
rem   call status.bat running "Some operation"
rem
rem   call status.bat result "Some operation" EXIT_CODE "0"
rem
rem   Multiple successful exit codes:
rem
rem   call status.bat result "Some operation" EXIT_CODE "0 3010"
rem
rem Environment:
rem
rem   STATUS_LOG
rem       Set by "init".
rem
rem ============================================================

if "%~1"=="" goto :usage

if /i "%~1"=="init" (
    call :init "%~2"
    exit /b %errorlevel%
)

if /i "%~1"=="running" (
    call :running "%~2"
    exit /b %errorlevel%
)

if /i "%~1"=="result" (
    call :result "%~2" "%~3" "%~4"
    exit /b %errorlevel%
)

if /i "%~1"=="log" (
    call :log "%~2"
    exit /b %errorlevel%
)

goto :usage


:init
set "STATUS_LOG=%~1"

for %%D in ("%STATUS_LOG%") do (
    if not exist "%%~dpD" (
        mkdir "%%~dpD" >nul 2>&1
    )
)

> "%STATUS_LOG%" (
    echo ============================================================
    echo Log started: %date% %time%
    echo ============================================================
    echo.
)

exit /b 0


:running
call :colors

set "STATUS_MESSAGE=%~1"

call :log "[RUNNING] %STATUS_MESSAGE%"

<nul set /p "=%COLOR_RUNNING%[ RUNNING ]%COLOR_RESET% - %STATUS_MESSAGE%"

exit /b 0


:result
call :colors

set "STATUS_MESSAGE=%~1"
set "STATUS_EXIT_CODE=%~2"
set "STATUS_SUCCESS_CODES=%~3"

if not defined STATUS_SUCCESS_CODES (
    set "STATUS_SUCCESS_CODES=0"
)

set "STATUS_SUCCEEDED=0"

for %%C in (%STATUS_SUCCESS_CODES%) do (
    if "%STATUS_EXIT_CODE%"=="%%C" (
        set "STATUS_SUCCEEDED=1"
    )
)

rem Clear the current line and return cursor to column 1.
<nul set /p "=%ESC%[2K%ESC%[1G"

if "%STATUS_SUCCEEDED%"=="1" (
    echo %COLOR_OK%[   OK    ]%COLOR_RESET% - %STATUS_MESSAGE%
    call :log "[OK] %STATUS_MESSAGE% (exit code %STATUS_EXIT_CODE%)"
    exit /b 0
)

echo %COLOR_FAIL%[  FAIL   ]%COLOR_RESET% - %STATUS_MESSAGE%
call :log "[FAIL] %STATUS_MESSAGE% (exit code %STATUS_EXIT_CODE%)"

exit /b 1


:log
if not defined STATUS_LOG exit /b 0

>> "%STATUS_LOG%" echo [%date% %time%] %~1

exit /b 0


:colors

rem Obtain ASCII ESC without embedding special characters
rem directly into this file.

for /F "delims=" %%E in ('echo prompt $E^| cmd') do (
    set "ESC=%%E"
)

set "COLOR_RESET=%ESC%[0m"
set "COLOR_RUNNING=%ESC%[93m"
set "COLOR_OK=%ESC%[92m"
set "COLOR_FAIL=%ESC%[91m"

exit /b 0


:usage
echo Usage:
echo.
echo   status.bat init "log-file"
echo   status.bat running "message"
echo   status.bat result "message" exit-code "success-codes"
echo   status.bat log "message"
echo.
exit /b 1