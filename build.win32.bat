@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%"

set "STATUS=%PROJECT_ROOT%util\scripts\status.bat"

set "EXTERNAL_BUILD_SCRIPT=%PROJECT_ROOT%external\build_ext.win32.bat"

set "PROJECT_OUTPUT_DIR=%PROJECT_ROOT%.out"
set "NPM_PACKAGE_DIR=%PROJECT_OUTPUT_DIR%\civa"

set "REQUESTED_ARCH=%~1"
if not defined REQUESTED_ARCH (
    set "REQUESTED_ARCH=native"
)

if /I "%REQUESTED_ARCH%"=="native" (
    if defined PROCESSOR_ARCHITEW6432 (
        set "REQUESTED_ARCH=%PROCESSOR_ARCHITEW6432%"
    ) else (
        set "REQUESTED_ARCH=%PROCESSOR_ARCHITECTURE%"
    )
)

if /I "%REQUESTED_ARCH%"=="x64" goto arch_x64
if /I "%REQUESTED_ARCH%"=="amd64" goto arch_x64
if /I "%REQUESTED_ARCH%"=="windows_amd64" goto arch_x64
if /I "%REQUESTED_ARCH%"=="x86" goto arch_x86
if /I "%REQUESTED_ARCH%"=="win32" goto arch_x86
if /I "%REQUESTED_ARCH%"=="i386" goto arch_x86
if /I "%REQUESTED_ARCH%"=="windows_i386" goto arch_x86
if /I "%REQUESTED_ARCH%"=="arm64" goto arch_arm64
if /I "%REQUESTED_ARCH%"=="aarch64" goto arch_arm64
if /I "%REQUESTED_ARCH%"=="windows_arm64" goto arch_arm64
goto invalid_arch

:arch_x64
set "CMAKE_ARCH=x64"
set "ODIN_TARGET=windows_amd64"
set "WEBVIEW2_ARCH=win-x64"
goto arch_selected

:arch_x86
set "CMAKE_ARCH=Win32"
set "ODIN_TARGET=windows_i386"
set "WEBVIEW2_ARCH=win-x86"
goto arch_selected

:arch_arm64
set "CMAKE_ARCH=ARM64"
set "ODIN_TARGET=windows_arm64"
set "WEBVIEW2_ARCH=win-arm64"

:arch_selected
set "CIVA_EXE_PATH=%NPM_PACKAGE_DIR%\civa.exe"
set "WEBVIEW2_LOADER_SOURCE=%PROJECT_ROOT%external\microsoft.web.webview2.1.0.4258.31\runtimes\%WEBVIEW2_ARCH%\native\WebView2Loader.dll"
set "WEBVIEW2_LOADER_PATH=%NPM_PACKAGE_DIR%\WebView2Loader.dll"
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

call "%EXTERNAL_BUILD_SCRIPT%" "%CMAKE_ARCH%" >> "%LOG_FILE%" 2>&1
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

odin build . -target:%ODIN_TARGET% -out:"%CIVA_EXE_PATH%" >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Building CIVA" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)


rem ---
rem Copy the architecture-matched WebView2 loader beside CIVA
rem ---

if not exist "%WEBVIEW2_LOADER_SOURCE%" (
    call "%STATUS%" log "WebView2 loader was not found: %WEBVIEW2_LOADER_SOURCE%"
    echo WebView2 loader was not found:
    echo %WEBVIEW2_LOADER_SOURCE%
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b 1
)

call "%STATUS%" running "Copying WebView2 loader"

copy /y "%WEBVIEW2_LOADER_SOURCE%" "%WEBVIEW2_LOADER_PATH%" >> "%LOG_FILE%" 2>&1
set "RESULT=!ERRORLEVEL!"

call "%STATUS%" result "Copying WebView2 loader" "!RESULT!" "0"

if not "!RESULT!"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b !RESULT!
)

if not exist "%WEBVIEW2_LOADER_PATH%" (
    call "%STATUS%" log "WebView2 loader was not copied to: %WEBVIEW2_LOADER_PATH%"
    echo WebView2 loader was not copied to:
    echo %WEBVIEW2_LOADER_PATH%
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b 1
)


rem ---
rem Completion log
rem ---

echo.
echo Output: %CIVA_EXE_PATH%
echo Architecture: %CMAKE_ARCH% (%ODIN_TARGET%)
echo WebView2 loader: %WEBVIEW2_LOADER_PATH%
echo Log: %LOG_FILE%
echo.

endlocal
exit /b 0

:invalid_arch
echo Unsupported architecture: %REQUESTED_ARCH%
echo Supported values: native, x64, x86, arm64
exit /b 2
