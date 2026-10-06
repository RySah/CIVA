@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%"

set "STATUS=%PROJECT_ROOT%util\scripts\status.bat"
set "EXTERNAL_CLEAN_SCRIPT=%PROJECT_ROOT%external\clean_ext.win32.bat"

set "PACKAGE_LOCK_JSON=%PROJECT_ROOT%package-lock.json"
set "PACKAGE_JSON=%PROJECT_ROOT%package.json"
set "NODE_MODULES=%PROJECT_ROOT%node_modules"

set "CIVA_EXE_PATH=%PROJECT_ROOT%.out\civa.exe"
set "CIVA_SRC_ROOT=%PROJECT_ROOT%civa"

set "LOG_DIR=%PROJECT_ROOT%.out\logs"
set "LOG_FILE=%LOG_DIR%\clean.log"


rem ---
rem Initialize logging
rem ---

call "%STATUS%" init "%LOG_FILE%"

if errorlevel 1 (
    echo Failed to initialize clean logging.
    exit /b 1
)


rem ---
rem Clean external dependencies
rem ---

call "%STATUS%" running "Cleaning external dependencies"

call "%EXTERNAL_CLEAN_SCRIPT%" >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Cleaning external dependencies" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Remove CIVA executable
rem ---

if exist "%CIVA_EXE_PATH%" (
    call "%STATUS%" running "Removing CIVA executable"

    del /f /q "%CIVA_EXE_PATH%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing CIVA executable" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "CIVA executable does not exist: %CIVA_EXE_PATH%"
)


rem ---
rem Remove npm lock file
rem ---

if exist "%PACKAGE_LOCK_JSON%" (
    call "%STATUS%" running "Removing npm lock file"

    del /f /q "%PACKAGE_LOCK_JSON%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing npm lock file" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "npm lock file does not exist: %PACKAGE_LOCK_JSON%"
)


rem ---
rem Remove npm package file
rem ---

if exist "%PACKAGE_JSON%" (
    call "%STATUS%" running "Removing npm package file"

    del /f /q "%PACKAGE_JSON%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing npm package file" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "npm package file does not exist: %PACKAGE_JSON%"
)


rem ---
rem Remove node_modules
rem ---

if exist "%NODE_MODULES%" (
    call "%STATUS%" running "Removing node_modules"

    rmdir /s /q "%NODE_MODULES%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing node_modules" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "node_modules does not exist: %NODE_MODULES%"
)


rem ---
rem Completion log
rem ---

echo.
echo Log: %LOG_FILE%
echo.

endlocal
exit /b 0
