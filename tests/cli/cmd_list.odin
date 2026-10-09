package test_cli

import "core:testing"
import "core:os"

import cli "../../util/cli"

@(private="file") _make_command_list :: proc(t: ^testing.T) -> (cli.Command_List, bool) {
	cl, err := cli.make_command_list()
	if !testing.expect(t, err == .None) {
		return {}, false
	}
	return cl, true
}

@(test)
test_command_list_process_desc_preserves_arguments_and_environment :: proc(t: ^testing.T) {
	cl, ok := _make_command_list(t)
	if !ok do return
	defer cli.delete_command_list(&cl)

	err := cli.command_list_append(&cl, "compiler", "build", "input file")
	if !testing.expect(t, err == .None) do return
	err = cli.command_list_env_add(&cl, "MODE", "release")
	if !testing.expect(t, err == .None) do return
	err = cli.command_list_env_add(&cl, "JOBS", 4)
	if !testing.expect(t, err == .None) do return

	pdesc: os.Process_Desc
	env_buf: [dynamic]string
	defer delete(env_buf)
	if !testing.expect(t, cli.get_process_desc_from_command_list(&pdesc, &cl, &env_buf) == .None) do return

	if !testing.expect(t, len(pdesc.command) == 3) do return
	if !testing.expect(t, pdesc.command[0] == "compiler") do return
	if !testing.expect(t, pdesc.command[1] == "build") do return
	if !testing.expect(t, pdesc.command[2] == "input file") do return

	found_mode := false
	found_jobs := false
	for entry in env_buf {
		found_mode = found_mode || entry == "MODE=release"
		found_jobs = found_jobs || entry == "JOBS=4"
	}
	if !testing.expect(t, found_mode) do return
	if !testing.expect(t, found_jobs) do return
	if !testing.expect(t, len(pdesc.env) == len(env_buf)) do return
	for i in 0..<len(env_buf) {
		if !testing.expect(t, pdesc.env[i] == env_buf[i]) do return
	}
}

@(test)
test_command_list_environment_value_is_replaced :: proc(t: ^testing.T) {
	cl, ok := _make_command_list(t)
	if !ok do return
	defer cli.delete_command_list(&cl)

	err := cli.command_list_env_add(&cl, "MODE", "debug")
	if !testing.expect(t, err == .None) do return
	err = cli.command_list_env_add(&cl, "MODE", "release")
	if !testing.expect(t, err == .None) do return

	pdesc: os.Process_Desc
	env_buf: [dynamic]string
	defer delete(env_buf)
	if !testing.expect(t, cli.get_process_desc_from_command_list(&pdesc, &cl, &env_buf) == .None) do return

	if !testing.expect(t, len(env_buf) == 1) do return
	if !testing.expect(t, env_buf[0] == "MODE=release") do return
}

@(test)
test_command_list_exec_captures_child_output :: proc(t: ^testing.T) {
	cl, ok := _make_command_list(t)
	if !ok do return
	defer cli.delete_command_list(&cl)

	err := cli.command_list_append(&cl, "cmd.exe", "/C", "echo command-list-execution")
	if !testing.expect(t, err == .None) do return

	state, stdout, stderr, exec_err := cli.command_list_exec(&cl)
	defer delete(stdout)
	defer delete(stderr)

	if !testing.expect(t, exec_err == .None) do return
	if !testing.expect(t, state.exited) do return
	if !testing.expect(t, state.success) do return
	if !testing.expect(t, state.exit_code == 0) do return
	if !testing.expect(t, string(stdout) == "command-list-execution\r\n") do return
	if !testing.expect(t, len(stderr) == 0) do return
}
