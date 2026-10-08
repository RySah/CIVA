[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

set ignore-comments

[windows]
clean:
    ./clean.win32

[windows]
build: 
    ./build.win32

test: build
    odin test tests/ -all-packages -define:ODIN_TEST_THREADS=1
