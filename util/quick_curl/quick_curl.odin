package quick_curl

import curl "vendor:curl"

import "core:log"
import "core:strings"
import "core:c"
import "core:c/libc"

import "base:runtime"

Error :: curl.code

init :: proc "c" () -> Error {
    return curl.global_init(curl.GLOBAL_DEFAULT)
}

cleanup :: proc "c" () {
    curl.global_cleanup()
}

@(private="file")
_sbprint_url_content_cstr :: proc "c" (buf: ^strings.Builder, url: cstring) -> (err: Error) {
    _write_cb : curl.write_callback : proc "c" (
        buffer: [^]byte,
        size: c.size_t,
        nitems: c.size_t,
        outstream: rawptr
    ) -> c.size_t {
        context = runtime.default_context()

        real_size := size * nitems
        builder := transmute(^strings.Builder)outstream

        strings.write_bytes(builder, buffer[:nitems])
        return real_size
    }

    e := curl.easy_init()
    if e == nil {
        return .E_FAILED_INIT
    }

    curl.easy_setopt(e, .URL, url)
    curl.easy_setopt(e, .WRITEFUNCTION, _write_cb)
    curl.easy_setopt(e, .WRITEDATA, buf)
    curl.easy_setopt(e, .FOLLOWLOCATION, libc.long(1))

    err = curl.easy_perform(e)
    return
}

sbprint_url_content :: proc(buf: ^strings.Builder, url: string) -> (err: Error) {
    url_cstr := strings.clone_to_cstring(url)
    defer delete(url_cstr)

    return _sbprint_url_content_cstr(buf, url_cstr)
}

aprint_url_content :: proc(url: string, allocator := context.allocator) -> (res: string, err: Error) {
    b: strings.Builder = ---
    strings.builder_init(&b, allocator=allocator)
    sbprint_url_content(&b, url) or_return
    res = strings.to_string(b)
    return
}

caprint_url_content :: proc(url: string, allocator := context.allocator) -> (res: cstring, err: Error) {
    b: strings.Builder = ---
    strings.builder_init(&b, allocator=allocator)
    sbprint_url_content(&b, url) or_return
    res = strings.to_cstring(&b)
    return
}