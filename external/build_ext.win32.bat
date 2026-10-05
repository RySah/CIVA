@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "STATUS=%PROJECT_ROOT%\util\scripts\status.bat"

set "LIBXML2_SOURCE=%SCRIPT_DIR%libxml2-2.15.4"
set "BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2\lib"

set "LOG_DIR=%PROJECT_ROOT%\.out\logs"
set "LOG_FILE=%LOG_DIR%\build_ext.log"


rem ---
rem Initialize logging
rem ---

call "%STATUS%" init "%LOG_FILE%"

if errorlevel 1 (
    echo Failed to initialize build logging.
    exit /b 1
)


rem ---
rem Create build directory
rem ---

if not exist "%BUILD_DIR%" (
    call "%STATUS%" running "Creating libxml2 build directory"

    mkdir "%BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating libxml2 build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Create output directory
rem ---

if not exist "%OUTPUT_DIR%" (
    call "%STATUS%" running "Creating libxml2 output directory"

    mkdir "%OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating libxml2 output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Configure libxml2
rem ---

call "%STATUS%" running "Configuring libxml2"

cmake ^
    -S "%LIBXML2_SOURCE%" ^
    -B "%BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DLIBXML2_WITH_ICONV=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%OUTPUT_DIR%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="%OUTPUT_DIR%" ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Configuring libxml2" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)


rem ---
rem Build libxml2
rem ---

call "%STATUS%" running "Building libxml2"

cmake --build "%BUILD_DIR%" --config Release ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Building libxml2" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)


rem ---
rem Completion log
rem ---

echo.
echo Output: %OUTPUT_DIR%
echo Log   : %LOG_FILE%
echo.

endlocal
exit /b 0
