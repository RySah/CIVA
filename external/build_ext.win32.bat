@echo off
setlocal EnableDelayedExpansion


rem ===
rem Paths
rem ===

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

set "REQUESTED_ARCH=%~1"
if not defined REQUESTED_ARCH (
    if defined PROCESSOR_ARCHITEW6432 (
        set "REQUESTED_ARCH=%PROCESSOR_ARCHITEW6432%"
    ) else (
        set "REQUESTED_ARCH=%PROCESSOR_ARCHITECTURE%"
    )
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
goto arch_selected

:arch_x86
set "CMAKE_ARCH=Win32"
goto arch_selected

:arch_arm64
set "CMAKE_ARCH=ARM64"

:arch_selected
set "STATUS=%PROJECT_ROOT%\util\scripts\status.bat"


rem ---
rem libxml2
rem ---

set "LIBXML2_SOURCE=%SCRIPT_DIR%libxml2-2.15.4"
set "LIBXML2_BUILD_DIR=%PROJECT_ROOT%\.build\external\libxml2\%CMAKE_ARCH%"
set "LIBXML2_OUTPUT_DIR=%PROJECT_ROOT%\.out\libxml2\lib"


rem ---
rem WAMR
rem ---

set "WAMR_SOURCE=%SCRIPT_DIR%wasm-micro-runtime-WAMR-2.4.5"
set "WAMR_BUILD_DIR=%PROJECT_ROOT%\.build\external\WAMR\%CMAKE_ARCH%"
set "WAMR_OUTPUT_DIR=%PROJECT_ROOT%\.out\WAMR\lib"

rem ---
rem webview
rem ---

set "WEBVIEW_SOURCE=%SCRIPT_DIR%webview-0.12.0"
set "WEBVIEW_BUILD_DIR=%PROJECT_ROOT%\.build\external\webview\%CMAKE_ARCH%"
set "WEBVIEW_OUTPUT_DIR=%PROJECT_ROOT%\.out\webview\lib"
set "WEBVIEW_STATIC_LIBRARY=%WEBVIEW_OUTPUT_DIR%\webview_static.lib"
set "WEBVIEW2_SDK_ROOT=%SCRIPT_DIR%microsoft.web.webview2.1.0.4258.31"
set "WEBVIEW2_INCLUDE=%WEBVIEW2_SDK_ROOT%\build\native\include\WebView2.h"

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
    -A "%CMAKE_ARCH%" ^
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
    -A "%CMAKE_ARCH%" ^
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


rem ===
rem webview
rem ===

if not exist "%WEBVIEW_SOURCE%\CMakeLists.txt" (
    call "%STATUS%" log "webview source was not found: %WEBVIEW_SOURCE%"
    echo webview source was not found:
    echo %WEBVIEW_SOURCE%
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b 1
)

if not exist "%WEBVIEW2_INCLUDE%" (
    call "%STATUS%" log "WebView2 SDK headers were not found: %WEBVIEW2_INCLUDE%"
    echo WebView2 SDK headers were not found:
    echo %WEBVIEW2_INCLUDE%
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b 1
)


rem ---
rem Create webview build directory
rem ---

if not exist "%WEBVIEW_BUILD_DIR%" (
    call "%STATUS%" running "Creating webview build directory"

    mkdir "%WEBVIEW_BUILD_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating webview build directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Create webview output directory
rem ---

if not exist "%WEBVIEW_OUTPUT_DIR%" (
    call "%STATUS%" running "Creating webview output directory"

    mkdir "%WEBVIEW_OUTPUT_DIR%" >> "%LOG_FILE%" 2>&1
    set "RESULT=!ERRORLEVEL!"

    call "%STATUS%" result "Creating webview output directory" "!RESULT!" "0"

    if not "!RESULT!"=="0" (
        echo.
        echo See log:
        echo %LOG_FILE%
        exit /b !RESULT!
    )
)


rem ---
rem Configure webview static C API library
rem ---

call "%STATUS%" running "Configuring webview"

cmake ^
    -S "%WEBVIEW_SOURCE%" ^
    -B "%WEBVIEW_BUILD_DIR%" ^
    -A "%CMAKE_ARCH%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DMSWebView2_ROOT="%WEBVIEW2_SDK_ROOT%" ^
    -DWEBVIEW_BUILD=ON ^
    -DWEBVIEW_BUILD_STATIC_LIBRARY=ON ^
    -DWEBVIEW_BUILD_SHARED_LIBRARY=OFF ^
    -DWEBVIEW_BUILD_EXAMPLES=OFF ^
    -DWEBVIEW_BUILD_TESTS=OFF ^
    -DWEBVIEW_BUILD_DOCS=OFF ^
    -DWEBVIEW_INSTALL_TARGETS=OFF ^
    -DWEBVIEW_ENABLE_CHECKS=OFF ^
    -DWEBVIEW_ENABLE_PACKAGING=OFF ^
    -DWEBVIEW_USE_STATIC_MSVC_RUNTIME=ON ^
    -DWEBVIEW_USE_BUILTIN_MSWEBVIEW2=ON ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%WEBVIEW_OUTPUT_DIR%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE="%WEBVIEW_OUTPUT_DIR%" ^
    -DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY="%WEBVIEW_BUILD_DIR%" ^
    -DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY_RELEASE="%WEBVIEW_BUILD_DIR%" ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Configuring webview" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)


rem ---
rem Build webview static C API library
rem ---

call "%STATUS%" running "Building webview static library"

cmake ^
    --build "%WEBVIEW_BUILD_DIR%" ^
    --config Release ^
    --target webview_core_static ^
    >> "%LOG_FILE%" 2>&1

set "RESULT=%ERRORLEVEL%"

call "%STATUS%" result "Building webview static library" "%RESULT%" "0"

if not "%RESULT%"=="0" (
    echo.
    echo See log:
    echo %LOG_FILE%
    exit /b %RESULT%
)

if not exist "%WEBVIEW_STATIC_LIBRARY%" (
    call "%STATUS%" log "Expected webview static library was not generated: %WEBVIEW_STATIC_LIBRARY%"
    echo Expected webview static library was not generated:
    echo %WEBVIEW_STATIC_LIBRARY%
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
echo webview:
echo   Source:         %WEBVIEW_SOURCE%
echo   Build:          %WEBVIEW_BUILD_DIR%
echo   Output library: %WEBVIEW_STATIC_LIBRARY%
echo   Architecture:   %CMAKE_ARCH%
echo   Configuration:  Release
echo   CRT mode:       /MT
echo   WebView2 SDK:   %WEBVIEW2_SDK_ROOT%
echo.
echo Log:
echo   %LOG_FILE%
echo.

endlocal
exit /b 0

:invalid_arch
echo Unsupported architecture: %REQUESTED_ARCH%
echo Supported values: x64, x86, arm64
exit /b 2