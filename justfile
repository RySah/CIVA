[windows]
set shell := ["powershell.exe", "-NoLogo", "-Command"]

set ignore-comments

build_arch := if arch() == "x86_64" { "x64" } else if arch() == "aarch64" { "arm64" } else if arch() == "x86" { "x86" } else { "native" }

[windows]
clean:
    ./clean.win32

[windows]
build arch=build_arch:
    ./build.win32 {{arch}}

test: build
    odin test tests/ -all-packages
