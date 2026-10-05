[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

set ignore-comments

[windows]
clean:
    ./clean.win32

[windows]
build: 
    ./build.win32

run_civa: build
    ./.out/civa

run_hash_schema *ARGS: build
    ./.out/hash_schema {{ ARGS }}