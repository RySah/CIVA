package libcef

import "core:c"

Cef_State :: enum c.int {
	Default  = 0,
	Enabled  = 1,
	Disabled = 2,
}

Cef_Log_Severity :: enum c.int {
	Default  = 0,
	Verbose  = 1,
	Debug    = 1,
	Info     = 2,
	Warning  = 3,
	Error    = 4,
	Fatal    = 5,
	Disable  = 99,
}

Cef_Log_Items :: enum c.int {
	Default       = 0,
	None          = 1,
	Process_Id    = 1 << 1,
	Thread_Id     = 1 << 2,
	Time_Stamp    = 1 << 3,
	Tick_Count    = 1 << 4,
}

Cef_Runtime_Style :: enum c.int {
	Default = 0,
	Chrome  = 1,
	Alloy   = 2,
}

Cef_Window_Open_Disposition :: enum c.int {
	Unknown                       = 0,
	Current_Tab                   = 1,
	Singleton_Tab                 = 2,
	New_Foreground_Tab            = 3,
	New_Background_Tab            = 4,
	New_Popup                     = 5,
	New_Window                    = 6,
	Save_To_Disk                  = 7,
	Off_The_Record                = 8,
	Ignore_Action                 = 9,
	Switch_To_Tab                 = 10,
	New_Picture_In_Picture        = 11,
	New_Split_View                = 12,
}

Cef_Color_Type :: enum c.int {
	RGBA_8888  = 0,
	BGRA_8888  = 1,
	Num_Values = 2,
}

Cef_Paint_Element_Type :: enum c.int {
	View  = 0,
	Popup = 1,
}

Cef_Mouse_Button_Type :: enum c.int {
	Left   = 0,
	Middle = 1,
	Right  = 2,
}

Cef_Key_Event_Type :: enum c.int {
	Raw_Key_Down = 0,
	Key_Down     = 1,
	Key_Up       = 2,
	Char         = 3,
}

Cef_Event_Flags :: enum c.uint32_t {
	None                       = 0,
	Caps_Lock_On               = 1 << 0,
	Shift_Down                 = 1 << 1,
	Control_Down               = 1 << 2,
	Alt_Down                   = 1 << 3,
	Left_Mouse_Button          = 1 << 4,
	Middle_Mouse_Button        = 1 << 5,
	Right_Mouse_Button         = 1 << 6,
	Command_Down               = 1 << 7,
	Num_Lock_On                = 1 << 8,
	Is_Key_Pad                 = 1 << 9,
	Is_Left                    = 1 << 10,
	Is_Right                   = 1 << 11,
	AltGr_Down                 = 1 << 12,
	Is_Repeat                  = 1 << 13,
	Precision_Scrolling_Delta  = 1 << 14,
	Scroll_By_Page             = 1 << 15,
}

Cef_Process_Id :: enum c.int {
	Browser  = 0,
	Renderer = 1,
}

Cef_Mouse_Event :: struct {
	x:         c.int,
	y:         c.int,
	modifiers: c.uint32_t,
}

Cef_Key_Event :: struct {
	size:                 c.size_t,
	_type:                Cef_Key_Event_Type,
	modifiers:            c.uint32_t,
	windows_key_code:     c.int,
	native_key_code:      c.int,
	is_system_key:        c.int,
	character:            u16,
	unmodified_character: u16,
	focus_on_editable_field: c.int,
}

Cef_String :: struct {
	str:    [^]u16,
	length: c.size_t,
	dtor:   #type proc "c" (str: [^]u16),
}

Cef_String_UTF8 :: struct {
	str:    [^]u8,
	length: c.size_t,
	dtor:   #type proc "c" (str: [^]u8),
}

Cef_String_Userfree :: ^Cef_String

Cef_Rect :: struct {
	x:      c.int,
	y:      c.int,
	width:  c.int,
	height: c.int,
}

Cef_Size :: struct {
	width:  c.int,
	height: c.int,
}

Cef_Screen_Info :: struct {
	size:                c.size_t,
	device_scale_factor: f32,
	depth:               c.int,
	depth_per_component: c.int,
	is_monochrome:       c.int,
	rect:                Cef_Rect,
	available_rect:      Cef_Rect,
}

Cef_Accelerated_Paint_Info_Common :: struct {
	size:                    c.size_t,
	timestamp:               c.uint64_t,
	coded_size:              Cef_Size,
	visible_rect:            Cef_Rect,
	content_rect:            Cef_Rect,
	source_size:             Cef_Size,
	capture_update_rect:     Cef_Rect,
	region_capture_rect:     Cef_Rect,
	capture_counter:         c.uint64_t,
	has_capture_update_rect: u8,
	has_region_capture_rect: u8,
	has_source_size:         u8,
	has_capture_counter:     u8,
}

Cef_Accelerated_Paint_Info :: struct {
	size:                 c.size_t,
	shared_texture_handle: rawptr,
	format:               Cef_Color_Type,
	extra:                Cef_Accelerated_Paint_Info_Common,
}

Cef_Base_Ref_Counted :: struct {
	size:                 c.size_t,
	add_ref:              Cef_Base_Add_Ref_Proc,
	release:              Cef_Base_Ref_Result_Proc,
	has_one_ref:          Cef_Base_Ref_Result_Proc,
	has_at_least_one_ref: Cef_Base_Ref_Result_Proc,
}

Cef_Callback_Ref_Count :: struct {
	value: c.int32_t,
}

Cef_Main_Args :: struct {
	instance: rawptr,
}

Cef_Settings :: struct {
	size: c.size_t,

	no_sandbox:                       c.int,
	browser_subprocess_path:          Cef_String,
	framework_dir_path:               Cef_String,
	main_bundle_path:                 Cef_String,
	multi_threaded_message_loop:      c.int,
	external_message_pump:            c.int,
	windowless_rendering_enabled:     c.int,
	command_line_args_disabled:       c.int,
	cache_path:                       Cef_String,
	root_cache_path:                  Cef_String,
	persist_session_cookies:          c.int,
	user_agent:                       Cef_String,
	user_agent_product:               Cef_String,
	locale:                           Cef_String,
	log_file:                         Cef_String,
	log_severity:                     Cef_Log_Severity,
	log_items:                        Cef_Log_Items,
	javascript_flags:                 Cef_String,
	resources_dir_path:               Cef_String,
	locales_dir_path:                 Cef_String,
	remote_debugging_port:            c.int,
	uncaught_exception_stack_size:    c.int,
	background_color:                 c.uint32_t,
	accept_language_list:             Cef_String,
	cookieable_schemes_list:          Cef_String,
	cookieable_schemes_exclude_defaults: c.int,
	chrome_policy_id:                 Cef_String,
	chrome_app_icon_id:               c.int,
	disable_signal_handlers:          c.int,
	use_views_default_popup:          c.int,
}

Cef_Browser_Settings :: struct {
	size:                    c.size_t,
	windowless_frame_rate:   c.int,

	standard_font_family:    Cef_String,
	fixed_font_family:       Cef_String,
	serif_font_family:       Cef_String,
	sans_serif_font_family:  Cef_String,
	cursive_font_family:     Cef_String,
	fantasy_font_family:     Cef_String,
	default_font_size:       c.int,
	default_fixed_font_size: c.int,
	minimum_font_size:       c.int,
	minimum_logical_font_size: c.int,
	default_encoding:        Cef_String,

	remote_fonts:                   Cef_State,
	javascript:                     Cef_State,
	javascript_close_windows:       Cef_State,
	javascript_access_clipboard:    Cef_State,
	javascript_dom_paste:           Cef_State,
	image_loading:                  Cef_State,
	image_shrink_standalone_to_fit: Cef_State,
	text_area_resize:               Cef_State,
	tab_to_links:                   Cef_State,
	local_storage:                  Cef_State,
	databases_deprecated:           Cef_State,
	webgl:                          Cef_State,
	background_color:               c.uint32_t,
	chrome_status_bubble:           Cef_State,
	chrome_zoom_bubble:             Cef_State,
	ax_viewport_collapse:           Cef_State,
}

Cef_Window_Info :: struct {
	size:                          c.size_t,
	ex_style:                      c.uint32_t,
	window_name:                   Cef_String,
	style:                         c.uint32_t,
	bounds:                        Cef_Rect,
	parent_window:                 rawptr,
	menu:                          rawptr,
	windowless_rendering_enabled: c.int,
	shared_texture_enabled:       c.int,
	external_begin_frame_enabled: c.int,
	window:                        rawptr,
	runtime_style:                 Cef_Runtime_Style,
}

Cef_App :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Client :: struct {
	base: Cef_Base_Ref_Counted,

	get_audio_handler:          rawptr,
	get_command_handler:        rawptr,
	get_context_menu_handler:   rawptr,
	get_dialog_handler:         rawptr,
	get_display_handler:        rawptr,
	get_download_handler:       rawptr,
	get_drag_handler:           rawptr,
	get_find_handler:           rawptr,
	get_focus_handler:          rawptr,
	get_frame_handler:          rawptr,
	get_permission_handler:     rawptr,
	get_jsdialog_handler:       rawptr,
	get_keyboard_handler:       rawptr,
	get_life_span_handler:      Cef_Client_Get_Life_Span_Handler_Proc,
	get_load_handler:           rawptr,
	get_print_handler:          rawptr,
	get_render_handler:         Cef_Client_Get_Render_Handler_Proc,
	get_request_handler:        rawptr,
	on_process_message_received: Cef_Client_On_Process_Message_Received_Proc,
}

Cef_Render_Handler :: struct {
	base: Cef_Base_Ref_Counted,

	get_accessibility_handler: rawptr,
	get_root_screen_rect:      rawptr,
	get_view_rect:             Cef_Render_Handler_Get_View_Rect_Proc,
	get_screen_point:          Cef_Render_Handler_Get_Screen_Point_Proc,
	get_screen_info:           Cef_Render_Handler_Get_Screen_Info_Proc,
	on_popup_show:             Cef_Render_Handler_On_Popup_Show_Proc,
	on_popup_size:             Cef_Render_Handler_On_Popup_Size_Proc,
	on_paint:                  Cef_Render_Handler_On_Paint_Proc,
	on_accelerated_paint:      Cef_Render_Handler_On_Accelerated_Paint_Proc,
	get_touch_handle_size:           rawptr,
	on_touch_handle_state_changed:    rawptr,
	start_dragging:                   rawptr,
	update_drag_cursor:               rawptr,
	on_scroll_offset_changed:         rawptr,
	on_ime_composition_range_changed: rawptr,
	on_text_selection_changed:        rawptr,
	on_virtual_keyboard_requested:    rawptr,
}

Cef_Life_Span_Handler :: struct {
	base: Cef_Base_Ref_Counted,

	on_before_popup:         Cef_Life_Span_Handler_On_Before_Popup_Proc,
	on_before_popup_aborted: rawptr,
	on_before_dev_tools_popup: rawptr,
	on_after_created:        Cef_Life_Span_Handler_On_After_Created_Proc,
	do_close:                Cef_Life_Span_Handler_Do_Close_Proc,
	on_before_close:         Cef_Life_Span_Handler_On_Before_Close_Proc,
}

Cef_Browser :: struct {
	base: Cef_Base_Ref_Counted,

	is_valid:               Cef_Browser_Is_Valid_Proc,
	get_host:               Cef_Browser_Get_Host_Proc,
	can_go_back:            rawptr,
	go_back:                rawptr,
	can_go_forward:         rawptr,
	go_forward:             rawptr,
	is_loading:             rawptr,
	reload:                 rawptr,
	reload_ignore_cache:    rawptr,
	stop_load:              rawptr,
	get_identifier:         Cef_Browser_Get_Identifier_Proc,
	is_same:                rawptr,
	is_popup:               rawptr,
	has_document:           Cef_Browser_Has_Document_Proc,
	get_main_frame:         Cef_Browser_Get_Main_Frame_Proc,
	get_focused_frame:      rawptr,
	get_frame_by_identifier: rawptr,
	get_frame_by_name:      rawptr,
	get_frame_count:        rawptr,
	get_frame_identifiers:  rawptr,
	get_frame_names:        rawptr,
}

Cef_Browser_Host :: struct {
	base: Cef_Base_Ref_Counted,

	get_browser:                   Cef_Browser_Host_Get_Browser_Proc,
	close_browser:                 Cef_Browser_Host_Close_Browser_Proc,
	try_close_browser:             rawptr,
	is_ready_to_be_closed:         rawptr,
	set_focus:                     Cef_Browser_Host_Set_Focus_Proc,
	get_window_handle:             rawptr,
	get_opener_window_handle:      rawptr,
	get_opener_identifier:         rawptr,
	has_view:                      rawptr,
	get_client:                    rawptr,
	get_request_context:           rawptr,
	can_zoom:                      rawptr,
	zoom:                          rawptr,
	get_default_zoom_level:        rawptr,
	get_zoom_level:                rawptr,
	set_zoom_level:                rawptr,
	run_file_dialog:               rawptr,
	start_download:                rawptr,
	download_image:                rawptr,
	print:                         rawptr,
	print_to_pdf:                  rawptr,
	find:                          rawptr,
	stop_finding:                  rawptr,
	show_dev_tools:                rawptr,
	close_dev_tools:               rawptr,
	has_dev_tools:                 rawptr,
	send_dev_tools_message:        rawptr,
	execute_dev_tools_method:      rawptr,
	add_dev_tools_message_observer: rawptr,
	get_navigation_entries:        rawptr,
	replace_misspelling:           rawptr,
	add_word_to_dictionary:        rawptr,
	is_window_rendering_disabled:  rawptr,
	was_resized:                   Cef_Browser_Host_Was_Resized_Proc,
	was_hidden:                    Cef_Browser_Host_Was_Hidden_Proc,
	notify_screen_info_changed:    Cef_Browser_Host_Notify_Screen_Info_Changed_Proc,
	invalidate:                    Cef_Browser_Host_Invalidate_Proc,
	send_external_begin_frame:     rawptr,
	send_key_event:                Cef_Browser_Host_Send_Key_Event_Proc,
	send_mouse_click_event:        Cef_Browser_Host_Send_Mouse_Click_Event_Proc,
	send_mouse_move_event:         Cef_Browser_Host_Send_Mouse_Move_Event_Proc,
	send_mouse_wheel_event:        Cef_Browser_Host_Send_Mouse_Wheel_Event_Proc,
	send_touch_event:              rawptr,
	send_capture_lost_event:       rawptr,
	notify_move_or_resize_started: rawptr,
	get_windowless_frame_rate:     Cef_Browser_Host_Get_Windowless_Frame_Rate_Proc,
	set_windowless_frame_rate:     Cef_Browser_Host_Set_Windowless_Frame_Rate_Proc,
	ime_set_composition:           rawptr,
	ime_commit_text:               rawptr,
	ime_finish_composing_text:     rawptr,
	ime_cancel_composition:        rawptr,
	drag_target_drag_enter:        rawptr,
	drag_target_drag_over:         rawptr,
	drag_target_drag_leave:        rawptr,
	drag_target_drop:              rawptr,
	drag_source_ended_at:          rawptr,
	drag_source_system_drag_ended: rawptr,
	get_visible_navigation_entry: rawptr,
	set_accessibility_state:       rawptr,
	set_auto_resize_enabled:       rawptr,
	set_audio_muted:               rawptr,
	is_audio_muted:                rawptr,
	is_fullscreen:                 rawptr,
	exit_fullscreen:               rawptr,
	can_execute_chrome_command:    rawptr,
	execute_chrome_command:        rawptr,
	is_render_process_unresponsive: rawptr,
	get_runtime_style:             rawptr,
	set_ax_viewport_collapse:       Cef_Browser_Host_Set_Ax_Viewport_Collapse_Proc,
}

Cef_Frame :: struct {
	base: Cef_Base_Ref_Counted,

	is_valid:                rawptr,
	undo:                    rawptr,
	redo:                    rawptr,
	cut:                     rawptr,
	copy:                    rawptr,
	paste:                   rawptr,
	paste_and_match_style:   rawptr,
	del:                     rawptr,
	select_all:              rawptr,
	view_source:             rawptr,
	get_source:              rawptr,
	get_text:                rawptr,
	load_request:            rawptr,
	load_url:                Cef_Frame_Load_Url_Proc,
	execute_java_script:     Cef_Frame_Execute_Java_Script_Proc,
	is_main:                 Cef_Frame_Is_Main_Proc,
	is_focused:              rawptr,
	get_name:                rawptr,
	get_identifier:          rawptr,
	get_parent:              rawptr,
	get_url:                 Cef_Frame_Get_Url_Proc,
	get_browser:             Cef_Frame_Get_Browser_Proc,
	get_v8_context:          rawptr,
	visit_dom:               rawptr,
	create_urlrequest:       rawptr,
	send_process_message:    rawptr,
}

Cef_Dictionary_Value :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Request_Context :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Process_Message :: struct {
	base: Cef_Base_Ref_Counted,
}

Cef_Popup_Features :: struct {
	size:   c.size_t,
	x:      c.int,
	x_set:  c.int,
	y:      c.int,
	y_set:  c.int,
	width:  c.int,
	width_set: c.int,
	height: c.int,
	height_set: c.int,
	is_popup: c.int,
}

#assert(size_of(Cef_Rect) == 16)
#assert(size_of(Cef_Size) == 8)
#assert(size_of(Cef_Mouse_Event) == 12)

when ODIN_OS == .Windows {
	#assert(size_of(rawptr) == 4)
}

when ODIN_OS == .Windows {
	#assert(size_of(Cef_String) == 12)
	#assert(size_of(Cef_Base_Ref_Counted) == 20)
	#assert(size_of(Cef_Key_Event) == 32)
	#assert(size_of(Cef_Screen_Info) == 52)
	#assert(size_of(Cef_Window_Info) == 68)
	#assert(size_of(Cef_Settings) == 244)
	#assert(size_of(Cef_Browser_Settings) == 172)
	#assert(size_of(Cef_Accelerated_Paint_Info) == 128)
	#assert(size_of(Cef_Accelerated_Paint_Info_Common) == 112)
	#assert(size_of(Cef_Popup_Features) == 40)
	#assert(size_of(Cef_Client) == 96)
	#assert(size_of(Cef_Render_Handler) == 88)
	#assert(size_of(Cef_Life_Span_Handler) == 44)
	#assert(size_of(Cef_Browser) == 104)
	#assert(size_of(Cef_Browser_Host) == 296)
	#assert(size_of(Cef_Frame) == 124)
	#assert(offset_of(Cef_Settings, windowless_rendering_enabled) == 52)
	#assert(offset_of(Cef_Settings, use_views_default_popup) == 240)
	#assert(offset_of(Cef_Base_Ref_Counted, add_ref) == 4)
	#assert(offset_of(Cef_Base_Ref_Counted, release) == 8)
	#assert(offset_of(Cef_Base_Ref_Counted, has_one_ref) == 12)
	#assert(offset_of(Cef_Base_Ref_Counted, has_at_least_one_ref) == 16)
	#assert(offset_of(Cef_Accelerated_Paint_Info_Common, timestamp) == 8)
	#assert(offset_of(Cef_Accelerated_Paint_Info_Common, capture_counter) == 96)
	#assert(offset_of(Cef_Accelerated_Paint_Info, format) == 8)
	#assert(offset_of(Cef_Accelerated_Paint_Info, extra) == 16)
	#assert(offset_of(Cef_Popup_Features, is_popup) == 36)
	#assert(offset_of(Cef_Window_Info, windowless_rendering_enabled) == 48)
	#assert(offset_of(Cef_Window_Info, shared_texture_enabled) == 52)
	#assert(offset_of(Cef_Browser_Settings, ax_viewport_collapse) == 168)
	#assert(offset_of(Cef_Client, get_life_span_handler) == 72)
	#assert(offset_of(Cef_Client, get_render_handler) == 84)
	#assert(offset_of(Cef_Client, on_process_message_received) == 92)
	#assert(offset_of(Cef_Render_Handler, get_view_rect) == 28)
	#assert(offset_of(Cef_Render_Handler, get_screen_point) == 32)
	#assert(offset_of(Cef_Render_Handler, get_screen_info) == 36)
	#assert(offset_of(Cef_Render_Handler, on_popup_show) == 40)
	#assert(offset_of(Cef_Render_Handler, on_popup_size) == 44)
	#assert(offset_of(Cef_Render_Handler, on_paint) == 48)
	#assert(offset_of(Cef_Render_Handler, on_accelerated_paint) == 52)
	#assert(offset_of(Cef_Life_Span_Handler, on_before_popup) == 20)
	#assert(offset_of(Cef_Life_Span_Handler, on_after_created) == 32)
	#assert(offset_of(Cef_Life_Span_Handler, do_close) == 36)
	#assert(offset_of(Cef_Life_Span_Handler, on_before_close) == 40)
	#assert(offset_of(Cef_Browser, is_valid) == 20)
	#assert(offset_of(Cef_Browser, get_host) == 24)
	#assert(offset_of(Cef_Browser, get_identifier) == 60)
	#assert(offset_of(Cef_Browser, has_document) == 72)
	#assert(offset_of(Cef_Browser, get_main_frame) == 76)
	#assert(offset_of(Cef_Browser_Host, close_browser) == 24)
	#assert(offset_of(Cef_Browser_Host, set_focus) == 36)
	#assert(offset_of(Cef_Browser_Host, was_resized) == 152)
	#assert(offset_of(Cef_Browser_Host, was_hidden) == 156)
	#assert(offset_of(Cef_Browser_Host, notify_screen_info_changed) == 160)
	#assert(offset_of(Cef_Browser_Host, invalidate) == 164)
	#assert(offset_of(Cef_Browser_Host, send_key_event) == 172)
	#assert(offset_of(Cef_Browser_Host, send_mouse_click_event) == 176)
	#assert(offset_of(Cef_Browser_Host, send_mouse_move_event) == 180)
	#assert(offset_of(Cef_Browser_Host, send_mouse_wheel_event) == 184)
	#assert(offset_of(Cef_Browser_Host, get_windowless_frame_rate) == 200)
	#assert(offset_of(Cef_Browser_Host, set_windowless_frame_rate) == 204)
	#assert(offset_of(Cef_Browser_Host, set_ax_viewport_collapse) == 292)
	#assert(offset_of(Cef_Frame, load_url) == 72)
	#assert(offset_of(Cef_Frame, execute_java_script) == 76)
	#assert(offset_of(Cef_Frame, is_main) == 80)
	#assert(offset_of(Cef_Frame, get_url) == 100)
	#assert(offset_of(Cef_Frame, get_browser) == 104)
}

when ODIN_OS == .Windows {
	Cef_Base_Add_Ref_Proc :: #type proc "stdcall" (self: rawptr)
	Cef_Base_Ref_Result_Proc :: #type proc "stdcall" (self: rawptr) -> c.int

	Cef_Client_Get_Render_Handler_Proc :: #type proc "stdcall" (self: ^Cef_Client) -> ^Cef_Render_Handler
	Cef_Client_Get_Life_Span_Handler_Proc :: #type proc "stdcall" (self: ^Cef_Client) -> ^Cef_Life_Span_Handler
	Cef_Client_On_Process_Message_Received_Proc :: #type proc "stdcall" (
		self: ^Cef_Client,
		browser: ^Cef_Browser,
		frame: ^Cef_Frame,
		source_process: Cef_Process_Id,
		message: ^Cef_Process_Message,
	) -> c.int

	Cef_Render_Handler_Get_View_Rect_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
	Cef_Render_Handler_Get_Screen_Point_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		view_x: c.int,
		view_y: c.int,
		screen_x: ^c.int,
		screen_y: ^c.int,
	) -> c.int
	Cef_Render_Handler_Get_Screen_Info_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		screen_info: ^Cef_Screen_Info,
	) -> c.int
	Cef_Render_Handler_On_Popup_Show_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		show: c.int,
	)
	Cef_Render_Handler_On_Popup_Size_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
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
	Cef_Render_Handler_On_Accelerated_Paint_Proc :: #type proc "stdcall" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		info: ^Cef_Accelerated_Paint_Info,
	)

	Cef_Life_Span_Handler_On_Before_Popup_Proc :: #type proc "stdcall" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
		frame: ^Cef_Frame,
		popup_id: c.int,
		target_url: ^Cef_String,
		target_frame_name: ^Cef_String,
		target_disposition: Cef_Window_Open_Disposition,
		user_gesture: c.int,
		popup_features: ^Cef_Popup_Features,
		window_info: ^Cef_Window_Info,
		client: ^^Cef_Client,
		settings: ^Cef_Browser_Settings,
		extra_info: ^^Cef_Dictionary_Value,
		no_javascript_access: ^c.int,
	) -> c.int
	Cef_Life_Span_Handler_On_After_Created_Proc :: #type proc "stdcall" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	)
	Cef_Life_Span_Handler_Do_Close_Proc :: #type proc "stdcall" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	) -> c.int
	Cef_Life_Span_Handler_On_Before_Close_Proc :: #type proc "stdcall" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	)

	Cef_Browser_Is_Valid_Proc :: #type proc "stdcall" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Get_Host_Proc :: #type proc "stdcall" (self: ^Cef_Browser) -> ^Cef_Browser_Host
	Cef_Browser_Get_Identifier_Proc :: #type proc "stdcall" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Has_Document_Proc :: #type proc "stdcall" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Get_Main_Frame_Proc :: #type proc "stdcall" (self: ^Cef_Browser) -> ^Cef_Frame
	Cef_Browser_Host_Get_Browser_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host) -> ^Cef_Browser
	Cef_Browser_Host_Close_Browser_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, force_close: c.int)
	Cef_Browser_Host_Set_Focus_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, focus: c.int)
	Cef_Browser_Host_Was_Resized_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host)
	Cef_Browser_Host_Was_Hidden_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, hidden: c.int)
	Cef_Browser_Host_Notify_Screen_Info_Changed_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host)
	Cef_Browser_Host_Invalidate_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, paint_type: Cef_Paint_Element_Type)
	Cef_Browser_Host_Send_Key_Event_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, event: ^Cef_Key_Event)
	Cef_Browser_Host_Send_Mouse_Click_Event_Proc :: #type proc "stdcall" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		button_type: Cef_Mouse_Button_Type,
		mouse_up: c.int,
		click_count: c.int,
	)
	Cef_Browser_Host_Send_Mouse_Move_Event_Proc :: #type proc "stdcall" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		mouse_leave: c.int,
	)
	Cef_Browser_Host_Send_Mouse_Wheel_Event_Proc :: #type proc "stdcall" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		delta_x: c.int,
		delta_y: c.int,
	)
	Cef_Browser_Host_Get_Windowless_Frame_Rate_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host) -> c.int
	Cef_Browser_Host_Set_Windowless_Frame_Rate_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, frame_rate: c.int)
	Cef_Browser_Host_Set_Ax_Viewport_Collapse_Proc :: #type proc "stdcall" (self: ^Cef_Browser_Host, enabled: c.int)

	Cef_Frame_Load_Url_Proc :: #type proc "stdcall" (self: ^Cef_Frame, url: ^Cef_String)
	Cef_Frame_Execute_Java_Script_Proc :: #type proc "stdcall" (
		self: ^Cef_Frame,
		code: ^Cef_String,
		script_url: ^Cef_String,
		start_line: c.int,
	)
	Cef_Frame_Is_Main_Proc :: #type proc "stdcall" (self: ^Cef_Frame) -> c.int
	Cef_Frame_Get_Url_Proc :: #type proc "stdcall" (self: ^Cef_Frame) -> Cef_String_Userfree
	Cef_Frame_Get_Browser_Proc :: #type proc "stdcall" (self: ^Cef_Frame) -> ^Cef_Browser
}
else {
	Cef_Base_Add_Ref_Proc :: #type proc "c" (self: rawptr)
	Cef_Base_Ref_Result_Proc :: #type proc "c" (self: rawptr) -> c.int

	Cef_Client_Get_Render_Handler_Proc :: #type proc "c" (self: ^Cef_Client) -> ^Cef_Render_Handler
	Cef_Client_Get_Life_Span_Handler_Proc :: #type proc "c" (self: ^Cef_Client) -> ^Cef_Life_Span_Handler
	Cef_Client_On_Process_Message_Received_Proc :: #type proc "c" (
		self: ^Cef_Client,
		browser: ^Cef_Browser,
		frame: ^Cef_Frame,
		source_process: Cef_Process_Id,
		message: ^Cef_Process_Message,
	) -> c.int

	Cef_Render_Handler_Get_View_Rect_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
	Cef_Render_Handler_Get_Screen_Point_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		view_x: c.int,
		view_y: c.int,
		screen_x: ^c.int,
		screen_y: ^c.int,
	) -> c.int
	Cef_Render_Handler_Get_Screen_Info_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		screen_info: ^Cef_Screen_Info,
	) -> c.int
	Cef_Render_Handler_On_Popup_Show_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		show: c.int,
	)
	Cef_Render_Handler_On_Popup_Size_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		rect: ^Cef_Rect,
	)
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
	Cef_Render_Handler_On_Accelerated_Paint_Proc :: #type proc "c" (
		self: ^Cef_Render_Handler,
		browser: ^Cef_Browser,
		paint_type: Cef_Paint_Element_Type,
		dirty_rects_count: c.size_t,
		dirty_rects: [^]Cef_Rect,
		info: ^Cef_Accelerated_Paint_Info,
	)

	Cef_Life_Span_Handler_On_Before_Popup_Proc :: #type proc "c" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
		frame: ^Cef_Frame,
		popup_id: c.int,
		target_url: ^Cef_String,
		target_frame_name: ^Cef_String,
		target_disposition: Cef_Window_Open_Disposition,
		user_gesture: c.int,
		popup_features: ^Cef_Popup_Features,
		window_info: ^Cef_Window_Info,
		client: ^^Cef_Client,
		settings: ^Cef_Browser_Settings,
		extra_info: ^^Cef_Dictionary_Value,
		no_javascript_access: ^c.int,
	) -> c.int
	Cef_Life_Span_Handler_On_After_Created_Proc :: #type proc "c" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	)
	Cef_Life_Span_Handler_Do_Close_Proc :: #type proc "c" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	) -> c.int
	Cef_Life_Span_Handler_On_Before_Close_Proc :: #type proc "c" (
		self: ^Cef_Life_Span_Handler,
		browser: ^Cef_Browser,
	)

	Cef_Browser_Is_Valid_Proc :: #type proc "c" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Get_Host_Proc :: #type proc "c" (self: ^Cef_Browser) -> ^Cef_Browser_Host
	Cef_Browser_Get_Identifier_Proc :: #type proc "c" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Has_Document_Proc :: #type proc "c" (self: ^Cef_Browser) -> c.int
	Cef_Browser_Get_Main_Frame_Proc :: #type proc "c" (self: ^Cef_Browser) -> ^Cef_Frame
	Cef_Browser_Host_Get_Browser_Proc :: #type proc "c" (self: ^Cef_Browser_Host) -> ^Cef_Browser
	Cef_Browser_Host_Close_Browser_Proc :: #type proc "c" (self: ^Cef_Browser_Host, force_close: c.int)
	Cef_Browser_Host_Set_Focus_Proc :: #type proc "c" (self: ^Cef_Browser_Host, focus: c.int)
	Cef_Browser_Host_Was_Resized_Proc :: #type proc "c" (self: ^Cef_Browser_Host)
	Cef_Browser_Host_Was_Hidden_Proc :: #type proc "c" (self: ^Cef_Browser_Host, hidden: c.int)
	Cef_Browser_Host_Notify_Screen_Info_Changed_Proc :: #type proc "c" (self: ^Cef_Browser_Host)
	Cef_Browser_Host_Invalidate_Proc :: #type proc "c" (self: ^Cef_Browser_Host, paint_type: Cef_Paint_Element_Type)
	Cef_Browser_Host_Send_Key_Event_Proc :: #type proc "c" (self: ^Cef_Browser_Host, event: ^Cef_Key_Event)
	Cef_Browser_Host_Send_Mouse_Click_Event_Proc :: #type proc "c" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		button_type: Cef_Mouse_Button_Type,
		mouse_up: c.int,
		click_count: c.int,
	)
	Cef_Browser_Host_Send_Mouse_Move_Event_Proc :: #type proc "c" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		mouse_leave: c.int,
	)
	Cef_Browser_Host_Send_Mouse_Wheel_Event_Proc :: #type proc "c" (
		self: ^Cef_Browser_Host,
		event: ^Cef_Mouse_Event,
		delta_x: c.int,
		delta_y: c.int,
	)
	Cef_Browser_Host_Get_Windowless_Frame_Rate_Proc :: #type proc "c" (self: ^Cef_Browser_Host) -> c.int
	Cef_Browser_Host_Set_Windowless_Frame_Rate_Proc :: #type proc "c" (self: ^Cef_Browser_Host, frame_rate: c.int)
	Cef_Browser_Host_Set_Ax_Viewport_Collapse_Proc :: #type proc "c" (self: ^Cef_Browser_Host, enabled: c.int)

	Cef_Frame_Load_Url_Proc :: #type proc "c" (self: ^Cef_Frame, url: ^Cef_String)
	Cef_Frame_Execute_Java_Script_Proc :: #type proc "c" (
		self: ^Cef_Frame,
		code: ^Cef_String,
		script_url: ^Cef_String,
		start_line: c.int,
	)
	Cef_Frame_Is_Main_Proc :: #type proc "c" (self: ^Cef_Frame) -> c.int
	Cef_Frame_Get_Url_Proc :: #type proc "c" (self: ^Cef_Frame) -> Cef_String_Userfree
	Cef_Frame_Get_Browser_Proc :: #type proc "c" (self: ^Cef_Frame) -> ^Cef_Browser
}
