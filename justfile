[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

set ignore-comments

[windows]
clean:
    ./clean.win32

[windows]
build: 
    ./build.win32

quick-run: build
    ./.out/civa

quick-run-hash-schema *ARGS: build
    ./.out/hash_schema {{ ARGS }}