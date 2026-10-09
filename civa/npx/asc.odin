package civa_npx

import "core:strings"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:os"

// https://www.assemblyscript.org/compiler.html#compiler-options

// Optimizes the module.
ASC_Optimization_Kind :: enum u8 {
    // Default optimizations
    Default,
    // Optimize for speed
    Speed,
    // Optimize for size
    Size
}

// Optimizes the module to the specified levels.
ASC_Optimization_Level :: struct {
    kind: ASC_Optimization_Kind,
    // How much to focus on optimizing code. [0-3]
    level: u8,
    // How much to focus on shrinking code size. [0-2, s=1, z=2]
    shrink_level: u8
}

sbprint_asc_optimization_kind_as_args :: proc(buf: ^strings.Builder, optk: ASC_Optimization_Kind) -> string {
    suffix: string = ---
    switch optk {
        case .Default:
            suffix = ""
        case .Speed:
            suffix = "speed"
        case .Size:
            suffix = "size"
    }
    return fmt.sbprintf(buf, "-O%s ", suffix)
}

sbprint_asc_optimization_level_as_args :: proc(buf: ^strings.Builder, optlvl: ASC_Optimization_Level) -> string {
    sbprint_asc_optimization_kind_as_args(buf, optlvl.kind)
    return fmt.sbprintf(buf, "--optimizeLevel %d --shrinkLevel %d ", optlvl.level, optlvl.shrink_level)
}

// Optimizes the module to the specified levels. With special flags.
ASC_Optimization :: struct {
    level: ASC_Optimization_Level,
    // Re-optimizes until no further improvements can be made.
    converge: bool,
    // Replaces assertions with just their value without trapping.
    no_assert: bool
}

sbprint_asc_optimization_as_args :: proc(buf: ^strings.Builder, opt: ASC_Optimization) -> (res: string) {
    res = sbprint_asc_optimization_level_as_args(buf, opt.level)
    if opt.converge {
        res = fmt.sbprint(buf, "--converge ")
    }
    if opt.no_assert {
        res = fmt.sbprint(buf, "--noAssert ")
    }
    return
}

ASC_Builtin_Runtime :: enum u8 {
    // TLSF + incremental GC (default)
    Incremental,
    // TLSF + lightweight GC invoked externally
    Minimal,
    // Minimal runtime stub (never frees)
    Stub
}

sbprint_asc_builtin_runtime_as_args :: proc(buf: ^strings.Builder, br: ASC_Builtin_Runtime) -> string {
    suffix: string = ---
    switch br {
        case .Incremental:
            suffix = "incremental"
        case .Minimal:
            suffix = "minimal"
        case .Stub:
            suffix = "stub"
    }
    return fmt.sbprintf(buf, "--runtime %s ", suffix)
}

ASC_Runtime :: union #no_nil {
    ASC_Builtin_Runtime,
    // Path to a custom runtime implementation
    string
}

sbprint_asc_runtime_as_args :: proc(buf: ^strings.Builder, r: ASC_Runtime) -> string {
    switch actual in r {
        case ASC_Builtin_Runtime:
            return sbprint_asc_builtin_runtime_as_args(buf, actual)
        case string:
            return fmt.sbprintf(buf, "--runtime \"%s\" ", actual)
    }
    return ""
}

ASC_Feature :: enum u8 {
    // Mutable global imports and exports.
    MutableGlobals,
    // Sign-extension operations.
    SignExt,
    // Non-trapping float to integer ops.
    NonTrappingF2I,
    // Bulk memory operations.
    BulkMemory,

    // Threading and atomic operations.
    Threads,
    // SIMD types and operations.
    SIMD,
    // Reference types and operations.
    RefTypes,
    // Garbage collection (WIP).
    GC, 
    // String reference types.
    StringRef,
    // Relaxed SIMD operations.
    RelaxedSimd
}

ASC_Feature_Set :: bit_set[ASC_Feature]

ASC_DEFAULT_ENABLED_FEATURES :: ASC_Feature_Set{
    .MutableGlobals,
    .SignExt,
    .NonTrappingF2I,
    .BulkMemory
}

ASC_DEFAULT_DISABLED_FEATURES :: ASC_Feature_Set{
    .Threads,
    .SIMD,
    .RefTypes,
    .GC,
    .StringRef,
    .RelaxedSimd
}

ASC_ALL_FEATURES :: ASC_DEFAULT_ENABLED_FEATURES | ASC_DEFAULT_DISABLED_FEATURES

ASC_Config :: struct {
    opt: ASC_Optimization,
    // Specifies the WebAssembly output file (.wasm).
    wasm_output_file: Maybe(string),
    // Specifies the WebAssembly text output file (.wat).
    wat_output_file: Maybe(string),
    // Exports the start function using the specified name instead of calling it implicitly. Useful for WASI or to obtain the exported memory before executing any code accessing it.
    export_start: Maybe(string),
    // Specifies the runtime variant to include in the program.
    runtime: ASC_Runtime,
    // Enforces very low (<64k) memory constraints.
    low_memory_limit: bool,
    // Aliases a global object under another name.
    use: Maybe(map[string]string),
    // Enables WebAssembly features.
    enabled_features: ASC_Feature_Set, 
    // Disables WebAssembly features.
    disabled_features: ASC_Feature_Set
}

sbprint_asc_config_as_args :: proc(buf: ^strings.Builder, conf: ASC_Config) -> (res: string) {
    res = sbprint_asc_optimization_as_args(buf, conf.opt)
    if output_file, has_output_file := conf.wasm_output_file.?; has_output_file do res = fmt.sbprintf(buf, "-o \"%s\" ", output_file)
    if text_output_file, has_text_output_file := conf.wat_output_file.?; has_text_output_file do res = fmt.sbprintf(buf, "-t \"%s\" ", text_output_file)
    if export_start, has_export_start := conf.export_start.?; has_export_start do res = fmt.sbprintf(buf, "--exportStart %s ", export_start)
    res = sbprint_asc_runtime_as_args(buf, conf.runtime)
    if conf.low_memory_limit do res = fmt.sbprintf(buf, "--lowMemoryLimit ")
    if use, has_use := conf.use.?; has_use {
        for k, v in use do res = fmt.sbprintf(buf, "-u %s=%s ", k, v)
    }
    enabled_features: []ASC_Feature = slice.bitset_to_enum_slice(conf.enabled_features, ASC_Feature)
    defer delete(enabled_features)
    disabled_features: []ASC_Feature = slice.bitset_to_enum_slice(conf.disabled_features, ASC_Feature)
    defer delete(disabled_features)
    for feat in enabled_features {
        if feat in ASC_DEFAULT_DISABLED_FEATURES {
            suffix: string = ---
            switch feat {
                case .MutableGlobals: suffix = "mutable-globals"
                case .SignExt: suffix = "sign-extension"
                case .NonTrappingF2I: suffix = "nontrapping-f2i"
                case .BulkMemory: suffix = "bulk-memory"
                case .Threads: suffix = "threads"
                case .SIMD: suffix = "simd"
                case .RefTypes: suffix = "reference-types"
                case .GC: suffix = "gc"
                case .StringRef: suffix = "stringref"
                case .RelaxedSimd: suffix = "relaxed-simd"
            }
            res = fmt.sbprintf(buf, "--enable %s ", suffix)
        }
    }
    for feat in disabled_features {
        if feat in ASC_DEFAULT_ENABLED_FEATURES {
            suffix: string = ---
            switch feat {
                case .MutableGlobals: suffix = "mutable-globals"
                case .SignExt: suffix = "sign-extension"
                case .NonTrappingF2I: suffix = "nontrapping-f2i"
                case .BulkMemory: suffix = "bulk-memory"
                case .Threads: suffix = "threads"
                case .SIMD: suffix = "simd"
                case .RefTypes: suffix = "reference-types"
                case .GC: suffix = "gc"
                case .StringRef: suffix = "stringref"
                case .RelaxedSimd: suffix = "relaxed-simd"
            }
            res = fmt.sbprintf(buf, "--disable %s ", suffix)
        }
    }
    return
}

asc_config_to_cli_cmd :: proc(self: ^ASC_Config, allocator := context.allocator) -> (res: string, err: mem.Allocator_Error) {
    sb: strings.Builder
    strings.builder_init(&sb) or_return

    strings.write_string(&sb, "npx asc ")
    sbprint_asc_config_as_args(&sb, self^)

    res = strings.to_string(sb)
    return
}

asc_config_run :: proc(self: ^ASC_Config, working_dir := "") {
    pdesc: os.Process_Desc = ---
    pdesc.working_dir = working_dir

    pdesc.command = []string{ "npx", "asc" }

}