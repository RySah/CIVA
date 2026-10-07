package civa_vm

import "core:mem"
import "core:slice"

import "base:intrinsics"

Stack :: struct {
    data: []u8,
    offset: int
}

stack_len :: #force_inline proc "contextless" (self: ^Stack) -> int {
    return len(self.data)
}

stack_init_buf :: proc "contextless" (self: ^Stack, buf: []u8) {
    self^ = {}
    self.data = buf
    
}

stack_init :: proc(self: ^Stack, #any_int size: int, allocator := context.allocator) -> (buf: []u8, err: mem.Allocator_Error) #optional_allocator_error {
    buf = make([]u8, size, allocator=allocator) or_return
    stack_init_buf(self, buf)
    return
}

stack_push_bytes :: #force_inline proc "contextless" (self: ^Stack, b: []byte, non_overlapping := true) {
    if non_overlapping {
        mem.copy_non_overlapping(raw_data(self.data[:self.offset]), raw_data(b), len(b))
    }
    else {
        mem.copy(raw_data(self.data[:self.offset]), raw_data(b), len(b))
    }
    when !ODIN_NO_BOUNDS_CHECK {
        assert_contextless(self.offset + len(b) < stack_len(self))
    }
    self.offset += len(b)
    
}

stack_push :: #force_inline proc "contextless" (self: ^Stack, data: $T, non_overlapping := true) {
    when T == []byte { //TODO: Use intrinsics to better check if we can easily simply push it as bytes
        stack_push_bytes(self, data, non_overlapping=non_overlapping)
    }
    else {
        stack_push_bytes(self, mem.any_to_bytes(data), non_overlapping=non_overlapping)
    }
}

stack_pop_bytes :: proc "contextless" (self: ^Stack, #any_int size: int) -> []u8 {
    when !ODIN_NO_TYPE_ASSERT {
        assert_contextless(self.offset > size && self.offset - size > 0)
    }
    self.offset -= size
    return self.data[self.offset:size]
}

stack_pop :: proc "contextless" (self: ^Stack, $T: typeid, #any_int count: int = 1) -> [^]T {
    return transmute([^]T)(raw_data(stack_pop_bytes(self, size_of(T) * count)))
}

stack_peek_bytes :: proc "contextless" (self: ^Stack, #any_int size: int) -> []u8 {
    when !ODIN_NO_TYPE_ASSERT {
        assert_contextless(self.offset > size && self.offset - size > 0)
    }
    return self.data[self.offset-size:size]
}

stack_peek :: proc "contextless" (self: ^Stack, $T: typeid, #any_int count: int = 1) -> [^]T {
    raw := stack_peek_bytes(self, size_of(T) * count)
    return transmute([^]T)(raw_data(raw))
}
