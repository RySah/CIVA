package libiwasm

when ODIN_OS == .Windows do foreign import lib "../../.out/WAMR/lib/iwasm.lib"
else                     do foreign import lib "../../.out/WAMR/lib/libiwasm.a"

import "core:c/libc"

foreign lib {
    wasm_config_delete :: proc "c" (^wasm_config_t) ---
    wasm_config_new :: proc "c" () -> ^wasm_config_t ---

    // Embedders may provide custom functions for manipulating configs.
    wasm_config_set_mem_alloc_opt :: proc "c" (^wasm_config_t, mem_alloc_type_t, ^MemAllocOption) -> ^wasm_config_t ---
    wasm_config_set_linux_perf_opt :: proc "c" (^wasm_config_t, libc.bool) -> ^wasm_config_t ---

    /**
     * Enable using GS register as the base address of linear memory in linux x86_64,
     * which may speedup the linear memory access for LLVM AOT/JIT:
     *   bit0 to bit4 denotes i32.load, i64.load, f32.load, f64.load, v128.load
     *   bit8 to bit12 denotes i32.store, i64.store, f32.store, f64.store, v128.store
     * For example, 0x01 enables i32.load, 0x0100 enables i32.store.
     * To enable all load/store operations, use 0x1F1F
     */
    wasm_config_set_segue_flags :: proc "c" (config: ^wasm_config_t, segue_flags: libc.uint32_t) -> ^wasm_config_t ---

    /**
     * Create a new engine
     *
     * Note: for the engine new/delete operations, including this,
     * wasm_engine_new_with_config, wasm_engine_new_with_args, and
     * wasm_engine_delete, if the platform has mutex initializer,
     * then they are thread-safe: we use a global lock to lock the
     * operations of the engine. Otherwise they are not thread-safe:
     * when there are engine new/delete operations happening
     * simultaneously in multiple threads, developer must create
     * the lock by himself, and add the lock when calling these
     * functions.
     */
    wasm_engine_delete :: proc "c" (^wasm_engine_t) ---
    wasm_engine_new :: proc "c" () -> ^wasm_engine_t ---
    wasm_engine_new_with_config :: proc "c" (^wasm_config_t) -> ^wasm_engine_t ---

    wasm_store_delete :: proc "c" (^wasm_store_t) ---
    wasm_store_new :: proc "c" (^wasm_engine_t) -> ^wasm_store_t ---
    
    wasm_valtype_vec_new_empty :: proc "c" (out: ^wasm_valtype_vec_t) ---
    wasm_valtype_vec_new_uninitialized :: proc "c" (out: ^wasm_valtype_vec_t, _: libc.size_t) ---
    wasm_valtype_vec_new :: proc "c" (out: ^wasm_valtype_vec_t, _: libc.size_t, _: [^]^wasm_valtype_t) ---
    wasm_valtype_vec_copy :: proc "c" (out: ^wasm_valtype_vec_t, _: ^wasm_valtype_vec_t) ---
    wasm_valtype_vec_delete :: proc "c" (^wasm_valtype_vec_t) ---

    wasm_valtype_delete :: proc "c" (^wasm_valtype_t) ---
    wasm_valtype_new :: proc "c" (wasm_valtype_t) -> ^wasm_valtype_t ---

    wasm_valtype_kind :: proc "c" (^wasm_valtype_t) -> wasm_valkind_t ---

    wasm_functype_vec_new_empty :: proc "c" (out: ^wasm_functype_vec_t) ---
    wasm_functype_vec_new_uninitialized :: proc "c" (out: ^wasm_functype_vec_t, _: libc.size_t) ---
    wasm_functype_vec_new :: proc "c" (out: ^wasm_functype_vec_t, _: libc.size_t, _: [^]^wasm_functype_t) ---
    wasm_functype_vec_copy :: proc "c" (out: ^wasm_functype_vec_t, _: ^wasm_functype_vec_t) ---
    wasm_functype_vec_delete :: proc "c" (^wasm_functype_vec_t) ---

    wasm_functype_delete :: proc "c" (^wasm_functype_t) ---
    wasm_functype_new :: proc "c" (params, results: ^wasm_valtype_vec_t) -> ^wasm_valtype_vec_t ---
    wasm_functype_params :: proc "c" (^wasm_functype_t) -> ^wasm_valtype_vec_t ---
    wasm_functype_result :: proc "c" (^wasm_functype_t) -> ^wasm_valtype_vec_t ---

    wasm_globaltype_vec_new_empty :: proc "c" (out: ^wasm_globaltype_vec_t) ---
    wasm_globaltype_vec_new_uninitialized :: proc "c" (out: ^wasm_globaltype_vec_t, _: libc.size_t) ---
    wasm_globaltype_vec_new :: proc "c" (out: ^wasm_globaltype_vec_t, _: libc.size_t, _: [^]^wasm_globaltype_t) ---
    wasm_globaltype_vec_copy :: proc "c" (out: ^wasm_globaltype_vec_t, _: ^wasm_globaltype_vec_t) ---
    wasm_globaltype_vec_delete :: proc "c" (^wasm_globaltype_vec_t) ---

    wasm_globaltype_delete :: proc "c" (^wasm_globaltype_t) ---
}

wasm_valkind_is_num :: #force_inline proc "contextless" (k: wasm_valkind_t) -> bool {
    return int(k) < int(wasm_valkind_t.WASM_EXTERNREF)
}

wasm_valkind_is_ref :: #force_inline proc "contextless" (k: wasm_valkind_t) -> bool {
    return int(k) >= int(wasm_valkind_t.WASM_EXTERNREF)
}

wasm_valtype_is_num :: #force_inline proc "c" (t: ^wasm_valtype_t) -> bool {
    return wasm_valkind_is_num(wasm_valtype_kind(t))
}

wasm_valtype_is_ref :: #force_inline proc "c" (t: ^wasm_valtype_t) -> bool {
    return wasm_valkind_is_ref(wasm_valtype_kind(t))
}

