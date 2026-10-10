package libcef

import "core:c"
import "core:mem"
import "core:sync"

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

	cef_run_message_loop :: proc "c" () ---

	cef_quit_message_loop :: proc "c" () ---

	cef_shutdown :: proc "c" () ---

	cef_browser_host_create_browser :: proc "c" (
		window_info: ^Cef_Window_Info,
		client: ^Cef_Client,
		url: ^Cef_String,
		settings: ^Cef_Browser_Settings,
		extra_info: ^Cef_Dictionary_Value,
		request_context: ^Cef_Request_Context,
	) -> c.int ---

	cef_browser_host_create_browser_sync :: proc "c" (
		window_info: ^Cef_Window_Info,
		client: ^Cef_Client,
		url: ^Cef_String,
		settings: ^Cef_Browser_Settings,
		extra_info: ^Cef_Dictionary_Value,
		request_context: ^Cef_Request_Context,
	) -> ^Cef_Browser ---

	cef_string_utf16_set :: proc "c" (
		src: [^]u16,
		src_len: c.size_t,
		output: ^Cef_String,
		copy: c.int,
	) -> c.int ---

	cef_string_utf16_clear :: proc "c" (str: ^Cef_String) ---

	cef_string_utf8_to_utf16 :: proc "c" (
		src: [^]u8,
		src_len: c.size_t,
		output: ^Cef_String,
	) -> c.int ---

	cef_string_utf16_to_utf8 :: proc "c" (
		src: [^]u16,
		src_len: c.size_t,
		output: ^Cef_String_UTF8,
	) -> c.int ---

	cef_string_utf8_clear :: proc "c" (str: ^Cef_String_UTF8) ---

	cef_string_userfree_utf16_free :: proc "c" (str: Cef_String_Userfree) ---
}

cef_settings_init :: proc() -> Cef_Settings {
	result: Cef_Settings
	result.size = c.size_t(size_of(Cef_Settings))
	return result
}

cef_browser_settings_init :: proc() -> Cef_Browser_Settings {
	result: Cef_Browser_Settings
	result.size = c.size_t(size_of(Cef_Browser_Settings))
	return result
}

cef_window_info_init :: proc() -> Cef_Window_Info {
	result: Cef_Window_Info
	result.size = c.size_t(size_of(Cef_Window_Info))
	return result
}

cef_screen_info_init :: proc() -> Cef_Screen_Info {
	result: Cef_Screen_Info
	result.size = c.size_t(size_of(Cef_Screen_Info))
	return result
}

cef_key_event_init :: proc() -> Cef_Key_Event {
	result: Cef_Key_Event
	result.size = c.size_t(size_of(Cef_Key_Event))
	return result
}

cef_accelerated_paint_info_init :: proc() -> Cef_Accelerated_Paint_Info {
	result: Cef_Accelerated_Paint_Info
	result.size = c.size_t(size_of(Cef_Accelerated_Paint_Info))
	return result
}

cef_base_ref_counted_init :: proc(
	base: ^Cef_Base_Ref_Counted,
	add_ref: Cef_Base_Add_Ref_Proc,
	release: Cef_Base_Ref_Result_Proc,
	has_one_ref: Cef_Base_Ref_Result_Proc,
	has_at_least_one_ref: Cef_Base_Ref_Result_Proc,
) {
	base^ = Cef_Base_Ref_Counted{
		size                 = c.size_t(size_of(Cef_Base_Ref_Counted)),
		add_ref              = add_ref,
		release              = release,
		has_one_ref          = has_one_ref,
		has_at_least_one_ref = has_at_least_one_ref,
	}
}

cef_callback_ref_count_init :: proc(count: ^Cef_Callback_Ref_Count) {
	sync.atomic_store(&count.value, 1)
}

cef_callback_ref_count_add_ref :: proc(count: ^Cef_Callback_Ref_Count) {
	sync.atomic_add(&count.value, 1)
}

cef_callback_ref_count_release :: proc(count: ^Cef_Callback_Ref_Count) -> c.int {
	return c.int(sync.atomic_sub(&count.value, 1) == 1)
}

cef_callback_ref_count_has_one_ref :: proc(count: ^Cef_Callback_Ref_Count) -> c.int {
	return c.int(sync.atomic_load(&count.value) == 1)
}

cef_callback_ref_count_has_at_least_one_ref :: proc(count: ^Cef_Callback_Ref_Count) -> c.int {
	return c.int(sync.atomic_load(&count.value) > 0)
}

cef_string_from_string :: proc(value: string) -> (result: Cef_String, ok: bool) {
	ok = cef_string_utf8_to_utf16(raw_data(value), c.size_t(len(value)), &result) != 0
	if !ok {
		cef_string_utf16_clear(&result)
	}
	return
}

cef_string_destroy :: proc(value: ^Cef_String) {
	cef_string_utf16_clear(value)
}

cef_string_to_string :: proc(
	value: ^Cef_String,
	allocator: mem.Allocator,
) -> (result: string, storage: []u8, ok: bool) {
	if value == nil {
		return
	}

	utf8: Cef_String_UTF8
	if cef_string_utf16_to_utf8(value.str, value.length, &utf8) == 0 {
		cef_string_utf8_clear(&utf8)
		return
	}
	defer cef_string_utf8_clear(&utf8)

	if utf8.length == 0 {
		ok = true
		return
	}

	buffer, alloc_error := mem.alloc(int(utf8.length), allocator = allocator)
	if alloc_error != .None {
		return
	}

	storage = ([^]u8)(buffer)[:int(utf8.length)]
	copy(storage, utf8.str[:int(utf8.length)])
	result = string(storage)
	ok = true
	return
}

cef_userfree_string_to_string :: proc(
	value: Cef_String_Userfree,
	allocator: mem.Allocator,
) -> (result: string, storage: []u8, ok: bool) {
	if value == nil {
		return
	}
	result, storage, ok = cef_string_to_string(value, allocator)
	cef_string_userfree_utf16_free(value)
	return
}

cef_frame_load_url_string :: proc(frame: ^Cef_Frame, url: string) -> bool {
	if frame == nil || frame.load_url == nil {
		return false
	}
	cef_url, ok := cef_string_from_string(url)
	if !ok {
		return false
	}
	defer cef_string_destroy(&cef_url)
	frame.load_url(frame, &cef_url)
	return true
}

cef_frame_load_html :: proc(
	frame: ^Cef_Frame,
	html: string,
	allocator := context.allocator,
) -> (ok: bool, err: mem.Allocator_Error) #optional_allocator_error {
	if frame == nil || frame.load_url == nil {
		return false, .None
	}

	prefix := "data:text/html;charset=utf-8,"
	max_int := int(~uintptr(0) >> 1)
	encoded_length := len(prefix)
	for byte in raw_data(html)[:len(html)] {
		increment := 3
		if (byte >= 0x41 && byte <= 0x5a) ||
		   (byte >= 0x61 && byte <= 0x7a) ||
		   (byte >= 0x30 && byte <= 0x39) ||
		   byte == 0x2d || byte == 0x2e || byte == 0x5f || byte == 0x7e {
			increment = 1
		}
		if encoded_length > max_int-increment {
			return false, .None
		}
		encoded_length += increment
	}

	url_buffer := make([]u8, encoded_length, allocator=allocator) or_return
	defer delete(url_buffer, allocator)
	copy(url_buffer[:len(prefix)], raw_data(prefix)[:len(prefix)])

	hex_digits := "0123456789ABCDEF"
	write_index := len(prefix)
	for byte in raw_data(html)[:len(html)] {
		if (byte >= 0x41 && byte <= 0x5a) ||
		   (byte >= 0x61 && byte <= 0x7a) ||
		   (byte >= 0x30 && byte <= 0x39) ||
		   byte == 0x2d || byte == 0x2e || byte == 0x5f || byte == 0x7e {
			url_buffer[write_index] = byte
			write_index += 1
		} else {
			url_buffer[write_index] = 0x25
			url_buffer[write_index+1] = hex_digits[int(byte>>4)]
			url_buffer[write_index+2] = hex_digits[int(byte&0x0f)]
			write_index += 3
		}
	}

	cef_url, converted := cef_string_from_string(string(url_buffer))
	if !converted {
		return false, .None
	}
	defer cef_string_destroy(&cef_url)
	frame.load_url(frame, &cef_url)
	return true, .None
}

cef_frame_execute_java_script_string :: proc(frame: ^Cef_Frame, code: string) -> bool {
	if frame == nil || frame.execute_java_script == nil {
		return false
	}
	cef_code, ok := cef_string_from_string(code)
	if !ok {
		return false
	}
	defer cef_string_destroy(&cef_code)
	frame.execute_java_script(frame, &cef_code, nil, 0)
	return true
}
