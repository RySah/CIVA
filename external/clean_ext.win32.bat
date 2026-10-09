@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "STATUS=%PROJECT_ROOT%\util\scripts\status.bat"

set "LIBXML2_BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "LIBXML2_OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2"

set "WAMR_BUILD_DIR=%PROJECT_ROOT%\.build\external\WAMR"
set "WAMR_OUTPUT_DIR=%PROJECT_ROOT%\.out\WAMR"

set "CEF_OUTPUT_DIR=%PROJECT_ROOT%\.out\cef"

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


rem ===
rem libxml2
rem ===


rem ---
rem Remove libxml2 build directory
rem ---

if exist "%LIBXML2_BUILD_DIR%" (
    call "%STATUS%" running "Removing libxml2 build directory"

    rmdir /s /q "%LIBXML2_BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing libxml2 build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Build directory does not exist: %LIBXML2_BUILD_DIR%"
)


rem ---
rem Remove libxml2 output directory
rem ---

if exist "%LIBXML2_OUTPUT_DIR%" (
    call "%STATUS%" running "Removing libxml2 output directory"

    rmdir /s /q "%LIBXML2_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing libxml2 output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Output directory does not exist: %LIBXML2_OUTPUT_DIR%"
)


rem ===
rem WAMR
rem ===


rem ---
rem Remove WAMR build directory
rem ---

if exist "%WAMR_BUILD_DIR%" (
    call "%STATUS%" running "Removing WAMR build directory"

    rmdir /s /q "%WAMR_BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing WAMR build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Build directory does not exist: %WAMR_BUILD_DIR%"
)


rem ---
rem Remove WAMR output directory
rem ---

if exist "%WAMR_OUTPUT_DIR%" (
    call "%STATUS%" running "Removing WAMR output directory"

    rmdir /s /q "%WAMR_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing WAMR output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Output directory does not exist: %WAMR_OUTPUT_DIR%"
)


rem ===
rem CEF
rem ===


rem ---
rem Remove CEF output directory
rem ---

if exist "%CEF_OUTPUT_DIR%" (
    call "%STATUS%" running "Removing CEF output directory"

    rmdir /s /q "%CEF_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing CEF output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "Output directory does not exist: %CEF_OUTPUT_DIR%"
)


rem ===
rem Completion
rem ===

echo.
echo External dependencies cleaned successfully.
echo.
echo Log: %LOG_FILE%
echo.

endlocal
exit /b 0