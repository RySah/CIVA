package civa_vm

import "core:math/bits"
import "core:os"

// 8 Registers Max
State_Register_Table_Usage :: bit_field u8 {
    R0: bool | 1,
    R1: bool | 1,
    R2: bool | 1,
    R3: bool | 1,
    R4: bool | 1,
    R5: bool | 1,
    R6: bool | 1,
    R7: bool | 1
}

State_Register_Table :: struct {
    buf: [^]Reg,
    in_use: State_Register_Table_Usage
}

State :: struct {
    running: bool,
    exit_code: i32,
    pc: u64,
    stack: ^Stack,
    reg_tbl: State_Register_Table
}

state_init :: proc "contextless" (self: ^State, 
    reg_tbl_buf: []Reg,
    stack: ^Stack
) {
    assert_contextless(len(reg_tbl_buf) >= 8)

    self^ = {}

    self.running = true

    self.stack = stack
    self.reg_tbl.buf = raw_data(reg_tbl_buf)
}

state_rt_roll_reg :: proc "contextless" (self: ^State_Register_Table) -> u8 {
    in_use_bm := transmute(u8)self.in_use
    free_bm := ~in_use_bm

    if free_bm == 0 {
        return 255
    }

    res_bit := free_bm & -free_bm
    idx := u8(bits.trailing_zeros(res_bit))

    self.in_use = transmute(State_Register_Table_Usage)(
        in_use_bm | res_bit
    )

    return idx
}

state_assign_8_roll_reg :: proc "contextless" (self: ^State, v: u8) -> (reg_idx: u8) {
    reg_idx = state_rt_roll_reg(&self.reg_tbl)
    self.reg_tbl.buf[reg_idx].B = v
    return
}

state_assign_16_roll_reg :: proc "contextless" (self: ^State, v: u16) -> (reg_idx: u8) {
    reg_idx = state_rt_roll_reg(&self.reg_tbl)
    self.reg_tbl.buf[reg_idx].W = v
    return
}

state_assign_32_roll_reg :: proc "contextless" (self: ^State, v: u32) -> (reg_idx: u8) {
    reg_idx = state_rt_roll_reg(&self.reg_tbl)
    self.reg_tbl.buf[reg_idx].DW = v
    return
}

state_assign_64_roll_reg :: proc "contextless" (self: ^State, v: u64) -> (reg_idx: u8) {
    reg_idx = state_rt_roll_reg(&self.reg_tbl)
    self.reg_tbl.buf[reg_idx].QW = v
    return
}

state_assign_roll_reg :: proc{
    state_assign_8_roll_reg,
    state_assign_16_roll_reg,
    state_assign_32_roll_reg,
    state_assign_64_roll_reg
}

state_opc_exec :: proc "contextless" (self: ^State, opc: OpCode) {


    POPX_8_RR_ERRO255 :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        v := stack_pop(self.stack, T)[0]
        assigned_reg_idx := state_assign_roll_reg(self, v)
        stack_push(self.stack, assigned_reg_idx, non_overlapping=true)
    }

    PUSH8_X_SR :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        reg_idx := stack_pop(self.stack, u8)[0]
        v := reg_get_for_T(&self.reg_tbl.buf[reg_idx], T)^
        self.reg_tbl.in_use = transmute(State_Register_Table_Usage)((transmute(u8)self.reg_tbl.in_use) & ~(u8(1) << reg_idx))
        stack_push(self.stack, v, non_overlapping=true)
    }

    XADDX_X :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        ab_ptr := stack_pop(self.stack, T, count=2)
        a := ab_ptr[0]
        b := ab_ptr[1]
        stack_push(self.stack, a + b, non_overlapping=true)
    }

    XSUBX_X :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        ab_ptr := stack_pop(self.stack, T, count=2)
        a := ab_ptr[0]
        b := ab_ptr[1]
        stack_push(self.stack, a - b, non_overlapping=true)
    }

    XMULX_X :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        ab_ptr := stack_pop(self.stack, T, count=2)
        a := ab_ptr[0]
        b := ab_ptr[1]
        stack_push(self.stack, a * b, non_overlapping=true)
    }

    XDIVX_X :: #force_inline proc "contextless" (self: ^State, $T: typeid) {
        ab_ptr := stack_pop(self.stack, T, count=2)
        a := ab_ptr[0]
        b := ab_ptr[1]
        stack_push(self.stack, a / b, non_overlapping=true)
    }

    switch opc {
        case .POP8_8_RR_ERRO255:
            POPX_8_RR_ERRO255(self, u8)
        case .POP16_8_RR_ERRO255:
            POPX_8_RR_ERRO255(self, u16)
        case .POP32_8_RR_ERRO255:
            POPX_8_RR_ERRO255(self, u32)
        case .POP64_8_RR_ERRO255:
            POPX_8_RR_ERRO255(self, u64)
        
        case .PUSH8_8_SDR:
            PUSH8_X_SR(self, u8)
        case .PUSH8_16_SDR:
            PUSH8_X_SR(self, u16)
        case .PUSH8_32_SDR:
            PUSH8_X_SR(self, u32)
        case .PUSH8_64_SDR:
            PUSH8_X_SR(self, u64)

        case .ADD8_8:
            XADDX_X(self, u8)
        case .ADD16_16:
            XADDX_X(self, u16)
        case .ADD32_32:
            XADDX_X(self, u32)
        case .ADD64_64:
            XADDX_X(self, u64)
        
        case .SUB8_8:
            XSUBX_X(self, u8)
        case .SUB16_16:
            XSUBX_X(self, u16)
        case .SUB32_32:
            XSUBX_X(self, u32)
        case .SUB64_64:
            XSUBX_X(self, u64)
        
        case .MUL8_8:
            XMULX_X(self, u8)
        case .MUL16_16:
            XMULX_X(self, u16)
        case .MUL32_32:
            XMULX_X(self, u32)
        case .MUL64_64:
            XMULX_X(self, u64)

        case .DIV8_8:
            XDIVX_X(self, u8)
        case .DIV16_16:
            XDIVX_X(self, u16)
        case .DIV32_32:
            XDIVX_X(self, u32)
        case .DIV64_64:
            XDIVX_X(self, u64)

        case .SADD8_8:
            XADDX_X(self, i8)
        case .SADD16_16:
            XADDX_X(self, i16)
        case .SADD32_32:
            XADDX_X(self, i32)
        case .SADD64_64:
            XADDX_X(self, i64)
        
        case .SSUB8_8:
            XSUBX_X(self, i8)
        case .SSUB16_16:
            XSUBX_X(self, i16)
        case .SSUB32_32:
            XSUBX_X(self, i32)
        case .SSUB64_64:
            XSUBX_X(self, i64)
        
        case .SMUL8_8:
            XMULX_X(self, i8)
        case .SMUL16_16:
            XMULX_X(self, i16)
        case .SMUL32_32:
            XMULX_X(self, i32)
        case .SMUL64_64:
            XMULX_X(self, i64)

        case .SDIV8_8:
            XDIVX_X(self, i8)
        case .SDIV16_16:
            XDIVX_X(self, i16)
        case .SDIV32_32:
            XDIVX_X(self, i32)
        case .SDIV64_64:
            XDIVX_X(self, i64)
        
        case .EXIT32_0:
            v := stack_pop(self.stack, i32)[0]
            self.running = false
            self.exit_code = v

        case .JMP64_0:
            v := stack_pop(self.stack, u64)[0]
            self.pc = v
    }
}