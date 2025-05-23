# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var tabletUnstableV1_types: array[14, ptr Interface]
type ZwpTabletManagerV1* = object
type ZwpTabletSeatV1* = object
type ZwpTabletToolV1* = object
type ZwpTabletV1* = object

let
  zwp_tablet_manager_v1_requests {.exportc.} = [
    Message(name: "get_tablet_seat", signature: "no", types: addr tablet_unstable_v1_types[3]),
    Message(name: "destroy", signature: "", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_manager_v1_interface* {.exportc.} = Interface(
    name: "zwp_tablet_manager_v1",
    version: 1,
    method_count: 2,
    methods: addr zwp_tablet_manager_v1_requests[0],
  )

  zwp_tablet_seat_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_seat_v1_events {.exportc.} = [
    Message(name: "tablet_added", signature: "n", types: addr tablet_unstable_v1_types[5]),
    Message(name: "tool_added", signature: "n", types: addr tablet_unstable_v1_types[6]),
  ]

  zwp_tablet_seat_v1_interface* {.exportc.} = Interface(
    name: "zwp_tablet_seat_v1",
    version: 1,
    method_count: 1,
    methods: addr zwp_tablet_seat_v1_requests[0],
    event_count: 2,
    events: addr zwp_tablet_seat_v1_events[0],
  )

  zwp_tablet_tool_v1_requests {.exportc.} = [
    Message(name: "set_cursor", signature: "u?oii", types: addr tablet_unstable_v1_types[7]),
    Message(name: "destroy", signature: "", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_tool_v1_events {.exportc.} = [
    Message(name: "type", signature: "u", types: addr tablet_unstable_v1_types[0]),
    Message(name: "hardware_serial", signature: "uu", types: addr tablet_unstable_v1_types[0]),
    Message(name: "hardware_id_wacom", signature: "uu", types: addr tablet_unstable_v1_types[0]),
    Message(name: "capability", signature: "u", types: addr tablet_unstable_v1_types[0]),
    Message(name: "done", signature: "", types: addr tablet_unstable_v1_types[0]),
    Message(name: "removed", signature: "", types: addr tablet_unstable_v1_types[0]),
    Message(name: "proximity_in", signature: "uoo", types: addr tablet_unstable_v1_types[11]),
    Message(name: "proximity_out", signature: "", types: addr tablet_unstable_v1_types[0]),
    Message(name: "down", signature: "u", types: addr tablet_unstable_v1_types[0]),
    Message(name: "up", signature: "", types: addr tablet_unstable_v1_types[0]),
    Message(name: "motion", signature: "ff", types: addr tablet_unstable_v1_types[0]),
    Message(name: "pressure", signature: "u", types: addr tablet_unstable_v1_types[0]),
    Message(name: "distance", signature: "u", types: addr tablet_unstable_v1_types[0]),
    Message(name: "tilt", signature: "ii", types: addr tablet_unstable_v1_types[0]),
    Message(name: "rotation", signature: "i", types: addr tablet_unstable_v1_types[0]),
    Message(name: "slider", signature: "i", types: addr tablet_unstable_v1_types[0]),
    Message(name: "wheel", signature: "ii", types: addr tablet_unstable_v1_types[0]),
    Message(name: "button", signature: "uuu", types: addr tablet_unstable_v1_types[0]),
    Message(name: "frame", signature: "u", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_tool_v1_interface* {.exportc.} = Interface(
    name: "zwp_tablet_tool_v1",
    version: 1,
    method_count: 2,
    methods: addr zwp_tablet_tool_v1_requests[0],
    event_count: 19,
    events: addr zwp_tablet_tool_v1_events[0],
  )

  zwp_tablet_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_v1_events {.exportc.} = [
    Message(name: "name", signature: "s", types: addr tablet_unstable_v1_types[0]),
    Message(name: "id", signature: "uu", types: addr tablet_unstable_v1_types[0]),
    Message(name: "path", signature: "s", types: addr tablet_unstable_v1_types[0]),
    Message(name: "done", signature: "", types: addr tablet_unstable_v1_types[0]),
    Message(name: "removed", signature: "", types: addr tablet_unstable_v1_types[0]),
  ]

  zwp_tablet_v1_interface* {.exportc.} = Interface(
    name: "zwp_tablet_v1",
    version: 1,
    method_count: 1,
    methods: addr zwp_tablet_v1_requests[0],
    event_count: 5,
    events: addr zwp_tablet_v1_events[0],
  )


type ZwpTabletToolV1Type* {.size: sizeof(uint32).} = enum
  type_pen = 0x140
  type_eraser = 0x141
  type_brush = 0x142
  type_pencil = 0x143
  type_airbrush = 0x144
  type_finger = 0x145
  type_mouse = 0x146
  type_lens = 0x147
func since*(e: ZwpTabletToolV1Type): int =
  case e
  of type_pen: 1
  of type_eraser: 1
  of type_brush: 1
  of type_pencil: 1
  of type_airbrush: 1
  of type_finger: 1
  of type_mouse: 1
  of type_lens: 1
proc isValid*(e: ZwpTabletToolV1Type; version: int): bool =
  version >= e.since

type ZwpTabletToolV1Capability* {.size: sizeof(uint32).} = enum
  capability_tilt = 1
  capability_pressure = 2
  capability_distance = 3
  capability_rotation = 4
  capability_slider = 5
  capability_wheel = 6
func since*(e: ZwpTabletToolV1Capability): int =
  case e
  of capability_tilt: 1
  of capability_pressure: 1
  of capability_distance: 1
  of capability_rotation: 1
  of capability_slider: 1
  of capability_wheel: 1
proc isValid*(e: ZwpTabletToolV1Capability; version: int): bool =
  version >= e.since

type ZwpTabletToolV1ButtonState* {.size: sizeof(uint32).} = enum
  button_state_released = 0
  button_state_pressed = 1
func since*(e: ZwpTabletToolV1ButtonState): int =
  case e
  of button_state_released: 1
  of button_state_pressed: 1
proc isValid*(e: ZwpTabletToolV1ButtonState; version: int): bool =
  version >= e.since

type ZwpTabletToolV1Error* {.size: sizeof(uint32).} = enum
  error_role = 0
func since*(e: ZwpTabletToolV1Error): int =
  case e
  of error_role: 1
proc isValid*(e: ZwpTabletToolV1Error; version: int): bool =
  version >= e.since

type ZwpTabletManagerV1Request* {.size: sizeof(uint32).} = enum
  ZwpTabletManagerV1Request_get_tablet_seat
  ZwpTabletManagerV1Request_destroy
proc since*(e: ZwpTabletManagerV1Request): int =
  case e
  of ZwpTabletManagerV1Request_get_tablet_seat: 1
  of ZwpTabletManagerV1Request_destroy: 1

type ZwpTabletSeatV1Event* {.size: sizeof(uint32).} = enum
  ZwpTabletSeatV1Event_tablet_added
  ZwpTabletSeatV1Event_tool_added
proc since*(e: ZwpTabletSeatV1Event): int =
  case e
  of ZwpTabletSeatV1Event_tablet_added: 1
  of ZwpTabletSeatV1Event_tool_added: 1

type ZwpTabletSeatV1Request* {.size: sizeof(uint32).} = enum
  ZwpTabletSeatV1Request_destroy
proc since*(e: ZwpTabletSeatV1Request): int =
  case e
  of ZwpTabletSeatV1Request_destroy: 1

type ZwpTabletToolV1Event* {.size: sizeof(uint32).} = enum
  ZwpTabletToolV1Event_type
  ZwpTabletToolV1Event_hardware_serial
  ZwpTabletToolV1Event_hardware_id_wacom
  ZwpTabletToolV1Event_capability
  ZwpTabletToolV1Event_done
  ZwpTabletToolV1Event_removed
  ZwpTabletToolV1Event_proximity_in
  ZwpTabletToolV1Event_proximity_out
  ZwpTabletToolV1Event_down
  ZwpTabletToolV1Event_up
  ZwpTabletToolV1Event_motion
  ZwpTabletToolV1Event_pressure
  ZwpTabletToolV1Event_distance
  ZwpTabletToolV1Event_tilt
  ZwpTabletToolV1Event_rotation
  ZwpTabletToolV1Event_slider
  ZwpTabletToolV1Event_wheel
  ZwpTabletToolV1Event_button
  ZwpTabletToolV1Event_frame
proc since*(e: ZwpTabletToolV1Event): int =
  case e
  of ZwpTabletToolV1Event_type: 1
  of ZwpTabletToolV1Event_hardware_serial: 1
  of ZwpTabletToolV1Event_hardware_id_wacom: 1
  of ZwpTabletToolV1Event_capability: 1
  of ZwpTabletToolV1Event_done: 1
  of ZwpTabletToolV1Event_removed: 1
  of ZwpTabletToolV1Event_proximity_in: 1
  of ZwpTabletToolV1Event_proximity_out: 1
  of ZwpTabletToolV1Event_down: 1
  of ZwpTabletToolV1Event_up: 1
  of ZwpTabletToolV1Event_motion: 1
  of ZwpTabletToolV1Event_pressure: 1
  of ZwpTabletToolV1Event_distance: 1
  of ZwpTabletToolV1Event_tilt: 1
  of ZwpTabletToolV1Event_rotation: 1
  of ZwpTabletToolV1Event_slider: 1
  of ZwpTabletToolV1Event_wheel: 1
  of ZwpTabletToolV1Event_button: 1
  of ZwpTabletToolV1Event_frame: 1

type ZwpTabletToolV1Request* {.size: sizeof(uint32).} = enum
  ZwpTabletToolV1Request_set_cursor
  ZwpTabletToolV1Request_destroy
proc since*(e: ZwpTabletToolV1Request): int =
  case e
  of ZwpTabletToolV1Request_set_cursor: 1
  of ZwpTabletToolV1Request_destroy: 1

type ZwpTabletV1Event* {.size: sizeof(uint32).} = enum
  ZwpTabletV1Event_name
  ZwpTabletV1Event_id
  ZwpTabletV1Event_path
  ZwpTabletV1Event_done
  ZwpTabletV1Event_removed
proc since*(e: ZwpTabletV1Event): int =
  case e
  of ZwpTabletV1Event_name: 1
  of ZwpTabletV1Event_id: 1
  of ZwpTabletV1Event_path: 1
  of ZwpTabletV1Event_done: 1
  of ZwpTabletV1Event_removed: 1

type ZwpTabletV1Request* {.size: sizeof(uint32).} = enum
  ZwpTabletV1Request_destroy
proc since*(e: ZwpTabletV1Request): int =
  case e
  of ZwpTabletV1Request_destroy: 1

tabletUnstableV1_types = [
  nil,
  nil,
  nil,
  addr zwp_tablet_seat_v1_interface,
  addr wl_seat_interface,
  addr zwp_tablet_v1_interface,
  addr zwp_tablet_tool_v1_interface,
  nil,
  addr wl_surface_interface,
  nil,
  nil,
  nil,
  addr zwp_tablet_v1_interface,
  addr wl_surface_interface,
]


