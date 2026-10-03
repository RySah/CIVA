@echo off
setlocal

rem ---
rem Paths
rem
rem This script lives at:
rem   PROJECT_ROOT\external\clean_ext.bat
rem ---

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2"

echo.
rem ---
echo Cleaning external build artifacts
rem ---
echo Build  : %BUILD_DIR%
echo Output : %OUTPUT_DIR%
echo.

rem ---
rem Remove libxml2 build directory
rem ---

if exist "%BUILD_DIR%" (
    echo [INFO] Removing build directory...
    rmdir /s /q "%BUILD_DIR%"

    if errorlevel 1 (
        echo [ERROR] Failed to remove:
        echo         %BUILD_DIR%
        exit /b 1
    )
) else (
    echo [INFO] Build directory does not exist.
)

rem ---
rem Remove libxml2 output directory
rem ---

if exist "%OUTPUT_DIR%" (
    echo [INFO] Removing output directory...
    rmdir /s /q "%OUTPUT_DIR%"

    if errorlevel 1 (
        echo [ERROR] Failed to remove:
        echo         %OUTPUT_DIR%
        exit /b 1
    )
) else (
    echo [INFO] Output directory does not exist.
)

echo.
rem ---
echo [SUCCESS] External build artifacts cleaned successfully
rem ---
echo.

endlocal
exit /b 0