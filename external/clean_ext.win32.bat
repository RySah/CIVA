@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "STATUS=%PROJECT_ROOT%\util\scripts\status.bat"

set "BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2"

set "LOG_DIR=%PROJECT_ROOT%\.out\logs"
set "LOG_FILE=%LOG_DIR%\clean_ext.log"


rem ---
rem Initialize logging
rem ---

call "%STATUS%" init "%LOG_FILE%"

if errorlevel 1 (
    echo Failed to initialize clean logging.
    exit /b 1
)


rem ---
rem Remove libxml2 build directory
rem ---

if exist "%BUILD_DIR%" (
    call "%STATUS%" running "Removing libxml2 build directory"

    rmdir /s /q "%BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing libxml2 build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Build directory does not exist: %BUILD_DIR%"
)


rem ---
rem Remove libxml2 output directory
rem ---

if exist "%OUTPUT_DIR%" (
    call "%STATUS%" running "Removing libxml2 output directory"

    rmdir /s /q "%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing libxml2 output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Output directory does not exist: %OUTPUT_DIR%"
)


rem ---
rem Completion log
rem ---

echo.
echo Log: %LOG_FILE%
echo.

endlocal
exit /b 0