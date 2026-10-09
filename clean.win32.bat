@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%"

set "STATUS=%PROJECT_ROOT%util\scripts\status.bat"

set "EXTERNAL_CLEAN_SCRIPT=%PROJECT_ROOT%external\clean_ext.win32.bat"

set "PROJECT_OUTPUT_DIR=%PROJECT_ROOT%.out"
set "NPM_PACKAGE_DIR=%PROJECT_OUTPUT_DIR%\civa"
set "CEF_OUTPUT_DIR=%PROJECT_OUTPUT_DIR%\cef"
set "CEF_FILES_MANIFEST=%CEF_OUTPUT_DIR%\.package-files"

set "PACKAGE_LOCK_JSON=%NPM_PACKAGE_DIR%\package-lock.json"
set "PACKAGE_JSON=%NPM_PACKAGE_DIR%\package.json"
set "NODE_MODULES=%NPM_PACKAGE_DIR%\node_modules"

set "CIVA_EXE_PATH=%NPM_PACKAGE_DIR%\civa.exe"
set "NPM_PACKAGE_DLLS=%NPM_PACKAGE_DIR%\*.dll"
set "CIVA_SRC_ROOT=%PROJECT_ROOT%civa"

set "LOG_DIR=%PROJECT_OUTPUT_DIR%\logs"
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
rem Remove CEF release files
rem ---

if exist "%CEF_FILES_MANIFEST%" (
    call "%STATUS%" running "Removing CEF release files"

    set "RESULT=0"

    for /f "usebackq delims=" %%F in ("%CEF_FILES_MANIFEST%") do (
        if exist "%NPM_PACKAGE_DIR%\%%F" (
            del /f /q "%NPM_PACKAGE_DIR%\%%F" >> "%LOG_FILE%" 2>&1
            if errorlevel 1 set "RESULT=1"
        )
    )

    call "%STATUS%" result "Removing CEF release files" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
) else (
    call "%STATUS%" log "CEF release file manifest does not exist: %CEF_FILES_MANIFEST%"
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
rem Remove application DLLs left by builds without a CEF manifest
rem ---

if not exist "%CEF_FILES_MANIFEST%" if exist "%NPM_PACKAGE_DLLS%" (
    call "%STATUS%" running "Removing legacy application DLLs"

    del /f /q "%NPM_PACKAGE_DLLS%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Removing legacy application DLLs" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Clean external dependencies after consuming the CEF file manifest
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