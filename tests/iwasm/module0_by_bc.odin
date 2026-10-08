package test_iwasm

import "core:testing"

@(private="file") WASM_MODULE :: #load("../assets/test_module0.wasm")
@(private="file") DEFAULT_STACK_SIZE :: 1024
@(private="file") DEFAULT_HEAP_SIZE :: 1024

import qiwasm "../../util/quick_iwasm"

@(private="file") _test_setup_module :: proc(t: ^testing.T) -> Maybe(qiwasm.Runtime_Module) {
    err_buf: [256]u8 = {}
    mod, mod_err := qiwasm.get_runtime_module_from_buffer(WASM_MODULE, err_buf[:], DEFAULT_STACK_SIZE, DEFAULT_HEAP_SIZE)

    if !testing.expect(t, mod_err == .None, msg=string(cstring(raw_data(err_buf[:])))) {
        qiwasm.delete_runtime_module(&mod)
        return nil
    }

    return mod
}

@(private="file") _test_cleanup :: proc(t: ^testing.T, mod: ^qiwasm.Runtime_Module) {
    qiwasm.delete_runtime_module(mod)
}

@test test_mod0_answer_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)
    
    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "answer").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [0]qiwasm.Value = {}
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, results[0].of.I32 == 42) do return
}

@test test_mod0_double_i32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "double_i32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    param_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [1]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 24 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return

    if !testing.expect(t, results[0].of.I32 == 48) do return
}

@test test_mod0_add_i32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "add_i32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return
    if !testing.expect(t, param_types[1] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 24 }
    }
    args[1] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 6 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.I32 == 30) do return
}

@test test_mod0_multiply_add_i32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "multiply_add_i32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    param_types: [3]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return
    if !testing.expect(t, param_types[1] == .I32) do return
    if !testing.expect(t, param_types[2] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [3]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 10 }
    }
    args[1] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 20 }
    }
    args[2] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 2 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return
    if !testing.expect(t, args[2].kind == param_types[2]) do return

    if !testing.expect(t, results[0].of.I32 == 60) do return
}

@test test_mod0_add_i64_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "add_i64").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I64) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I64) do return
    if !testing.expect(t, param_types[1] == .I64) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I64,
        of = { I64 = 24 }
    }
    args[1] = qiwasm.Value{
        kind = .I64,
        of = { I64 = 6 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.I64 == 30) do return
}

@test test_mod0_add_f32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "add_f32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .F32) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .F32) do return
    if !testing.expect(t, param_types[1] == .F32) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .F32,
        of = { F32 = 1.50 }
    }
    args[1] = qiwasm.Value{
        kind = .F32,
        of = { F32 = 2.25 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.F32 == 3.75) do return
}

@test test_mod0_multiply_f64_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "multiply_f64").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .F64) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .F64) do return
    if !testing.expect(t, param_types[1] == .F64) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .F64,
        of = { F64 = 2.5 }
    }
    args[1] = qiwasm.Value{
        kind = .F64,
        of = { F64 = 4.0 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.F64 == 10.00) do return
}

@test test_mod0_greater_than_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "greater_than").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return
    if !testing.expect(t, param_types[1] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 20 }
    }
    args[1] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 10 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.I32 == 1) do return
}

@test test_mod0_max_i32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "max_i32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .I32) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return
    if !testing.expect(t, param_types[1] == .I32) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 10 }
    }
    args[1] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 20 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.I32 == 20) do return
}

@test test_mod0_scale_i32_by_bytecode :: proc(t: ^testing.T) {
    mod, mod_success := _test_setup_module(t).?
    if !testing.expect(t, mod_success) do return
    defer _test_cleanup(t, &mod)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&mod, "scale_i32").?
    if !testing.expect(t, found_func) do return

    result_types: [1]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_result_types(&mod, func, result_types[:])
    if !testing.expect(t, result_types[0] == .F32) do return

    param_types: [2]qiwasm.Value_Kind = {}
    qiwasm.runtime_module_function_get_param_types(&mod, func, param_types[:])
    if !testing.expect(t, param_types[0] == .I32) do return
    if !testing.expect(t, param_types[1] == .F32) do return

    results: [1]qiwasm.Value = {}
    args: [2]qiwasm.Value = {}
    args[0] = qiwasm.Value{
        kind = .I32,
        of = { I32 = 10 }
    }
    args[1] = qiwasm.Value{
        kind = .F32,
        of = { F32 = 2.5 }
    }
    if !testing.expect(t, qiwasm.runtime_module_function_call(&mod, func, results[:], args[:])) do return

    if !testing.expect(t, results[0].kind == result_types[0]) do return

    if !testing.expect(t, args[0].kind == param_types[0]) do return
    if !testing.expect(t, args[1].kind == param_types[1]) do return

    if !testing.expect(t, results[0].of.F32 == 25.0) do return
}

@test test_mod0_multiple_live_modules_by_bytecode :: proc(t: ^testing.T) {
    first, first_success := _test_setup_module(t).?
    if !testing.expect(t, first_success) do return
    defer _test_cleanup(t, &first)

    second, second_success := _test_setup_module(t).?
    if !testing.expect(t, second_success) do return
    defer _test_cleanup(t, &second)

    _test_cleanup(t, &first)

    func, found_func := qiwasm.runtime_module_lookup_function_cstr(&second, "answer").?
    if !testing.expect(t, found_func) do return

    results: [1]qiwasm.Value = {}
    args: [0]qiwasm.Value = {}
    if !testing.expect(t, qiwasm.runtime_module_function_call(&second, func, results[:], args[:])) do return
    if !testing.expect(t, results[0].of.I32 == 42) do return
}
