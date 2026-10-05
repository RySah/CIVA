package schema_hash_algo

import "core:os"
import "core:fmt"
import "core:flags"
import "core:strings"

main :: proc() {
    Options :: struct {
		file: ^os.File `args:"pos=0,required,file=r" usage:"Input file."`,
		output: ^os.File `args:"pos=1,required,file=ca" usage:"Output file."`,
    }

    opt: Options = ---
	style : flags.Parsing_Style = .Odin
    flags.parse_or_exit(&opt, os.args, style)

    file_data, hash_result: []byte
    err: os.Error = ---

    file_data, err = os.read_entire_file(opt.file, context.allocator)
    if err != nil {
        fmt.eprintfln("ERR: Failed to read entire file. (%v)", err)
        os.exit(1)
    }

    hash_result, err = make([]byte, DIGEST_SIZE)
    if err != nil {
        fmt.eprintfln("ERR: Failed to allocate digest for output. (%v)", err)
        os.exit(1)
    }
    defer delete(hash_result)

    hash(file_data, hash_result)

    digest_hex_builder: strings.Builder
    strings.builder_init(&digest_hex_builder)
    defer strings.builder_destroy(&digest_hex_builder)

    for b in hash_result {
        fmt.sbprintf(&digest_hex_builder, "%X", b)
    }

    digest_hex := strings.to_string(digest_hex_builder)

    _, err = os.write_strings(opt.output, digest_hex, "\n")
    if err != nil {
        fmt.eprintfln("ERR: Failed to write hash result to output file. (%v)", err)
        os.exit(1)
    }
}