package civa_vm

/* Given the constraints of WASM, u128 will not be supported in regards to the register. */
Reg :: struct #raw_union {
    B: u8,
    W: u16,
    DW: u32,
    QW: u64
}

#assert(size_of(Reg) == size_of(u64), "Registers is assumed to be 64 bits in size")

reg_get_for_T :: #force_inline proc "contextless" (self: ^Reg, $T: typeid) -> ^T {
    when size_of(T) == 1 {
        return transmute(^T)(&self.B)
    }
    else when size_of(T) == 2 {
        return transmute(^T)(&self.W)
    }
    else when size_of(T) == 4 {
        return transmute(^T)(&self.DW)
    }
    else when size_of(T) == 8 {
        return transmute(^T)(&self.QW)
    }
    else {
        #assert(size_of(T) <= 8)
    }
}