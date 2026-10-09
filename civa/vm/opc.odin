package civa_vm

/*
[NAME][BIT CONSUMPTION]_[BIT PRODUCTION]_[SPECIAL]

SPECIAL:
- RR = Rolling Register, will place the data in any available register
- SDR = Source Or Destination Register, expects the register index in the stack
- ERRO255 = Error On 255, will push a result, if the result is 255 a error occured

Examples:
- POP8_8_RR_ERRO255, Will pop 1 byte off of the stack (consumes 8 bits), and pushes the register its assigned to as a byte (produces 8 bits)
*/
OpCode :: enum u8 {
    POP8_8_RR_ERRO255 = 0,
    POP16_8_RR_ERRO255 = 1,
    POP32_8_RR_ERRO255 = 2,
    POP64_8_RR_ERRO255 = 3,

    PUSH8_8_SDR = 4,
    PUSH8_16_SDR = 5,
    PUSH8_32_SDR = 6,
    PUSH8_64_SDR = 7,

    ADD8_8 = 8, ADD16_16 = 9, ADD32_32 = 10, ADD64_64 = 11,
    SUB8_8 = 12, SUB16_16 = 13, SUB32_32 = 14, SUB64_64 = 15,
    MUL8_8 = 16, MUL16_16 = 17, MUL32_32 = 18, MUL64_64 = 19,
    DIV8_8 = 20, DIV16_16 = 21, DIV32_32 = 22, DIV64_64 = 23,

    SADD8_8 = 24, SADD16_16 = 25, SADD32_32 = 26, SADD64_64 = 27,
    SSUB8_8 = 28, SSUB16_16 = 29, SSUB32_32 = 30, SSUB64_64 = 31,
    SMUL8_8 = 32, SMUL16_16 = 33, SMUL32_32 = 34, SMUL64_64 = 35,
    SDIV8_8 = 36, SDIV16_16 = 37, SDIV32_32 = 38, SDIV64_64 = 39,
    
    EXIT32_0 = 40,

    JMP64_0 = 41,
    JMP32_0 = 42,

}

