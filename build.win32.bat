@echo off

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%"

set "EXTERNAL_BUILD_SCRIPT=%PROJECT_ROOT%external\build_ext.win32.bat"
set "HASH_SCHEMA_EXE_PATH=%PROJECT_ROOT%.out\hash_schema.exe"
set "CIVA_EXE_PATH=%PROJECT_ROOT%.out\civa.exe"


call "%EXTERNAL_BUILD_SCRIPT%"

if errorlevel 1 (
    echo Failed to build external dependencies.
    exit /b 1
)

odin build schema_hash_algo -out:%HASH_SCHEMA_EXE_PATH%
odin build . -out:%CIVA_EXE_PATH%
