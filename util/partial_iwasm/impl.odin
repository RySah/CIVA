package partial_iwasm

when ODIN_OS == .Windows do foreign import lib "../../.out/WAMR/lib/iwasm.lib"
else                     do foreign import lib "../../.out/WAMR/lib/libiwasm.a"
