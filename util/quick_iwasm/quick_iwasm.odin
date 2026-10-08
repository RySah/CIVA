package quick_xml

import plibiwasm "../libiwasm"

import "core:c/libc"
import "core:strings"
import "core:mem"
import "core:sync"

Error :: enum u8 {
    None,
    RuntimeInitFailed,
    BytecodeAllocationFailed,
    BytecodeTooLarge,
    ModuleLoadFailed,
    InstanceLoadFailed,
    ExecEnvCreationFailed
}

Value_Kind :: plibiwasm.Val_Kind

Value :: plibiwasm.Val

Runtime_Module :: struct {
    // Treat this owning value as move-only; pass it by pointer and delete it once.
    _module: plibiwasm.Module,
    _inst: plibiwasm.Module_Inst,
    _exec_env: plibiwasm.Exec_Env,
    _bytecode: []u8,
    _allocator: mem.Allocator,
    _owns_runtime: bool
}

delete_runtime_module :: proc(self: ^Runtime_Module) {
    if self == nil do return

    has_wasm_resources := self._exec_env != nil || self._inst != nil || self._module != nil
    owns_thread_env := false
    if has_wasm_resources {
        thread_env_ok: bool
        owns_thread_env, thread_env_ok = _wasm_thread_env_begin()
        assert_contextless(thread_env_ok)
    }

    if self._exec_env != nil {
        plibiwasm.wasm_runtime_destroy_exec_env(self._exec_env)
    }
    if self._inst != nil {
        plibiwasm.wasm_runtime_deinstantiate(self._inst)
    }
    if self._module != nil {
        plibiwasm.wasm_runtime_unload(self._module)
    }
    if len(self._bytecode) > 0 {
        delete(self._bytecode, allocator=self._allocator)
    }

    if owns_thread_env do plibiwasm.wasm_runtime_destroy_thread_env()
    owns_runtime := self._owns_runtime
    self^ = {}
    if owns_runtime do runtime_destroy()
}

runtime_module_lookup_function_cstr:: #force_inline proc "contextless" (module: ^Runtime_Module, name: cstring) -> Maybe(Function) {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    if !thread_env_ok do return nil
    defer _wasm_thread_env_end(owns_thread_env)

    return plibiwasm.wasm_runtime_lookup_function(module._inst, name)
}

runtime_module_get_exception :: #force_inline proc "contextless" (module: ^Runtime_Module) -> cstring {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    if !thread_env_ok do return nil
    defer _wasm_thread_env_end(owns_thread_env)

    return plibiwasm.wasm_runtime_get_exception(module._inst)
}

Function :: plibiwasm.Function_Inst

runtime_module_lookup_function :: proc(module: ^Runtime_Module, name: string) -> Maybe(Function) {
    name_cstr := strings.clone_to_cstring(name)
    defer delete(name_cstr)
    return runtime_module_lookup_function_cstr(module, name_cstr)
}

runtime_module_function_get_param_types_into_buf :: proc "contextless" (module: ^Runtime_Module, func: Function, buf: []Value_Kind) {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    assert_contextless(thread_env_ok)
    defer _wasm_thread_env_end(owns_thread_env)

    when !ODIN_NO_BOUNDS_CHECK {
        expected_count := int(plibiwasm.wasm_func_get_param_count(func, module._inst))
        assert_contextless(len(buf) >= expected_count)
    }
    plibiwasm.wasm_func_get_param_types(func, module._inst, raw_data(buf))
}

runtime_module_function_get_param_types_buf :: proc(module: ^Runtime_Module, func: Function, allocator := context.allocator) -> (buf: []Value_Kind, err: mem.Allocator_Error) #optional_allocator_error {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    assert_contextless(thread_env_ok)
    defer _wasm_thread_env_end(owns_thread_env)

    expected_count := int(plibiwasm.wasm_func_get_param_count(func, module._inst))
    buf = make([]Value_Kind, expected_count, allocator=allocator) or_return
    #no_bounds_check {
        runtime_module_function_get_param_types_into_buf(module, func, buf)
    }
    return
}

runtime_module_function_get_param_types :: proc{
    runtime_module_function_get_param_types_into_buf,
    runtime_module_function_get_param_types_buf
}

runtime_module_function_get_result_types_into_buf :: proc "contextless" (module: ^Runtime_Module, func: Function, buf: []Value_Kind) {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    assert_contextless(thread_env_ok)
    defer _wasm_thread_env_end(owns_thread_env)

    when !ODIN_NO_BOUNDS_CHECK {
        expected_count := int(plibiwasm.wasm_func_get_result_count(func, module._inst))
        assert_contextless(len(buf) >= expected_count)
    }
    plibiwasm.wasm_func_get_result_types(func, module._inst, raw_data(buf))
}

runtime_module_function_get_result_types_buf :: proc(module: ^Runtime_Module, func: Function, allocator := context.allocator) -> (buf: []Value_Kind, err: mem.Allocator_Error) #optional_allocator_error {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    assert_contextless(thread_env_ok)
    defer _wasm_thread_env_end(owns_thread_env)

    expected_count := int(plibiwasm.wasm_func_get_result_count(func, module._inst))
    buf = make([]Value_Kind, expected_count, allocator=allocator) or_return
    #no_bounds_check {
        runtime_module_function_get_result_types_into_buf(module, func, buf)
    }
    return
}

runtime_module_function_get_result_types :: proc{
    runtime_module_function_get_result_types_into_buf,
    runtime_module_function_get_result_types_buf
}

runtime_module_function_call :: proc(module: ^Runtime_Module, func: Function, results: []Value, args: []Value) -> (success: bool) {
    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    if !thread_env_ok do return false
    defer _wasm_thread_env_end(owns_thread_env)

    success = plibiwasm.wasm_runtime_call_wasm_a(
        module._exec_env,
        func,
        libc.uint32_t(len(results)), raw_data(results),
        libc.uint32_t(len(args)), raw_data(args)
    )
    return
}

_wasm_thread_env_begin :: proc "contextless" () -> (owns_thread_env, success: bool) {
    if plibiwasm.wasm_runtime_thread_env_inited() {
        return false, true
    }
    if !plibiwasm.wasm_runtime_init_thread_env() {
        return false, false
    }
    return true, true
}

_wasm_thread_env_end :: proc "contextless" (owns_thread_env: bool) {
    if owns_thread_env {
        plibiwasm.wasm_runtime_destroy_thread_env()
    }
}

@(private="file") _global_lock: sync.Mutex
@(private="file") _runtime_users: int

runtime_init :: proc "contextless" () -> bool {
    if sync.mutex_guard(&_global_lock) {
        if _runtime_users == 0 {
            if !plibiwasm.wasm_runtime_init() {
                return false
            }
        }

        _runtime_users += 1
        return true
    }

    return false
}

runtime_destroy :: proc "contextless" () {
    if sync.mutex_guard(&_global_lock) {
        assert_contextless(_runtime_users > 0)

        _runtime_users -= 1

        if _runtime_users == 0 {
            plibiwasm.wasm_runtime_destroy()
        }
    }
}

get_runtime_module_for_bytecode :: proc(
    data: []byte,
    err_buf: []byte,
    stack_size, default_heap_size: u32,
    allocator := context.allocator
) -> (runtime_mod: Runtime_Module, err: Error) {
    if !runtime_init() {
        err = .RuntimeInitFailed
        return
    }
    runtime_mod._owns_runtime = true
    release_runtime_on_exit := true
    defer if release_runtime_on_exit do runtime_destroy()

    if u64(len(data)) > u64(0xffff_ffff) {
        err = .BytecodeTooLarge
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }

    bytecode, alloc_err := make([]u8, len(data), allocator=allocator)
    if alloc_err != nil {
        err = .BytecodeAllocationFailed
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }
    runtime_mod._bytecode = bytecode
    runtime_mod._allocator = allocator
    copy(runtime_mod._bytecode, data)

    owns_thread_env, thread_env_ok := _wasm_thread_env_begin()
    if !thread_env_ok {
        err = .ModuleLoadFailed
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }
    defer _wasm_thread_env_end(owns_thread_env)

    runtime_mod._module = plibiwasm.wasm_runtime_load(
        raw_data(runtime_mod._bytecode), libc.uint32_t(len(runtime_mod._bytecode)),
        raw_data(err_buf), libc.uint32_t(len(err_buf))
    )
    if runtime_mod._module == nil {
        err = .ModuleLoadFailed
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }

    runtime_mod._inst = plibiwasm.wasm_runtime_instantiate(
        runtime_mod._module,
        stack_size, default_heap_size,
        raw_data(err_buf), libc.uint32_t(len(err_buf))
    )
    if runtime_mod._inst == nil {
        err = .InstanceLoadFailed
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }

    runtime_mod._exec_env = plibiwasm.wasm_runtime_create_exec_env(runtime_mod._inst, stack_size)
    if runtime_mod._exec_env == nil {
        err = .ExecEnvCreationFailed
        runtime_mod._owns_runtime = false
        delete_runtime_module(&runtime_mod)
        return
    }

    release_runtime_on_exit = false
    return
}