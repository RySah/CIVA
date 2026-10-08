package quick_xml

import plibiwasm "../libiwasm"

import "core:c/libc"
import "core:strings"
import "core:mem"

Error :: enum u8 {
    None,
    ModuleLoadFailed,
    InstanceLoadFailed,
    ExecEnvCreationFailed
}

Value_Kind :: plibiwasm.Val_Kind

Value :: plibiwasm.Val

Runtime_Module :: struct {
    _inst: plibiwasm.Module_Inst,
    _exec_env: plibiwasm.Exec_Env
}

delete_runtime_module :: proc(self: Runtime_Module) {
    mod := plibiwasm.wasm_runtime_get_module(self._inst)
    
    defer plibiwasm.wasm_runtime_unload(mod)
    defer plibiwasm.wasm_runtime_deinstantiate(self._inst)
    defer plibiwasm.wasm_runtime_destroy_exec_env(self._exec_env)
}

runtime_module_lookup_function_cstr:: #force_inline proc "contextless" (module: Runtime_Module, name: cstring) -> Maybe(Function) {
    return plibiwasm.wasm_runtime_lookup_function(module._inst, name)
}

runtime_module_get_exception :: #force_inline proc "contextless" (module: Runtime_Module) -> cstring {
    return plibiwasm.wasm_runtime_get_exception(module._inst)
}

Function :: plibiwasm.Function_Inst

runtime_module_lookup_function :: proc(module: Runtime_Module, name: string) -> Maybe(Function) {
    name_cstr := strings.clone_to_cstring(name)
    defer delete(name_cstr)
    return runtime_module_lookup_function_cstr(module, name_cstr)
}

runtime_module_function_get_param_types_into_buf :: proc "contextless" (module: Runtime_Module, func: Function, buf: []Value_Kind) {
    when !ODIN_NO_BOUNDS_CHECK {
        expected_count := int(plibiwasm.wasm_func_get_param_count(func, module._inst))
        assert_contextless(len(buf) >= expected_count)
    }
    plibiwasm.wasm_func_get_param_types(func, module._inst, raw_data(buf))
}

runtime_module_function_get_param_types_buf :: proc(module: Runtime_Module, func: Function, allocator := context.allocator) -> (buf: []Value_Kind, err: mem.Allocator_Error) #optional_allocator_error {
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

runtime_module_function_get_result_types_into_buf :: proc "contextless" (module: Runtime_Module, func: Function, buf: []Value_Kind) {
    when !ODIN_NO_BOUNDS_CHECK {
        expected_count := int(plibiwasm.wasm_func_get_result_count(func, module._inst))
        assert_contextless(len(buf) >= expected_count)
    }
    plibiwasm.wasm_func_get_result_types(func, module._inst, raw_data(buf))
}

runtime_module_function_get_result_types_buf :: proc(module: Runtime_Module, func: Function, allocator := context.allocator) -> (buf: []Value_Kind, err: mem.Allocator_Error) #optional_allocator_error {
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

runtime_module_function_call :: proc(module: Runtime_Module, func: Function, results: []Value, args: []Value) -> (success: bool) {
    success = plibiwasm.wasm_runtime_call_wasm_a(
        module._exec_env,
        func,
        libc.uint32_t(len(results)), raw_data(results),
        libc.uint32_t(len(args)), raw_data(args)
    )
    return
}

runtime_init :: plibiwasm.wasm_runtime_init
runtime_destroy :: plibiwasm.wasm_runtime_destroy

get_runtime_module_for_bytecode :: proc(
    data: []byte,
    err_buf: []byte,
    stack_size, default_heap_size: u32
) -> (runtime_mod: Runtime_Module, err: Error) {
    mod := plibiwasm.wasm_runtime_load(
        raw_data(data), libc.uint32_t(len(data)), 
        raw_data(err_buf), libc.uint32_t(len(err_buf))
    )
    if mod == nil {
        err = .ModuleLoadFailed
        return
    }
    // defer plibiwasm.wasm_runtime_unload(mod)

    runtime_mod._inst = plibiwasm.wasm_runtime_instantiate(
        mod, 
        stack_size, default_heap_size, 
        raw_data(err_buf), libc.uint32_t(len(err_buf))
    )
    if runtime_mod._inst == nil {
        err = .InstanceLoadFailed
        return
    }
    // defer plibiwasm.wasm_runtime_deinstantiate(inst._inst)

    runtime_mod._exec_env = plibiwasm.wasm_runtime_create_exec_env(runtime_mod._inst, stack_size)
    if runtime_mod._exec_env == nil {
        err = .ExecEnvCreationFailed
        return
    }
    // defer plibiwasm.wasm_runtime_destroy_exec_env(exec_env)

    return
}