@echo off
setlocal

rem ---
rem Paths
rem
rem This script lives at:
rem   PROJECT_ROOT\external\build_ext.bat
rem ---

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "LIBXML2_SOURCE=%SCRIPT_DIR%libxml2-2.15.4"

set "BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2\lib"

echo.
rem ---
echo Building libxml2
rem ---
echo Source : %LIBXML2_SOURCE%
echo Build  : %BUILD_DIR%
echo Output : %OUTPUT_DIR%
echo.

rem ---
rem Ensure required directories exist
rem ---

if not exist "%BUILD_DIR%" (
    echo [INFO] Creating build directory...
    mkdir "%BUILD_DIR%"
)

if not exist "%OUTPUT_DIR%" (
    echo [INFO] Creating output directory...
    mkdir "%OUTPUT_DIR%"
)

rem ---
rem Configure
rem ---

echo [INFO] Configuring libxml2...

cmake ^
    -S "%LIBXML2_SOURCE%" ^
    -B "%BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DLIBXML2_WITH_ICONV=OFF ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%OUTPUT_DIR%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="%OUTPUT_DIR%"

if errorlevel 1 (
    echo.
    echo [ERROR] libxml2 configuration failed.
    exit /b 1
)

rem ---
rem Build
rem ---

echo.
echo [INFO] Building libxml2...

cmake --build "%BUILD_DIR%" --config Release

if errorlevel 1 (
    echo.
    echo [ERROR] libxml2 build failed.
    exit /b 1
)

echo.
echo ---
echo [SUCCESS] libxml2 built successfully
echo Output: %OUTPUT_DIR%
echo ---
echo.

endlocal
exit /b 0