# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var xdgShellUnstableV6_types: array[24, ptr Interface]
type ZxdgPopupV6* = object
type ZxdgPositionerV6* = object
type ZxdgShellV6* = object
type ZxdgSurfaceV6* = object
type ZxdgToplevelV6* = object

let
  zxdg_shell_v6_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "create_positioner", signature: "n", types: addr xdg_shell_unstable_v6_types[4]),
    Message(name: "get_xdg_surface", signature: "no", types: addr xdg_shell_unstable_v6_types[5]),
    Message(name: "pong", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_shell_v6_events {.exportc.} = [
    Message(name: "ping", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_shell_v6_interface* {.exportc.} = Interface(
    name: "zxdg_shell_v6",
    version: 1,
    method_count: 4,
    methods: addr zxdg_shell_v6_requests[0],
    event_count: 1,
    events: addr zxdg_shell_v6_events[0],
  )

  zxdg_positioner_v6_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_size", signature: "ii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_anchor_rect", signature: "iiii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_anchor", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_gravity", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_constraint_adjustment", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_offset", signature: "ii", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_positioner_v6_interface* {.exportc.} = Interface(
    name: "zxdg_positioner_v6",
    version: 1,
    method_count: 7,
    methods: addr zxdg_positioner_v6_requests[0],
  )

  zxdg_surface_v6_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "get_toplevel", signature: "n", types: addr xdg_shell_unstable_v6_types[7]),
    Message(name: "get_popup", signature: "noo", types: addr xdg_shell_unstable_v6_types[8]),
    Message(name: "set_window_geometry", signature: "iiii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "ack_configure", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_surface_v6_events {.exportc.} = [
    Message(name: "configure", signature: "u", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_surface_v6_interface* {.exportc.} = Interface(
    name: "zxdg_surface_v6",
    version: 1,
    method_count: 5,
    methods: addr zxdg_surface_v6_requests[0],
    event_count: 1,
    events: addr zxdg_surface_v6_events[0],
  )

  zxdg_toplevel_v6_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_parent", signature: "?o", types: addr xdg_shell_unstable_v6_types[11]),
    Message(name: "set_title", signature: "s", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_app_id", signature: "s", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "show_window_menu", signature: "ouii", types: addr xdg_shell_unstable_v6_types[12]),
    Message(name: "move", signature: "ou", types: addr xdg_shell_unstable_v6_types[16]),
    Message(name: "resize", signature: "ouu", types: addr xdg_shell_unstable_v6_types[18]),
    Message(name: "set_max_size", signature: "ii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_min_size", signature: "ii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_maximized", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "unset_maximized", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_fullscreen", signature: "?o", types: addr xdg_shell_unstable_v6_types[21]),
    Message(name: "unset_fullscreen", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "set_minimized", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_toplevel_v6_events {.exportc.} = [
    Message(name: "configure", signature: "iia", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "close", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_toplevel_v6_interface* {.exportc.} = Interface(
    name: "zxdg_toplevel_v6",
    version: 1,
    method_count: 14,
    methods: addr zxdg_toplevel_v6_requests[0],
    event_count: 2,
    events: addr zxdg_toplevel_v6_events[0],
  )

  zxdg_popup_v6_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "grab", signature: "ou", types: addr xdg_shell_unstable_v6_types[22]),
  ]

  zxdg_popup_v6_events {.exportc.} = [
    Message(name: "configure", signature: "iiii", types: addr xdg_shell_unstable_v6_types[0]),
    Message(name: "popup_done", signature: "", types: addr xdg_shell_unstable_v6_types[0]),
  ]

  zxdg_popup_v6_interface* {.exportc.} = Interface(
    name: "zxdg_popup_v6",
    version: 1,
    method_count: 2,
    methods: addr zxdg_popup_v6_requests[0],
    event_count: 2,
    events: addr zxdg_popup_v6_events[0],
  )


type ZxdgShellV6Error* {.size: sizeof(uint32).} = enum
  error_role = 0
  error_defunct_surfaces = 1
  error_not_the_topmost_popup = 2
  error_invalid_popup_parent = 3
  error_invalid_surface_state = 4
  error_invalid_positioner = 5
func since*(e: ZxdgShellV6Error): int =
  case e
  of error_role: 1
  of error_defunct_surfaces: 1
  of error_not_the_topmost_popup: 1
  of error_invalid_popup_parent: 1
  of error_invalid_surface_state: 1
  of error_invalid_positioner: 1
proc isValid*(e: ZxdgShellV6Error; version: int): bool =
  version >= e.since

type ZxdgPositionerV6Error* {.size: sizeof(uint32).} = enum
  error_invalid_input = 0
func since*(e: ZxdgPositionerV6Error): int =
  case e
  of error_invalid_input: 1
proc isValid*(e: ZxdgPositionerV6Error; version: int): bool =
  version >= e.since

type ZxdgPositionerV6Anchor* {.size: sizeof(uint32).} = enum
  anchor_none = 0
  anchor_top = 1
  anchor_bottom = 2
  anchor_left = 4
  anchor_right = 8
func since*(e: ZxdgPositionerV6Anchor): int =
  case e
  of anchor_none: 1
  of anchor_top: 1
  of anchor_bottom: 1
  of anchor_left: 1
  of anchor_right: 1
proc isValid*(e: ZxdgPositionerV6Anchor; version: int): bool =
  version >= e.since

type ZxdgPositionerV6Gravity* {.size: sizeof(uint32).} = enum
  gravity_none = 0
  gravity_top = 1
  gravity_bottom = 2
  gravity_left = 4
  gravity_right = 8
func since*(e: ZxdgPositionerV6Gravity): int =
  case e
  of gravity_none: 1
  of gravity_top: 1
  of gravity_bottom: 1
  of gravity_left: 1
  of gravity_right: 1
proc isValid*(e: ZxdgPositionerV6Gravity; version: int): bool =
  version >= e.since

type ZxdgPositionerV6ConstraintAdjustment* {.size: sizeof(uint32).} = enum
  constraint_adjustment_none = 0
  constraint_adjustment_slide_x = 1
  constraint_adjustment_slide_y = 2
  constraint_adjustment_flip_x = 4
  constraint_adjustment_flip_y = 8
  constraint_adjustment_resize_x = 16
  constraint_adjustment_resize_y = 32
func since*(e: ZxdgPositionerV6ConstraintAdjustment): int =
  case e
  of constraint_adjustment_none: 1
  of constraint_adjustment_slide_x: 1
  of constraint_adjustment_slide_y: 1
  of constraint_adjustment_flip_x: 1
  of constraint_adjustment_flip_y: 1
  of constraint_adjustment_resize_x: 1
  of constraint_adjustment_resize_y: 1
proc isValid*(e: ZxdgPositionerV6ConstraintAdjustment; version: int): bool =
  version >= e.since

type ZxdgSurfaceV6Error* {.size: sizeof(uint32).} = enum
  error_not_constructed = 1
  error_already_constructed = 2
  error_unconfigured_buffer = 3
func since*(e: ZxdgSurfaceV6Error): int =
  case e
  of error_not_constructed: 1
  of error_already_constructed: 1
  of error_unconfigured_buffer: 1
proc isValid*(e: ZxdgSurfaceV6Error; version: int): bool =
  version >= e.since

type ZxdgToplevelV6ResizeEdge* {.size: sizeof(uint32).} = enum
  resize_edge_none = 0
  resize_edge_top = 1
  resize_edge_bottom = 2
  resize_edge_left = 4
  resize_edge_top_left = 5
  resize_edge_bottom_left = 6
  resize_edge_right = 8
  resize_edge_top_right = 9
  resize_edge_bottom_right = 10
func since*(e: ZxdgToplevelV6ResizeEdge): int =
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
proc isValid*(e: ZxdgToplevelV6ResizeEdge; version: int): bool =
  version >= e.since

type ZxdgToplevelV6State* {.size: sizeof(uint32).} = enum
  state_maximized = 1
  state_fullscreen = 2
  state_resizing = 3
  state_activated = 4
func since*(e: ZxdgToplevelV6State): int =
  case e
  of state_maximized: 1
  of state_fullscreen: 1
  of state_resizing: 1
  of state_activated: 1
proc isValid*(e: ZxdgToplevelV6State; version: int): bool =
  version >= e.since

type ZxdgPopupV6Error* {.size: sizeof(uint32).} = enum
  error_invalid_grab = 0
func since*(e: ZxdgPopupV6Error): int =
  case e
  of error_invalid_grab: 1
proc isValid*(e: ZxdgPopupV6Error; version: int): bool =
  version >= e.since

type ZxdgShellV6Event* {.size: sizeof(uint32).} = enum
  ZxdgShellV6Event_ping
proc since*(e: ZxdgShellV6Event): int =
  case e
  of ZxdgShellV6Event_ping: 1

type ZxdgShellV6Request* {.size: sizeof(uint32).} = enum
  ZxdgShellV6Request_destroy
  ZxdgShellV6Request_create_positioner
  ZxdgShellV6Request_get_xdg_surface
  ZxdgShellV6Request_pong
proc since*(e: ZxdgShellV6Request): int =
  case e
  of ZxdgShellV6Request_destroy: 1
  of ZxdgShellV6Request_create_positioner: 1
  of ZxdgShellV6Request_get_xdg_surface: 1
  of ZxdgShellV6Request_pong: 1

type ZxdgPositionerV6Request* {.size: sizeof(uint32).} = enum
  ZxdgPositionerV6Request_destroy
  ZxdgPositionerV6Request_set_size
  ZxdgPositionerV6Request_set_anchor_rect
  ZxdgPositionerV6Request_set_anchor
  ZxdgPositionerV6Request_set_gravity
  ZxdgPositionerV6Request_set_constraint_adjustment
  ZxdgPositionerV6Request_set_offset
proc since*(e: ZxdgPositionerV6Request): int =
  case e
  of ZxdgPositionerV6Request_destroy: 1
  of ZxdgPositionerV6Request_set_size: 1
  of ZxdgPositionerV6Request_set_anchor_rect: 1
  of ZxdgPositionerV6Request_set_anchor: 1
  of ZxdgPositionerV6Request_set_gravity: 1
  of ZxdgPositionerV6Request_set_constraint_adjustment: 1
  of ZxdgPositionerV6Request_set_offset: 1

type ZxdgSurfaceV6Event* {.size: sizeof(uint32).} = enum
  ZxdgSurfaceV6Event_configure
proc since*(e: ZxdgSurfaceV6Event): int =
  case e
  of ZxdgSurfaceV6Event_configure: 1

type ZxdgSurfaceV6Request* {.size: sizeof(uint32).} = enum
  ZxdgSurfaceV6Request_destroy
  ZxdgSurfaceV6Request_get_toplevel
  ZxdgSurfaceV6Request_get_popup
  ZxdgSurfaceV6Request_set_window_geometry
  ZxdgSurfaceV6Request_ack_configure
proc since*(e: ZxdgSurfaceV6Request): int =
  case e
  of ZxdgSurfaceV6Request_destroy: 1
  of ZxdgSurfaceV6Request_get_toplevel: 1
  of ZxdgSurfaceV6Request_get_popup: 1
  of ZxdgSurfaceV6Request_set_window_geometry: 1
  of ZxdgSurfaceV6Request_ack_configure: 1

type ZxdgToplevelV6Event* {.size: sizeof(uint32).} = enum
  ZxdgToplevelV6Event_configure
  ZxdgToplevelV6Event_close
proc since*(e: ZxdgToplevelV6Event): int =
  case e
  of ZxdgToplevelV6Event_configure: 1
  of ZxdgToplevelV6Event_close: 1

type ZxdgToplevelV6Request* {.size: sizeof(uint32).} = enum
  ZxdgToplevelV6Request_destroy
  ZxdgToplevelV6Request_set_parent
  ZxdgToplevelV6Request_set_title
  ZxdgToplevelV6Request_set_app_id
  ZxdgToplevelV6Request_show_window_menu
  ZxdgToplevelV6Request_move
  ZxdgToplevelV6Request_resize
  ZxdgToplevelV6Request_set_max_size
  ZxdgToplevelV6Request_set_min_size
  ZxdgToplevelV6Request_set_maximized
  ZxdgToplevelV6Request_unset_maximized
  ZxdgToplevelV6Request_set_fullscreen
  ZxdgToplevelV6Request_unset_fullscreen
  ZxdgToplevelV6Request_set_minimized
proc since*(e: ZxdgToplevelV6Request): int =
  case e
  of ZxdgToplevelV6Request_destroy: 1
  of ZxdgToplevelV6Request_set_parent: 1
  of ZxdgToplevelV6Request_set_title: 1
  of ZxdgToplevelV6Request_set_app_id: 1
  of ZxdgToplevelV6Request_show_window_menu: 1
  of ZxdgToplevelV6Request_move: 1
  of ZxdgToplevelV6Request_resize: 1
  of ZxdgToplevelV6Request_set_max_size: 1
  of ZxdgToplevelV6Request_set_min_size: 1
  of ZxdgToplevelV6Request_set_maximized: 1
  of ZxdgToplevelV6Request_unset_maximized: 1
  of ZxdgToplevelV6Request_set_fullscreen: 1
  of ZxdgToplevelV6Request_unset_fullscreen: 1
  of ZxdgToplevelV6Request_set_minimized: 1

type ZxdgPopupV6Event* {.size: sizeof(uint32).} = enum
  ZxdgPopupV6Event_configure
  ZxdgPopupV6Event_popup_done
proc since*(e: ZxdgPopupV6Event): int =
  case e
  of ZxdgPopupV6Event_configure: 1
  of ZxdgPopupV6Event_popup_done: 1

type ZxdgPopupV6Request* {.size: sizeof(uint32).} = enum
  ZxdgPopupV6Request_destroy
  ZxdgPopupV6Request_grab
proc since*(e: ZxdgPopupV6Request): int =
  case e
  of ZxdgPopupV6Request_destroy: 1
  of ZxdgPopupV6Request_grab: 1

xdgShellUnstableV6_types = [
  nil,
  nil,
  nil,
  nil,
  addr zxdg_positioner_v6_interface,
  addr zxdg_surface_v6_interface,
  addr wl_surface_interface,
  addr zxdg_toplevel_v6_interface,
  addr zxdg_popup_v6_interface,
  addr zxdg_surface_v6_interface,
  addr zxdg_positioner_v6_interface,
  addr zxdg_toplevel_v6_interface,
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
  addr wl_seat_interface,
  nil,
]


