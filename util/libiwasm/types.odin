package libiwasm

import "core:c/libc"

wasm_engine_t :: struct{}

wasm_store_t :: struct{}

mem_alloc_type_t :: enum {
    /* pool mode, allocate memory from user defined heap buffer */
    Alloc_With_Pool,
    /* user allocator mode, allocate memory from user defined
       malloc function */
    Alloc_With_Allocator,
    /* system allocator mode, allocate memory from system allocator,
       or, platform's os_malloc function */
    Alloc_With_System_Allocator
}

/* Memory allocator option */
MemAllocOption :: struct #raw_union {
   pool: struct {
      heap_buf: rawptr,
      heap_size: libc.uint32_t
   },
   allocator: struct {
      malloc_func: rawptr,
      realloc_func: rawptr,
      free_func: rawptr,
      /* allocator user data, only used when
          WASM_MEM_ALLOC_WITH_USER_DATA is defined */
      user_data: rawptr
   }
}

/* Runtime configuration */
wasm_config_t :: struct {
   mem_alloc_type: mem_alloc_type_t,
   mem_alloc_option: MemAllocOption,
   segue_flags: libc.uint32_t,
   enable_linux_perf: libc.bool
}

InstantiationArgs :: struct {
   default_stack_size: libc.uint32_t,
   host_managed_heap_size: libc.uint32_t,
   max_memory_pages: libc.uint32_t
}

wasm_mutability_t :: libc.uint8_t

wasm_mutablity_enum :: enum {
   WASM_CONST,
   WASM_VAR
}

wasm_limits_t :: struct {
   min: libc.uint32_t,
   max: libc.uint32_t
}

wasm_limits_max_default : libc.uint32_t : 0xffffffff

wasm_valtype_t :: struct{}

wasm_byte_t :: byte

wasm_valtype_vec_t :: wasm_VEC(wasm_valtype_t)

wasm_VEC :: struct($T: typeid) {
   size: libc.size_t,
   data: [^]T,
   num_elems: libc.size_t,
   size_of_elem: libc.size_t,
   lock: rawptr
}

wasm_name_t :: wasm_VEC(wasm_byte_t)

wasm_valkind_t :: enum u8 {
   WASM_I32,
   WASM_I64,
   WASM_F32,
   WASM_F64,
   WASM_V128,
   WASM_EXTERNREF = 128,
   WASM_FUNCREF
}

wasm_functype_t :: struct{}

wasm_functype_vec_t :: wasm_VEC(wasm_functype_t)

wasm_globaltype_t :: struct{}

wasm_globaltype_vec_t :: wasm_VEC(wasm_globaltype_t)