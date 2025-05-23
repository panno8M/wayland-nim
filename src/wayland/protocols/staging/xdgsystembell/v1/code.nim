# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var xdgSystemBellV1_types: array[1, ptr Interface]
type XdgSystemBellV1* = object

let
  xdg_system_bell_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr xdg_system_bell_v1_types[0]),
    Message(name: "ring", signature: "?o", types: addr xdg_system_bell_v1_types[0]),
  ]

  xdg_system_bell_v1_interface* {.exportc.} = Interface(
    name: "xdg_system_bell_v1",
    version: 1,
    method_count: 2,
    methods: addr xdg_system_bell_v1_requests[0],
  )


type XdgSystemBellV1Request* {.size: sizeof(uint32).} = enum
  XdgSystemBellV1Request_destroy
  XdgSystemBellV1Request_ring
proc since*(e: XdgSystemBellV1Request): int =
  case e
  of XdgSystemBellV1Request_destroy: 1
  of XdgSystemBellV1Request_ring: 1

xdgSystemBellV1_types = [
  addr wl_surface_interface,
]


