package civa_npx

import "core:fmt"
import "core:mem"
import "core:slice"

import cli "../../util/cli"

// https://www.assemblyscript.org/compiler.html#compiler-options

General_Error :: enum u8 {
    None,
    FailedToRun
}

Error :: union #shared_nil {
    General_Error,
    mem.Allocator_Error,
    cli.Error
}

// Optimizes the module.
ASC_Optimization_Kind :: enum u8 {
    // Default optimizations
    Default,
    // Optimize for speed
    Speed,
    // Optimize for size
    Size
}

command_list_add_asc_optimization_kind :: proc(self: ^cli.Command_List, optk: ASC_Optimization_Kind) -> (err: mem.Allocator_Error) {
    suffix: string = ---
    switch optk {
        case .Default:
            suffix = ""
        case .Speed:
            suffix = "speed"
        case .Size:
            suffix = "size"
    }
    return cli.command_list_append(self, "--optimize", suffix)
}

// Optimizes the module to the specified levels.
ASC_Optimization_Level :: struct {
    kind: ASC_Optimization_Kind,
    // How much to focus on optimizing code. [0-3]
    level: u8,
    // How much to focus on shrinking code size. [0-2, s=1, z=2]
    shrink_level: u8
}

command_list_add_asc_optimization_level :: proc(self: ^cli.Command_List, optlvl: ASC_Optimization_Level) -> (err: mem.Allocator_Error) {
    command_list_add_asc_optimization_kind(self, optlvl.kind) or_return
    optimize_level := fmt.aprintf("%d", optlvl.level)
    defer delete(optimize_level)
    shrink_level := fmt.aprintf("%d", optlvl.shrink_level)
    defer delete(shrink_level)
    return cli.command_list_append(self, "--optimizeLevel", optimize_level, "--shrinkLevel", shrink_level)
} 

// Optimizes the module to the specified levels. With special flags.
ASC_Optimization :: struct {
    level: ASC_Optimization_Level,
    // Re-optimizes until no further improvements can be made.
    converge: bool,
    // Replaces assertions with just their value without trapping.
    no_assert: bool
}

command_list_add_asc_optimization :: proc(self: ^cli.Command_List, opt: ASC_Optimization) -> (err: mem.Allocator_Error) {
    command_list_add_asc_optimization_level(self, opt.level) or_return
    if opt.converge do cli.command_list_append(self, "--converge") or_return
    if opt.no_assert do cli.command_list_append(self, "--noAssert") or_return
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

command_list_add_asc_builtin_runtime :: proc(self: ^cli.Command_List, br: ASC_Builtin_Runtime) -> (err: mem.Allocator_Error) {
    suffix: string = ---
    switch br {
        case .Incremental:
            suffix = "incremental"
        case .Minimal:
            suffix = "minimal"
        case .Stub:
            suffix = "stub"
    }
    return cli.command_list_append(self, "--runtime", suffix)
}

ASC_Runtime :: union #no_nil {
    ASC_Builtin_Runtime,
    // Path to a custom runtime implementation
    string
}

command_list_add_asc_runtime :: proc(self: ^cli.Command_List, r: ASC_Runtime) -> (err: mem.Allocator_Error) {
    switch actual in r {
        case ASC_Builtin_Runtime:
            return command_list_add_asc_builtin_runtime(self, actual)
        case string:
            return cli.command_list_append(self, "--runtime", actual)
    }
    return
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

command_list_add_asc_config :: proc(self: ^cli.Command_List, config: ^ASC_Config) -> (err: mem.Allocator_Error) {
    command_list_add_asc_optimization(self, config.opt) or_return
    if output_file, has_output_file := config.wasm_output_file.?; has_output_file do cli.command_list_append(self, "--outFile", output_file) or_return
    if text_output_file, has_text_output_file := config.wat_output_file.?; has_text_output_file do cli.command_list_append(self, "--textFile", text_output_file) or_return
    if export_start, has_export_start := config.export_start.?; has_export_start do cli.command_list_append(self, "--exportStart", export_start) or_return
    command_list_add_asc_runtime(self, config.runtime) or_return
    if config.low_memory_limit do cli.command_list_append(self, "--lowMemoryLimit") or_return
    if use, has_use := config.use.?; has_use {
        for k, v in use {
            d := fmt.aprintf("%s=%s", k, v)
            defer delete(d)
            cli.command_list_append(self, "--use", d) or_return
        }
    }
    enabled_features: []ASC_Feature = slice.bitset_to_enum_slice(config.enabled_features, ASC_Feature)
    defer delete(enabled_features)
    disabled_features: []ASC_Feature = slice.bitset_to_enum_slice(config.disabled_features, ASC_Feature)
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
            cli.command_list_append(self, "--enable", suffix) or_return
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
            cli.command_list_append(self, "--disable", suffix) or_return
        }
    }
    return
}

asc_config_to_command_list :: proc(self: ^ASC_Config, allocator := context.allocator) -> (cl: cli.Command_List, err: mem.Allocator_Error) {
    cl = cli.make_command_list(allocator=allocator) or_return
    cli.command_list_append(&cl, "npx", "asc") or_return
    command_list_add_asc_config(&cl, self) or_return
    return
}

asc_config_run :: proc(self: ^ASC_Config, working_dir := "") -> (err: Error) {
    cl := asc_config_to_command_list(self) or_return
    defer cli.delete_command_list(&cl)

    pstate, stdout, stderr := cli.command_list_exec(&cl) or_return
    defer delete(stdout)
	defer delete(stderr)

    success := pstate.exit_code == 0 when ODIN_OS == .Windows else pstate.success
    if !success {
        err = .FailedToRun
        return
    }

    return
}