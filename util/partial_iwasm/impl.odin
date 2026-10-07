package partial_iwasm

when ODIN_OS == .Windows do foreign import lib "../../.out/WAMR/lib/iwasm.lib"
when ODIN_OS == .Linux   do foreign import lib "../../.out/WAMR/lib/libiwasm.a"