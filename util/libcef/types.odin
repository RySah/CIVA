package libcef

import "core:c"

Cef_State :: c.int
Cef_Log_Severity :: c.int
Cef_Log_Items :: c.int
Cef_Runtime_Style :: c.int
Cef_Paint_Element_Type :: enum c.int {
	View = 0,
	Popup = 1,
}

Cef_String :: struct {
	str: [^]u16,
	length: c.size_t,
	dtor: #type proc "c" (str: [^]u16),
}

Cef_Rect :: struct {
	x: c.int,
	y: c.int,
	width: c.int,
	height: c.int,
}

when ODIN_OS == .Windows {
	Cef_Base_Ref_Counted_Proc :: #type proc "stdcall" (self: rawptr) -> c.int
}
else {
	Cef_Base_Ref_Counted_Proc :: #type proc "c" (self: rawptr) -> c.int
}

Cef_Base_Ref_Counted :: struct {
	size: c.size_t,
	add_ref: Cef_Base_Ref_Counted_Proc,
	release: Cef_Base_Ref_Counted_Proc,
	has_one_ref: Cef_Base_Ref_Counted_Proc,
	has_at_least_one_ref: Cef_Base_Ref_Counted_Proc,
}

Cef_Main_Args :: struct {
	instance: rawptr,
}

Cef_Settings :: struct {
	size: c.size_t,

	no_sandbox: c.int,
	browser_subprocess_path: Cef_String,
	framework_dir_path: Cef_String,
	main_bundle_path: Cef_String,
	multi_threaded_message_loop: c.int,
	external_message_pump: c.int,
	windowless_rendering_enabled: c.int,
	command_line_args_disabled: c.int,
	cache_path: Cef_String,
	root_cache_path: Cef_String,
	persist_session_cookies: c.int,
	user_agent: Cef_String,
	user_agent_product: Cef_String,
	locale: Cef_String,
	log_file: Cef_String,
	log_severity: Cef_Log_Severity,
	log_items: Cef_Log_Items,
	javascript_flags: Cef_String,
	resources_dir_path: Cef_String,
	locales_dir_path: Cef_String,
	remote_debugging_port: c.int,
	uncaught_exception_stack_size: c.int,
	background_color: c.uint32_t,
	accept_language_list: Cef_String,
	cookieable_schemes_list: Cef_String,
	cookieable_schemes_exclude_defaults: c.int,
	chrome_policy_id: Cef_String,
	chrome_app_icon_id: c.int,
	disable_signal_handlers: c.int,
	use_views_default_popup: c.int,
}

Cef_Browser_Settings :: struct {
	size: c.size_t,
	windowless_frame_rate: c.int,

	standard_font_family: Cef_String,
	fixed_font_family: Cef_String,
	serif_font_family: Cef_String,
	sans_serif_font_family: Cef_String,
	cursive_font_family: Cef_String,
	fantasy_font_family: Cef_String,
	default_font_size: c.int,
	default_fixed_font_size: c.int,
	minimum_font_size: c.int,
	minimum_logical_font_size: c.int,
	default_encoding: Cef_String,

	remote_fonts: Cef_State,
	javascript: Cef_State,
	javascript_close_windows: Cef_State,
	javascript_access_clipboard: Cef_State,
	javascript_dom_paste: Cef_State,
	image_loading: Cef_State,
	image_shrink_standalone_to_fit: Cef_State,
	text_area_resize: Cef_State,
	tab_to_links: Cef_State,
	local_storage: Cef_State,
	databases_deprecated: Cef_State,
	webgl: Cef_State,
	background_color: c.uint32_t,
	chrome_status_bubble: Cef_State,
	chrome_zoom_bubble: Cef_State,
}

Cef_Window_Info :: struct {
	size: c.size_t,
	ex_style: c.uint32_t,
	window_name: Cef_String,
	style: c.uint32_t,
	bounds: Cef_Rect,
	parent_window: rawptr,
	menu: rawptr,
	windowless_rendering_enabled: c.int,
	shared_texture_enabled: c.int,
	external_begin_frame_enabled: c.int,
	window: rawptr,
	runtime_style: Cef_Runtime_Style,
}

Cef_App :: struct {
	base: Cef_Base_Ref_Counted,
}

when ODIN_OS == .Windows {
	Cef_Client_Get_Render_Handler_Proc :: #type proc "stdcall" (self: ^Cef_Client) -> ^Cef_Render_Handler
}
else {
	Cef_Client_Get_Render_Handler_Proc :: #type proc "c" (self: ^Cef_Client) -> ^Cef_Render_Handler
}

Cef_Client :: struct {
	base: Cef_Base_Ref_Counted,

	get_audio_handler: rawptr,
	get_command_handler: rawptr,
	get_context_menu_handler: rawptr,
	get_dialog_handler: rawptr,
	get_display_handler: rawptr,
	get_download_handler: rawptr,
	get_drag_handler: rawptr,
	get_find_handler: rawptr,
	get_focus_handler: rawptr,
	get_frame_handler: rawptr,
	get_permission_handler: rawptr,
	get_jsdialog_handler: rawptr,
	get_keyboard_handler: rawptr,
	get_life_span_handler: rawptr,
	get_load_handler: rawptr,
	get_print_handler: rawptr,
	get_render_handler: Cef_Client_Get_Render_Handler_Proc,
	get_request_handler: rawptr,
	on_process_message_received: rawptr,
}

Cef_Dictionary_Value :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Request_Context :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Browser :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Accelerated_Paint_Info :: struct {}

when ODIN_OS == .Windows {
	Cef_Render_Handler_Get_View_Rect_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
}
else {
	Cef_Render_Handler_Get_View_Rect_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
}

when ODIN_OS == .Windows {
	Cef_Render_Handler_On_Paint_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		buffer: rawptr,
		width: c.int,
		height: c.int,
	)
}
else {
	Cef_Render_Handler_On_Paint_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		buffer: rawptr,
		width: c.int,
		height: c.int,
	)
}

when ODIN_OS == .Windows {
	Cef_Render_Handler_On_Accelerated_Paint_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		info: ^Cef_Accelerated_Paint_Info,
	)
}
else {
	Cef_Render_Handler_On_Accelerated_Paint_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		info: ^Cef_Accelerated_Paint_Info,
	)
}

Cef_Render_Handler :: struct {
	base: Cef_Base_Ref_Counted,

	get_accessibility_handler: rawptr,
	get_root_screen_rect: rawptr,
	get_view_rect: Cef_Render_Handler_Get_View_Rect_Proc,
	get_screen_point: rawptr,
	get_screen_info: rawptr,
	on_popup_show: rawptr,
	on_popup_size: rawptr,
	on_paint: Cef_Render_Handler_On_Paint_Proc,
	on_accelerated_paint: Cef_Render_Handler_On_Accelerated_Paint_Proc,
	get_touch_handle_size: rawptr,
	on_touch_handle_state_changed: rawptr,
	start_dragging: rawptr,
	update_drag_cursor: rawptr,
	on_scroll_offset_changed: rawptr,
	on_ime_composition_range_changed: rawptr,
	on_text_selection_changed: rawptr,
	on_virtual_keyboard_requested: rawptr,
}
