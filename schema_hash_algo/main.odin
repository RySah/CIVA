package schema_hash_algo

import "core:os"
import "core:fmt"

main :: proc() {
    for arg in os.args {
        fmt.printfln("%s", arg)
    }
}