package libiwasm

when ODIN_OS == .Windows do foreign import lib "../../.out/WAMR/lib/iwasm.lib"
else                     do foreign import lib "../../.out/WAMR/lib/libiwasm.a"

import "core:c/libc"

foreign lib {
    /**
     * Initialize the WASM runtime environment, and also initialize
     * the memory allocator with system allocator, which calls os_malloc
     * to allocate memory
     *
     * @return true if success, false otherwise
     */
    wasm_runtime_init :: proc "c" () -> libc.bool ---

    /**
     * Destroy the WASM runtime environment.
     */
    wasm_runtime_destroy :: proc "c" () ---

    /**
     * Load a WASM module from a specified byte buffer. The byte buffer can be
     * WASM binary data when interpreter or JIT is enabled, or AOT binary data
     * when AOT is enabled. If it is AOT binary data, it must be 4-byte aligned.
     *
     * Note: In case of AOT XIP modules, the runtime doesn't make modifications
     * to the buffer. (Except the "Known issues" mentioned in doc/xip.md.)
     * Otherwise, the runtime can make modifications to the buffer for its
     * internal purposes. Thus, in general, it isn't safe to create multiple
     * modules from a single buffer.
     *
     * @param buf the byte buffer which contains the WASM/AOT binary data,
     *        note that the byte buffer must be writable since runtime may
     *        change its content for footprint and performance purpose, and
     *        it must be referenceable until wasm_runtime_unload is called
     * @param size the size of the buffer
     * @param error_buf output of the exception info
     * @param error_buf_size the size of the exception string
     *
     * @return return WASM module loaded, NULL if failed
     */
    wasm_runtime_load :: proc "c" (
        buf: [^]libc.uint8_t, size: libc.uint32_t, 
        error_buf: [^]libc.char, error_buf_size: libc.uint32_t
    ) -> Module ---

    /**
     * Load a WASM module with specified load argument.
     */
    wasm_runtime_load_ex :: proc "c" (
        buf: [^]libc.uint8_t, size: libc.uint32_t,
        args: ^Load_Args,
        error_buf: [^]libc.char, error_buf_size: libc.uint32_t
    ) -> Module ---

    /**
     * Resolve symbols for a previously loaded WASM module. Only useful when the
     * module was loaded with LoadArgs::no_resolve set to true
     */
    wasm_runtime_resolve_symbols :: proc "c" (module: Module) -> libc.bool ---

    /**
     * Unload a WASM module.
     *
     * @param module the module to be unloaded
     */
    wasm_runtime_unload :: proc "c" (module: Module) ---

    /**
     * Instantiate a WASM module.
     *
     * @param module the WASM module to instantiate
     * @param default_stack_size the default stack size of the module instance when
     *        the exec env's operation stack isn't created by user, e.g. API
     *        wasm_application_execute_main() and wasm_application_execute_func()
     *        create the operation stack internally with the stack size specified
     *        here. And API wasm_runtime_create_exec_env() creates the operation
     *        stack with stack size specified by its parameter, the stack size
     *        specified here is ignored.
     * @param host_managed_heap_size the default heap size of the module instance,
     *        a heap will be created besides the app memory space. Both wasm app
     *        and native function can allocate memory from the heap.
     * @param error_buf buffer to output the error info if failed
     * @param error_buf_size the size of the error buffer
     *
     * @return return the instantiated WASM module instance, NULL if failed
     */
    wasm_runtime_instantiate :: proc "c" (
        module: Module, 
        default_stack_size, host_managed_heap_size: libc.uint32_t, 
        error_buf: [^]libc.char, error_buf_size: libc.uint32_t
    ) -> Module_Inst ---

    /**
     * Deinstantiate a WASM module instance, destroy the resources.
     *
     * @param module_inst the WASM module instance to destroy
     */
    wasm_runtime_deinstantiate :: proc "c" (module_inst: Module_Inst) ---

    /**
     * Create execution environment for a WASM module instance.
     *
     * @param module_inst the module instance
     * @param stack_size the stack size to execute a WASM function
     *
     * @return the execution environment, NULL if failed, e.g. invalid
     *         stack size is passed
     */
    wasm_runtime_create_exec_env :: proc "c" (module_inst: Module_Inst, stack_size: libc.uint32_t) -> Exec_Env ---

    /**
     * Destroy the execution environment.
     *
     * @param exec_env the execution environment to destroy
     */
    wasm_runtime_destroy_exec_env :: proc "c" (exec_env: Exec_Env) ---

    /**
     * Get WASM module from WASM module instance
     *
     * @param module_inst the WASM module instance to retrieve
     *
     * @return the WASM module
     */
    wasm_runtime_get_module :: proc "c" (module_inst: Module_Inst) -> Module ---

    /**
     * Lookup an exported function in the WASM module instance.
     *
     * @param module_inst the module instance
     * @param name the name of the function
     *
     * @return the function instance found, NULL if not found
     */
    wasm_runtime_lookup_function :: proc "c" (module_inst: Module_Inst, name: cstring) -> Function_Inst ---

    /**
     * Get parameter count of the function instance
     *
     * @param func_inst the function instance
     * @param module_inst the module instance the function instance belongs to
     *
     * @return the parameter count of the function instance
     */
    wasm_func_get_param_count :: proc "c" (func_inst: Function_Inst, module_inst: Module_Inst) -> libc.uint32_t ---

    /**
     * Get result count of the function instance
     *
     * @param func_inst the function instance
     * @param module_inst the module instance the function instance belongs to
     *
     * @return the result count of the function instance
     */
    wasm_func_get_result_count :: proc "c" (func_inst: Function_Inst, module_inst: Module_Inst) -> libc.uint32_t ---
    
    /**
     * Get parameter types of the function instance
     *
     * @param func_inst the function instance
     * @param module_inst the module instance the function instance belongs to
     * @param param_types the parameter types returned
     */
    wasm_func_get_param_types :: proc "c" (func_inst: Function_Inst, module_inst: Module_Inst, param_types: [^]Val_Kind) ---

    /**
     * Get result types of the function instance
     *
     * @param func_inst the function instance
     * @param module_inst the module instance the function instance belongs to
     * @param result_types the result types returned
     */
    wasm_func_get_result_types :: proc "c" (func_inst: Function_Inst, module_inst: Module_Inst, result_types: [^]Val_Kind) ---

    /**
     * Call the given WASM function of a WASM module instance with
     * arguments (bytecode and AoT).
     *
     * @param exec_env the execution environment to call the function,
     *   which must be created from wasm_create_exec_env()
     * @param function the function to call
     * @param argc total cell number that the function parameters occupy,
     *   a cell is a slot of the uint32 array argv[], e.g. i32/f32 argument
     *   occupies one cell, i64/f64 argument occupies two cells, note that
     *   it might be different from the parameter number of the function
     * @param argv the arguments. If the function has return value,
     *   the first (or first two in case 64-bit return value) element of
     *   argv stores the return value of the called WASM function after this
     *   function returns.
     *
     * @return true if success, false otherwise and exception will be thrown,
     *   the caller can call wasm_runtime_get_exception to get the exception
     *   info.
     */
    wasm_runtime_call_wasm :: proc "c" (exec_env: Exec_Env, function: Function_Inst, argc: libc.uint32_t, argv: [^]libc.uint32_t) -> libc.bool ---

    /**
     * Call the given WASM function of a WASM module instance with
     * provided results space and arguments (bytecode and AoT).
     *
     * @param exec_env the execution environment to call the function,
     *   which must be created from wasm_create_exec_env()
     * @param function the function to call
     * @param num_results the number of results
     * @param results the pre-alloced pointer to get the results
     * @param num_args the number of arguments
     * @param args the arguments
     *
     * @return true if success, false otherwise and exception will be thrown,
     *   the caller can call wasm_runtime_get_exception to get the exception
     *   info.
     */
    wasm_runtime_call_wasm_a :: proc "c" (exec_env: Exec_Env, function: Function_Inst, num_results: libc.uint32_t, results: [^]Val, num_args: libc.uint32_t, args: [^]Val) -> libc.bool --- 

    /**
     * Get exception info of the WASM module instance.
     *
     * @param module_inst the WASM module instance
     *
     * @return the exception string
     */
    wasm_runtime_get_exception :: proc "c" (module_inst: Module_Inst) -> cstring ---

    /**
     * Initialize the thread environment.
     * Note:
     *   If developer creates a child thread by himself to call the
     *   the wasm function in that thread, he should call this API
     *   firstly before calling the wasm function and then call
     *   wasm_runtime_destroy_thread_env() after calling the wasm
     *   function. If the thread is created from the runtime API,
     *   it is unnecessary to call these two APIs.
     *
     * @return true if success, false otherwise
     */
    wasm_runtime_init_thread_env :: proc "c" () -> libc.bool ---

    /**
     * Destroy the thread environment
     */
    wasm_runtime_destroy_thread_env :: proc "c" () ---

    /**
     * Whether the thread environment is initialized
     */
    wasm_runtime_thread_env_inited :: proc "c" () -> libc.bool ---
}
