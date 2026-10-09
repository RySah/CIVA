package libcef

import "core:c"

when ODIN_OS == .Windows do foreign import lib "../../.out/cef/libcef.lib"

foreign lib {
	cef_execute_process :: proc "c" (
		args: ^Cef_Main_Args,
		application: ^Cef_App,
		windows_sandbox_info: rawptr,
	) -> c.int ---

	cef_initialize :: proc "c" (
		args: ^Cef_Main_Args,
		settings: ^Cef_Settings,
		application: ^Cef_App,
		windows_sandbox_info: rawptr,
	) -> c.int ---

	cef_do_message_loop_work :: proc "c" () ---

	cef_shutdown :: proc "c" () ---

	cef_browser_host_create_browser_sync :: proc "c" (
		window_info: ^Cef_Window_Info,
		client: ^Cef_Client,
		url: ^Cef_String,
		settings: ^Cef_Browser_Settings,
		extra_info: ^Cef_Dictionary_Value,
		request_context: ^Cef_Request_Context,
	) -> ^Cef_Browser ---
}
