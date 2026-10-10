@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%"

set "STATUS=%PROJECT_ROOT%util\scripts\status.bat"

set "EXTERNAL_BUILD_SCRIPT=%PROJECT_ROOT%external\build_ext.win32.bat"

set "PROJECT_OUTPUT_DIR=%PROJECT_ROOT%.out"
set "NPM_PACKAGE_DIR=%PROJECT_OUTPUT_DIR%\civa"

set "CIVA_EXE_PATH=%NPM_PACKAGE_DIR%\civa.exe"
set "CIVA_SRC_ROOT=%PROJECT_ROOT%civa"

set "LOG_DIR=%PROJECT_OUTPUT_DIR%\logs"
set "LOG_FILE=%LOG_DIR%\build.log"


rem ---
rem Initialize logging
rem ---

call "%STATUS%" init "%LOG_FILE%"

if errorlevel 1 (
    echo Failed to initialize build logging.
    exit /b 1
)


rem ---
rem Build external dependencies
rem ---

call "%STATUS%" running "Building external dependencies"

call "%EXTERNAL_BUILD_SCRIPT%" >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Building external dependencies" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Initialize npm project
rem ---

if not exist "%NPM_PACKAGE_DIR%" (
    mkdir "%NPM_PACKAGE_DIR%"
)


pushd "%NPM_PACKAGE_DIR%"

call "%STATUS%" running "Initializing npm project"

npm init -y >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Initializing npm project" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    popd
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Install AssemblyScript
rem ---

call "%STATUS%" running "Installing AssemblyScript"

npm install --save-dev assemblyscript >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Installing AssemblyScript" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    popd
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Verify AssemblyScript installation
rem ---

call "%STATUS%" running "Verifying AssemblyScript installation"

npx asc --version >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Verifying AssemblyScript installation" "!RESULT!" "0"

popd

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Build CIVA
rem ---

call "%STATUS%" running "Building CIVA"

odin build . -out:"%CIVA_EXE_PATH%" >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Building CIVA" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Completion log
rem ---

echo.
echo Output: %CIVA_EXE_PATH%
echo Log   : %LOG_FILE%
echo.

endlocal
exit /b 0
