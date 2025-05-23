# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var xdgShellUnstableV5_types: array[24, ptr Interface]
type XdgPopup* = object
type XdgShell* = object
type XdgSurface* = object

let
  xdg_shell_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "use_unstable_version", signature: "i", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "get_xdg_surface", signature: "no", types: addr xdg_shell_unstable_v5_types[4]),
    Message(name: "get_xdg_popup", signature: "nooouii", types: addr xdg_shell_unstable_v5_types[6]),
    Message(name: "pong", signature: "u", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_shell_events {.exportc.} = [
    Message(name: "ping", signature: "u", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_shell_interface* {.exportc.} = Interface(
    name: "xdg_shell",
    version: 1,
    method_count: 5,
    methods: addr xdg_shell_requests[0],
    event_count: 1,
    events: addr xdg_shell_events[0],
  )

  xdg_surface_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_parent", signature: "?o", types: addr xdg_shell_unstable_v5_types[13]),
    Message(name: "set_title", signature: "s", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_app_id", signature: "s", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "show_window_menu", signature: "ouii", types: addr xdg_shell_unstable_v5_types[14]),
    Message(name: "move", signature: "ou", types: addr xdg_shell_unstable_v5_types[18]),
    Message(name: "resize", signature: "ouu", types: addr xdg_shell_unstable_v5_types[20]),
    Message(name: "ack_configure", signature: "u", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_window_geometry", signature: "iiii", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_maximized", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "unset_maximized", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_fullscreen", signature: "?o", types: addr xdg_shell_unstable_v5_types[23]),
    Message(name: "unset_fullscreen", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "set_minimized", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_surface_events {.exportc.} = [
    Message(name: "configure", signature: "iiau", types: addr xdg_shell_unstable_v5_types[0]),
    Message(name: "close", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_surface_interface* {.exportc.} = Interface(
    name: "xdg_surface",
    version: 1,
    method_count: 14,
    methods: addr xdg_surface_requests[0],
    event_count: 2,
    events: addr xdg_surface_events[0],
  )

  xdg_popup_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_popup_events {.exportc.} = [
    Message(name: "popup_done", signature: "", types: addr xdg_shell_unstable_v5_types[0]),
  ]

  xdg_popup_interface* {.exportc.} = Interface(
    name: "xdg_popup",
    version: 1,
    method_count: 1,
    methods: addr xdg_popup_requests[0],
    event_count: 1,
    events: addr xdg_popup_events[0],
  )


type XdgShellVersion* {.size: sizeof(uint32).} = enum
  version_current = 5
func since*(e: XdgShellVersion): int =
  case e
  of version_current: 1
proc isValid*(e: XdgShellVersion; version: int): bool =
  version >= e.since

type XdgShellError* {.size: sizeof(uint32).} = enum
  error_role = 0
  error_defunct_surfaces = 1
  error_not_the_topmost_popup = 2
  error_invalid_popup_parent = 3
func since*(e: XdgShellError): int =
  case e
  of error_role: 1
  of error_defunct_surfaces: 1
  of error_not_the_topmost_popup: 1
  of error_invalid_popup_parent: 1
proc isValid*(e: XdgShellError; version: int): bool =
  version >= e.since

type XdgSurfaceResizeEdge* {.size: sizeof(uint32).} = enum
  resize_edge_none = 0
  resize_edge_top = 1
  resize_edge_bottom = 2
  resize_edge_left = 4
  resize_edge_top_left = 5
  resize_edge_bottom_left = 6
  resize_edge_right = 8
  resize_edge_top_right = 9
  resize_edge_bottom_right = 10
func since*(e: XdgSurfaceResizeEdge): int =
  case e
  of resize_edge_none: 1
  of resize_edge_top: 1
  of resize_edge_bottom: 1
  of resize_edge_left: 1
  of resize_edge_top_left: 1
  of resize_edge_bottom_left: 1
  of resize_edge_right: 1
  of resize_edge_top_right: 1
  of resize_edge_bottom_right: 1
proc isValid*(e: XdgSurfaceResizeEdge; version: int): bool =
  version >= e.since

type XdgSurfaceState* {.size: sizeof(uint32).} = enum
  state_maximized = 1
  state_fullscreen = 2
  state_resizing = 3
  state_activated = 4
func since*(e: XdgSurfaceState): int =
  case e
  of state_maximized: 1
  of state_fullscreen: 1
  of state_resizing: 1
  of state_activated: 1
proc isValid*(e: XdgSurfaceState; version: int): bool =
  version >= e.since

type XdgShellEvent* {.size: sizeof(uint32).} = enum
  XdgShellEvent_ping
proc since*(e: XdgShellEvent): int =
  case e
  of XdgShellEvent_ping: 1

type XdgShellRequest* {.size: sizeof(uint32).} = enum
  XdgShellRequest_destroy
  XdgShellRequest_use_unstable_version
  XdgShellRequest_get_xdg_surface
  XdgShellRequest_get_xdg_popup
  XdgShellRequest_pong
proc since*(e: XdgShellRequest): int =
  case e
  of XdgShellRequest_destroy: 1
  of XdgShellRequest_use_unstable_version: 1
  of XdgShellRequest_get_xdg_surface: 1
  of XdgShellRequest_get_xdg_popup: 1
  of XdgShellRequest_pong: 1

type XdgSurfaceEvent* {.size: sizeof(uint32).} = enum
  XdgSurfaceEvent_configure
  XdgSurfaceEvent_close
proc since*(e: XdgSurfaceEvent): int =
  case e
  of XdgSurfaceEvent_configure: 1
  of XdgSurfaceEvent_close: 1

type XdgSurfaceRequest* {.size: sizeof(uint32).} = enum
  XdgSurfaceRequest_destroy
  XdgSurfaceRequest_set_parent
  XdgSurfaceRequest_set_title
  XdgSurfaceRequest_set_app_id
  XdgSurfaceRequest_show_window_menu
  XdgSurfaceRequest_move
  XdgSurfaceRequest_resize
  XdgSurfaceRequest_ack_configure
  XdgSurfaceRequest_set_window_geometry
  XdgSurfaceRequest_set_maximized
  XdgSurfaceRequest_unset_maximized
  XdgSurfaceRequest_set_fullscreen
  XdgSurfaceRequest_unset_fullscreen
  XdgSurfaceRequest_set_minimized
proc since*(e: XdgSurfaceRequest): int =
  case e
  of XdgSurfaceRequest_destroy: 1
  of XdgSurfaceRequest_set_parent: 1
  of XdgSurfaceRequest_set_title: 1
  of XdgSurfaceRequest_set_app_id: 1
  of XdgSurfaceRequest_show_window_menu: 1
  of XdgSurfaceRequest_move: 1
  of XdgSurfaceRequest_resize: 1
  of XdgSurfaceRequest_ack_configure: 1
  of XdgSurfaceRequest_set_window_geometry: 1
  of XdgSurfaceRequest_set_maximized: 1
  of XdgSurfaceRequest_unset_maximized: 1
  of XdgSurfaceRequest_set_fullscreen: 1
  of XdgSurfaceRequest_unset_fullscreen: 1
  of XdgSurfaceRequest_set_minimized: 1

type XdgPopupEvent* {.size: sizeof(uint32).} = enum
  XdgPopupEvent_popup_done
proc since*(e: XdgPopupEvent): int =
  case e
  of XdgPopupEvent_popup_done: 1

type XdgPopupRequest* {.size: sizeof(uint32).} = enum
  XdgPopupRequest_destroy
proc since*(e: XdgPopupRequest): int =
  case e
  of XdgPopupRequest_destroy: 1

xdgShellUnstableV5_types = [
  nil,
  nil,
  nil,
  nil,
  addr xdg_surface_interface,
  addr wl_surface_interface,
  addr xdg_popup_interface,
  addr wl_surface_interface,
  addr wl_surface_interface,
  addr wl_seat_interface,
  nil,
  nil,
  nil,
  addr xdg_surface_interface,
  addr wl_seat_interface,
  nil,
  nil,
  nil,
  addr wl_seat_interface,
  nil,
  addr wl_seat_interface,
  nil,
  nil,
  addr wl_output_interface,
]


