package schema_hash_algo

import "core:crypto/sha2"

is_hardware_accelerated :: proc "contextless" () -> bool {
    return #force_inline sha2.is_hardware_accelerated_256()
}

DIGEST_SIZE :: sha2.DIGEST_SIZE_256

hash :: proc(data: []byte, out: []byte) {
    assert(len(out) >= DIGEST_SIZE)
    ctx: sha2.Context_256 = ---
    sha2.init_256(&ctx)
    sha2.update(&ctx, data)
    sha2.final(&ctx, out, finalize_clone=false)
    return
}
