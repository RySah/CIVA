package cli

import "core:strings"
import "core:mem"
import "core:fmt"
import "core:os"

Error :: union #shared_nil {
    mem.Allocator_Error,
    os.Error
}

Command_List :: struct {
    _buf: [dynamic]string,
    _intern: strings.Intern,
    _env: map[string]string
}

make_command_list :: proc(allocator := context.allocator) -> (cl: Command_List, err: mem.Allocator_Error) #optional_allocator_error {
    cl._buf = make([dynamic]string, allocator=allocator) or_return
    strings.intern_init(&cl._intern, allocator=allocator, map_allocator=allocator) or_return
    cl._env = make(map[string]string, allocator=allocator)
    return
}

delete_command_list :: proc(self: ^Command_List) {
    delete(self._buf)
    delete(self._env)
    strings.intern_destroy(&self._intern)
}

command_list_append :: proc(self: ^Command_List, args: ..string) -> (err: mem.Allocator_Error) {
    for arg in args {
        append(&self._buf, strings.intern_get(&self._intern, arg) or_return) or_return
    }
    return
}

command_list_env_add_str :: proc(self: ^Command_List, name: string, value: string) -> (err: mem.Allocator_Error) {
    self._env[strings.intern_get(&self._intern, name) or_return] = strings.intern_get(&self._intern, value) or_return
    return
}

command_list_env_add_any :: proc(self: ^Command_List, name: string, value: any) -> (err: mem.Allocator_Error) {
    value_str := fmt.aprintf("%v", value)
    defer delete(value_str)
    return command_list_env_add_str(self, name, value_str)
}

command_list_env_add :: proc{
    command_list_env_add_str,
    command_list_env_add_any
}

get_process_desc_from_command_list :: proc(
    pdesc: ^os.Process_Desc, 
    cl: ^Command_List, 
    env_buf: ^[dynamic]string = nil,
    stderr: ^os.File = nil,
    stdout: ^os.File = nil,
    stdin: ^os.File = nil
) -> (err: mem.Allocator_Error) {
    pdesc^ = {}

    pdesc.command = cl._buf[:]
    if env_buf != nil {
        for name, v in cl._env {
            owned_kvp := fmt.aprintf("%s=%s", name, v)
            defer delete(owned_kvp)
            append(env_buf, strings.intern_get(&cl._intern, owned_kvp) or_return) or_return
        }
        if len(env_buf) > 0 {
            pdesc.env = env_buf^[:]
        }
    }
    pdesc.stderr = stderr
    pdesc.stdout = stdout
    pdesc.stdin = stdin
    return
}

command_list_exec :: proc(
    self: ^Command_List,
    allocator := context.allocator
) -> (pstate: os.Process_State, stdout, stderr: []byte, err: Error) {
    pdesc: os.Process_Desc = ---
    env := make([dynamic]string) or_return
    defer delete(env)
    get_process_desc_from_command_list(&pdesc, self, &env, stderr=nil, stdout=nil, stdin=nil) or_return
    pstate, stdout, stderr = os.process_exec(pdesc, allocator) or_return
    return
}
