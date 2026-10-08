@echo off
setlocal EnableDelayedExpansion


rem ===
rem Paths
rem ===

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "STATUS=%PROJECT_ROOT%\util\scripts\status.bat"


rem ---
rem libxml2
rem ---

set "LIBXML2_SOURCE=%SCRIPT_DIR%libxml2-2.15.4"
set "LIBXML2_BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2"
set "LIBXML2_OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2\lib"


rem ---
rem WAMR
rem ---

set "WAMR_SOURCE=%SCRIPT_DIR%wasm-micro-runtime-WAMR-2.4.5"
set "WAMR_BUILD_DIR=%PROJECT_ROOT%\.build\external\WAMR"
set "WAMR_OUTPUT_DIR=%PROJECT_ROOT%\.out\WAMR\lib"


rem ---
rem Logging
rem ---

set "LOG_DIR=%PROJECT_ROOT%\.out\logs"
set "LOG_FILE=%LOG_DIR%\build_ext.log"



rem ===
rem Initialize logging
rem ===

call "%STATUS%" init "%LOG_FILE%"

if errorlevel 1 (
    echo Failed to initialize build logging.
    exit /b 1
)



rem ===
rem libxml2
rem ===


rem ---
rem Create libxml2 build directory
rem ---

if not exist "%LIBXML2_BUILD_DIR%" (
    call "%STATUS%" running "Creating libxml2 build directory"

    mkdir "%LIBXML2_BUILD_DIR%" >> "%LOG_FILE%" 2>&1
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
rem Create libxml2 output directory
rem ---

if not exist "%LIBXML2_OUTPUT_DIR%" (
    call "%STATUS%" running "Creating libxml2 output directory"

    mkdir "%LIBXML2_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
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
    -B "%LIBXML2_BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DLIBXML2_WITH_ICONV=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBXML2_OUTPUT_DIR%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="%LIBXML2_OUTPUT_DIR%" ^
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

cmake ^
    --build "%LIBXML2_BUILD_DIR%" ^
    --config Release ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Building libxml2" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)


rem ===
rem WAMR
rem ===


rem ---
rem Create WAMR build directory
rem ---

if not exist "%WAMR_BUILD_DIR%" (
    call "%STATUS%" running "Creating WAMR build directory"

    mkdir "%WAMR_BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating WAMR build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Create WAMR output directory
rem ---

if not exist "%WAMR_OUTPUT_DIR%" (
    call "%STATUS%" running "Creating WAMR output directory"

    mkdir "%WAMR_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating WAMR output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Configure WAMR
rem
rem CIVA currently only needs to execute portable .wasm modules.
rem Therefore:
rem
rem     Interpreter      : enabled
rem     Fast interpreter : enabled
rem     AOT              : disabled
rem     LLVM JIT         : disabled
rem     Fast JIT         : disabled
rem     Builtin libc     : enabled
rem     WASI libc        : disabled
rem     Multi-module     : disabled
rem
rem AOT/JIT can be enabled later without changing CIVA's VM API.
rem ---

call "%STATUS%" running "Configuring WAMR"

cmake ^
    -S "%WAMR_SOURCE%" ^
    -B "%WAMR_BUILD_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_POLICY_DEFAULT_CMP0091=NEW ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DWAMR_BUILD_PLATFORM=windows ^
    -DWAMR_BUILD_INTERP=1 ^
    -DWAMR_BUILD_FAST_INTERP=1 ^
    -DWAMR_BUILD_AOT=0 ^
    -DWAMR_BUILD_JIT=0 ^
    -DWAMR_BUILD_FAST_JIT=0 ^
    -DWAMR_BUILD_LIBC_BUILTIN=1 ^
    -DWAMR_BUILD_LIBC_WASI=0 ^
    -DWAMR_BUILD_MULTI_MODULE=0 ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%WAMR_OUTPUT_DIR%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="%WAMR_OUTPUT_DIR%" ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Configuring WAMR" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)


rem ---
rem Build WAMR
rem
rem vmlib is WAMR's embeddable runtime library.
rem Its OUTPUT_NAME is "iwasm", so on MSVC this should produce:
rem
rem     iwasm.lib
rem ---

call "%STATUS%" running "Building WAMR"

cmake ^
    --build "%WAMR_BUILD_DIR%" ^
    --config Release ^
    --target vmlib ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Building WAMR" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)



rem ===
rem Verify outputs
rem ===


rem ---
rem Verify WAMR output
rem ---

if not exist "%WAMR_OUTPUT_DIR%\iwasm.lib" (
    call "%STATUS%" running "Verifying WAMR output"

    echo Expected WAMR library was not generated: >> "%LOG_FILE%"
    echo %WAMR_OUTPUT_DIR%\iwasm.lib >> "%LOG_FILE%"

    call "%STATUS%" result "Verifying WAMR output" "1" "0"

    echo.
    echo WAMR build completed but iwasm.lib could not be found.
    echo Expected:
    echo %WAMR_OUTPUT_DIR%\iwasm.lib
    echo.
    echo See log:
    echo %LOG_FILE%

    exit /b 1
)


rem ==
rem Completion
rem ===

echo.
echo External dependencies built successfully.
echo.
echo libxml2:
echo   %LIBXML2_OUTPUT_DIR%
echo.
echo WAMR:
echo   %WAMR_OUTPUT_DIR%
echo.
echo Log:
echo   %LOG_FILE%
echo.

endlocal
exit /b 0