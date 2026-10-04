[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

set ignore-comments

[windows]
build-ext:
    ./external/build_ext.win32

[windows]
clean:
    ./external/clean_ext.win32

[windows]
build: build-ext
    odin build . -out:.out/civa.exe

[windows]
quick-run: build
    ./.out/civa