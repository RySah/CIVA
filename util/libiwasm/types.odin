package libiwasm

import "core:c/libc"


Mem_Alloc_Type :: enum {
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
Mem_Alloc_Option :: struct #raw_union {
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
Config :: struct {
   mem_alloc_type: Mem_Alloc_Type,
   mem_alloc_option: Mem_Alloc_Option,
   segue_flags: libc.uint32_t,
   enable_linux_perf: libc.bool
}

Instantiation_Args :: struct {
   default_stack_size: libc.uint32_t,
   host_managed_heap_size: libc.uint32_t,
   max_memory_pages: libc.uint32_t
}

Mutability :: enum {
   CONST,
   VAR
}

Limits :: struct {
   min: libc.uint32_t,
   max: libc.uint32_t
}

LIMITS_MAX_DEFAULT : libc.uint32_t : 0xffffffff
VEC_DECL :: struct($T: typeid) {
   size: libc.size_t,
   data: [^]T,
   num_elems: libc.size_t,
   size_of_elem: libc.size_t,
   lock: rawptr
}

Val_Kind :: enum libc.uint8_t {
   I32,
   I64,
   F32,
   F64,
   V128,
   EXTERNREF = 128,
   FUNCREF
}

Module :: distinct rawptr

Module_Inst :: distinct rawptr

Function_Inst :: distinct rawptr

Exec_Env :: distinct rawptr

Load_Args :: struct {
   name: cstring,
   /* This option is only used by the Wasm C API (see wasm_c_api.h) */
   clone_wasm_binary: libc.bool,
   /* False by default, used by AOT/wasm loader only.
    If true, the AOT/wasm loader creates a copy of some module fields (e.g.
    const strings), making it possible to free the wasm binary buffer after
    loading. */
   wasm_binary_freeable: libc.bool,

   /* false by default, if true, don't resolve the symbols yet. The
    wasm_runtime_load_ex has to be followed by a wasm_runtime_resolve_symbols
    call */
    no_resolve: libc.bool
}

Ref_Kind :: enum {
   FOREIGN,
   FUNC,
   GLOBAL,
   MEMORY,
   TABLE
}

Host_Info :: struct {
   info: rawptr,
   finalizer: #type proc "c" (rawptr)
}

Ref :: struct {
   store: rawptr,
   kind: Ref_Kind,
   host_info: Host_Info,
   ref_idx_rt: libc.uint32_t,
   inst_comm_rt: rawptr
}

Val :: struct {
   kind: Val_Kind,
   _paddings: [7]libc.uint8_t,
   of: struct #raw_union {
      /* also represent a function index */
      I32: libc.int32_t,
      I64: libc.int64_t,
      F32: libc.float,
      F64: libc.double,
      foreign_: uintptr,
      ref: ^Ref
   }
}

#assert(size_of(Val_Kind) == 1)
#assert(size_of(Val) == 16)
#assert(align_of(Val) == align_of(libc.uint64_t))
#assert(offset_of(Val, of) == 8)