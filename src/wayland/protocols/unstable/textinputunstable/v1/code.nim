# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var textInputUnstableV1_types: array[10, ptr Interface]
type ZwpTextInputManagerV1* = object
type ZwpTextInputV1* = object

let
  zwp_text_input_v1_requests {.exportc.} = [
    Message(name: "activate", signature: "oo", types: addr text_input_unstable_v1_types[5]),
    Message(name: "deactivate", signature: "o", types: addr text_input_unstable_v1_types[7]),
    Message(name: "show_input_panel", signature: "", types: addr text_input_unstable_v1_types[0]),
    Message(name: "hide_input_panel", signature: "", types: addr text_input_unstable_v1_types[0]),
    Message(name: "reset", signature: "", types: addr text_input_unstable_v1_types[0]),
    Message(name: "set_surrounding_text", signature: "suu", types: addr text_input_unstable_v1_types[0]),
    Message(name: "set_content_type", signature: "uu", types: addr text_input_unstable_v1_types[0]),
    Message(name: "set_cursor_rectangle", signature: "iiii", types: addr text_input_unstable_v1_types[0]),
    Message(name: "set_preferred_language", signature: "s", types: addr text_input_unstable_v1_types[0]),
    Message(name: "commit_state", signature: "u", types: addr text_input_unstable_v1_types[0]),
    Message(name: "invoke_action", signature: "uu", types: addr text_input_unstable_v1_types[0]),
  ]

  zwp_text_input_v1_events {.exportc.} = [
    Message(name: "enter", signature: "o", types: addr text_input_unstable_v1_types[8]),
    Message(name: "leave", signature: "", types: addr text_input_unstable_v1_types[0]),
    Message(name: "modifiers_map", signature: "a", types: addr text_input_unstable_v1_types[0]),
    Message(name: "input_panel_state", signature: "u", types: addr text_input_unstable_v1_types[0]),
    Message(name: "preedit_string", signature: "uss", types: addr text_input_unstable_v1_types[0]),
    Message(name: "preedit_styling", signature: "uuu", types: addr text_input_unstable_v1_types[0]),
    Message(name: "preedit_cursor", signature: "i", types: addr text_input_unstable_v1_types[0]),
    Message(name: "commit_string", signature: "us", types: addr text_input_unstable_v1_types[0]),
    Message(name: "cursor_position", signature: "ii", types: addr text_input_unstable_v1_types[0]),
    Message(name: "delete_surrounding_text", signature: "iu", types: addr text_input_unstable_v1_types[0]),
    Message(name: "keysym", signature: "uuuuu", types: addr text_input_unstable_v1_types[0]),
    Message(name: "language", signature: "us", types: addr text_input_unstable_v1_types[0]),
    Message(name: "text_direction", signature: "uu", types: addr text_input_unstable_v1_types[0]),
  ]

  zwp_text_input_v1_interface* {.exportc.} = Interface(
    name: "zwp_text_input_v1",
    version: 1,
    method_count: 11,
    methods: addr zwp_text_input_v1_requests[0],
    event_count: 13,
    events: addr zwp_text_input_v1_events[0],
  )

  zwp_text_input_manager_v1_requests {.exportc.} = [
    Message(name: "create_text_input", signature: "n", types: addr text_input_unstable_v1_types[9]),
  ]

  zwp_text_input_manager_v1_interface* {.exportc.} = Interface(
    name: "zwp_text_input_manager_v1",
    version: 1,
    method_count: 1,
    methods: addr zwp_text_input_manager_v1_requests[0],
  )


type ZwpTextInputV1ContentHint* {.size: sizeof(uint32).} = enum
  content_hint_none = 0x0
  content_hint_default = 0x7
  content_hint_password = 0xc0
  content_hint_auto_completion = 0x1
  content_hint_auto_correction = 0x2
  content_hint_auto_capitalization = 0x4
  content_hint_lowercase = 0x8
  content_hint_uppercase = 0x10
  content_hint_titlecase = 0x20
  content_hint_hidden_text = 0x40
  content_hint_sensitive_data = 0x80
  content_hint_latin = 0x100
  content_hint_multiline = 0x200
func since*(e: ZwpTextInputV1ContentHint): int =
  case e
  of content_hint_none: 1
  of content_hint_default: 1
  of content_hint_password: 1
  of content_hint_auto_completion: 1
  of content_hint_auto_correction: 1
  of content_hint_auto_capitalization: 1
  of content_hint_lowercase: 1
  of content_hint_uppercase: 1
  of content_hint_titlecase: 1
  of content_hint_hidden_text: 1
  of content_hint_sensitive_data: 1
  of content_hint_latin: 1
  of content_hint_multiline: 1
proc isValid*(e: ZwpTextInputV1ContentHint; version: int): bool =
  version >= e.since

type ZwpTextInputV1ContentPurpose* {.size: sizeof(uint32).} = enum
  content_purpose_normal = 0
  content_purpose_alpha = 1
  content_purpose_digits = 2
  content_purpose_number = 3
  content_purpose_phone = 4
  content_purpose_url = 5
  content_purpose_email = 6
  content_purpose_name = 7
  content_purpose_password = 8
  content_purpose_date = 9
  content_purpose_time = 10
  content_purpose_datetime = 11
  content_purpose_terminal = 12
func since*(e: ZwpTextInputV1ContentPurpose): int =
  case e
  of content_purpose_normal: 1
  of content_purpose_alpha: 1
  of content_purpose_digits: 1
  of content_purpose_number: 1
  of content_purpose_phone: 1
  of content_purpose_url: 1
  of content_purpose_email: 1
  of content_purpose_name: 1
  of content_purpose_password: 1
  of content_purpose_date: 1
  of content_purpose_time: 1
  of content_purpose_datetime: 1
  of content_purpose_terminal: 1
proc isValid*(e: ZwpTextInputV1ContentPurpose; version: int): bool =
  version >= e.since

type ZwpTextInputV1PreeditStyle* {.size: sizeof(uint32).} = enum
  preedit_style_default = 0
  preedit_style_none = 1
  preedit_style_active = 2
  preedit_style_inactive = 3
  preedit_style_highlight = 4
  preedit_style_underline = 5
  preedit_style_selection = 6
  preedit_style_incorrect = 7
func since*(e: ZwpTextInputV1PreeditStyle): int =
  case e
  of preedit_style_default: 1
  of preedit_style_none: 1
  of preedit_style_active: 1
  of preedit_style_inactive: 1
  of preedit_style_highlight: 1
  of preedit_style_underline: 1
  of preedit_style_selection: 1
  of preedit_style_incorrect: 1
proc isValid*(e: ZwpTextInputV1PreeditStyle; version: int): bool =
  version >= e.since

type ZwpTextInputV1TextDirection* {.size: sizeof(uint32).} = enum
  text_direction_auto = 0
  text_direction_ltr = 1
  text_direction_rtl = 2
func since*(e: ZwpTextInputV1TextDirection): int =
  case e
  of text_direction_auto: 1
  of text_direction_ltr: 1
  of text_direction_rtl: 1
proc isValid*(e: ZwpTextInputV1TextDirection; version: int): bool =
  version >= e.since

type ZwpTextInputV1Event* {.size: sizeof(uint32).} = enum
  ZwpTextInputV1Event_enter
  ZwpTextInputV1Event_leave
  ZwpTextInputV1Event_modifiers_map
  ZwpTextInputV1Event_input_panel_state
  ZwpTextInputV1Event_preedit_string
  ZwpTextInputV1Event_preedit_styling
  ZwpTextInputV1Event_preedit_cursor
  ZwpTextInputV1Event_commit_string
  ZwpTextInputV1Event_cursor_position
  ZwpTextInputV1Event_delete_surrounding_text
  ZwpTextInputV1Event_keysym
  ZwpTextInputV1Event_language
  ZwpTextInputV1Event_text_direction
proc since*(e: ZwpTextInputV1Event): int =
  case e
  of ZwpTextInputV1Event_enter: 1
  of ZwpTextInputV1Event_leave: 1
  of ZwpTextInputV1Event_modifiers_map: 1
  of ZwpTextInputV1Event_input_panel_state: 1
  of ZwpTextInputV1Event_preedit_string: 1
  of ZwpTextInputV1Event_preedit_styling: 1
  of ZwpTextInputV1Event_preedit_cursor: 1
  of ZwpTextInputV1Event_commit_string: 1
  of ZwpTextInputV1Event_cursor_position: 1
  of ZwpTextInputV1Event_delete_surrounding_text: 1
  of ZwpTextInputV1Event_keysym: 1
  of ZwpTextInputV1Event_language: 1
  of ZwpTextInputV1Event_text_direction: 1

type ZwpTextInputV1Request* {.size: sizeof(uint32).} = enum
  ZwpTextInputV1Request_activate
  ZwpTextInputV1Request_deactivate
  ZwpTextInputV1Request_show_input_panel
  ZwpTextInputV1Request_hide_input_panel
  ZwpTextInputV1Request_reset
  ZwpTextInputV1Request_set_surrounding_text
  ZwpTextInputV1Request_set_content_type
  ZwpTextInputV1Request_set_cursor_rectangle
  ZwpTextInputV1Request_set_preferred_language
  ZwpTextInputV1Request_commit_state
  ZwpTextInputV1Request_invoke_action
proc since*(e: ZwpTextInputV1Request): int =
  case e
  of ZwpTextInputV1Request_activate: 1
  of ZwpTextInputV1Request_deactivate: 1
  of ZwpTextInputV1Request_show_input_panel: 1
  of ZwpTextInputV1Request_hide_input_panel: 1
  of ZwpTextInputV1Request_reset: 1
  of ZwpTextInputV1Request_set_surrounding_text: 1
  of ZwpTextInputV1Request_set_content_type: 1
  of ZwpTextInputV1Request_set_cursor_rectangle: 1
  of ZwpTextInputV1Request_set_preferred_language: 1
  of ZwpTextInputV1Request_commit_state: 1
  of ZwpTextInputV1Request_invoke_action: 1

type ZwpTextInputManagerV1Request* {.size: sizeof(uint32).} = enum
  ZwpTextInputManagerV1Request_create_text_input
proc since*(e: ZwpTextInputManagerV1Request): int =
  case e
  of ZwpTextInputManagerV1Request_create_text_input: 1

textInputUnstableV1_types = [
  nil,
  nil,
  nil,
  nil,
  nil,
  addr wl_seat_interface,
  addr wl_surface_interface,
  addr wl_seat_interface,
  addr wl_surface_interface,
  addr zwp_text_input_v1_interface,
]


