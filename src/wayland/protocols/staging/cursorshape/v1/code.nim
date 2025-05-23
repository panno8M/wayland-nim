# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code
import wayland/protocols/stable/tablet/v2/code as tablet_code

var cursorShapeV1_types: array[6, ptr Interface]
type WpCursorShapeDeviceV1* = object
type WpCursorShapeManagerV1* = object

let
  wp_cursor_shape_manager_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr cursor_shape_v1_types[0]),
    Message(name: "get_pointer", signature: "no", types: addr cursor_shape_v1_types[2]),
    Message(name: "get_tablet_tool_v2", signature: "no", types: addr cursor_shape_v1_types[4]),
  ]

  wp_cursor_shape_manager_v1_interface* {.exportc.} = Interface(
    name: "wp_cursor_shape_manager_v1",
    version: 2,
    method_count: 3,
    methods: addr wp_cursor_shape_manager_v1_requests[0],
  )

  wp_cursor_shape_device_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr cursor_shape_v1_types[0]),
    Message(name: "set_shape", signature: "uu", types: addr cursor_shape_v1_types[0]),
  ]

  wp_cursor_shape_device_v1_interface* {.exportc.} = Interface(
    name: "wp_cursor_shape_device_v1",
    version: 2,
    method_count: 2,
    methods: addr wp_cursor_shape_device_v1_requests[0],
  )


type WpCursorShapeDeviceV1Shape* {.size: sizeof(uint32).} = enum
  shape_default = 1
  shape_context_menu = 2
  shape_help = 3
  shape_pointer = 4
  shape_progress = 5
  shape_wait = 6
  shape_cell = 7
  shape_crosshair = 8
  shape_text = 9
  shape_vertical_text = 10
  shape_alias = 11
  shape_copy = 12
  shape_move = 13
  shape_no_drop = 14
  shape_not_allowed = 15
  shape_grab = 16
  shape_grabbing = 17
  shape_e_resize = 18
  shape_n_resize = 19
  shape_ne_resize = 20
  shape_nw_resize = 21
  shape_s_resize = 22
  shape_se_resize = 23
  shape_sw_resize = 24
  shape_w_resize = 25
  shape_ew_resize = 26
  shape_ns_resize = 27
  shape_nesw_resize = 28
  shape_nwse_resize = 29
  shape_col_resize = 30
  shape_row_resize = 31
  shape_all_scroll = 32
  shape_zoom_in = 33
  shape_zoom_out = 34
  shape_dnd_ask = 35
  shape_all_resize = 36
func since*(e: WpCursorShapeDeviceV1Shape): int =
  case e
  of shape_default: 1
  of shape_context_menu: 1
  of shape_help: 1
  of shape_pointer: 1
  of shape_progress: 1
  of shape_wait: 1
  of shape_cell: 1
  of shape_crosshair: 1
  of shape_text: 1
  of shape_vertical_text: 1
  of shape_alias: 1
  of shape_copy: 1
  of shape_move: 1
  of shape_no_drop: 1
  of shape_not_allowed: 1
  of shape_grab: 1
  of shape_grabbing: 1
  of shape_e_resize: 1
  of shape_n_resize: 1
  of shape_ne_resize: 1
  of shape_nw_resize: 1
  of shape_s_resize: 1
  of shape_se_resize: 1
  of shape_sw_resize: 1
  of shape_w_resize: 1
  of shape_ew_resize: 1
  of shape_ns_resize: 1
  of shape_nesw_resize: 1
  of shape_nwse_resize: 1
  of shape_col_resize: 1
  of shape_row_resize: 1
  of shape_all_scroll: 1
  of shape_zoom_in: 1
  of shape_zoom_out: 1
  of shape_dnd_ask: 2
  of shape_all_resize: 2
proc isValid*(e: WpCursorShapeDeviceV1Shape; version: int): bool =
  version >= e.since

type WpCursorShapeDeviceV1Error* {.size: sizeof(uint32).} = enum
  error_invalid_shape = 1
func since*(e: WpCursorShapeDeviceV1Error): int =
  case e
  of error_invalid_shape: 1
proc isValid*(e: WpCursorShapeDeviceV1Error; version: int): bool =
  version >= e.since

type WpCursorShapeManagerV1Request* {.size: sizeof(uint32).} = enum
  WpCursorShapeManagerV1Request_destroy
  WpCursorShapeManagerV1Request_get_pointer
  WpCursorShapeManagerV1Request_get_tablet_tool_v2
proc since*(e: WpCursorShapeManagerV1Request): int =
  case e
  of WpCursorShapeManagerV1Request_destroy: 1
  of WpCursorShapeManagerV1Request_get_pointer: 1
  of WpCursorShapeManagerV1Request_get_tablet_tool_v2: 1

type WpCursorShapeDeviceV1Request* {.size: sizeof(uint32).} = enum
  WpCursorShapeDeviceV1Request_destroy
  WpCursorShapeDeviceV1Request_set_shape
proc since*(e: WpCursorShapeDeviceV1Request): int =
  case e
  of WpCursorShapeDeviceV1Request_destroy: 1
  of WpCursorShapeDeviceV1Request_set_shape: 1

cursorShapeV1_types = [
  nil,
  nil,
  addr wp_cursor_shape_device_v1_interface,
  addr wl_pointer_interface,
  addr wp_cursor_shape_device_v1_interface,
  addr zwp_tablet_tool_v2_interface,
]


