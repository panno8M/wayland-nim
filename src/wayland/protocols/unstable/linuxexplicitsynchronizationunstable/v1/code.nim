# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/common
import wayland/protocols/wayland/code as wayland_code

var zwpLinuxExplicitSynchronizationUnstableV1_types: array[4, ptr Interface]
type ZwpLinuxBufferReleaseV1* = object
type ZwpLinuxExplicitSynchronizationV1* = object
type ZwpLinuxSurfaceSynchronizationV1* = object

let
  zwp_linux_explicit_synchronization_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[0]),
    Message(name: "get_synchronization", signature: "no", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[1]),
  ]

  zwp_linux_explicit_synchronization_v1_interface* {.exportc.} = Interface(
    name: "zwp_linux_explicit_synchronization_v1",
    version: 2,
    method_count: 2,
    methods: addr zwp_linux_explicit_synchronization_v1_requests[0],
  )

  zwp_linux_surface_synchronization_v1_requests {.exportc.} = [
    Message(name: "destroy", signature: "", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[0]),
    Message(name: "set_acquire_fence", signature: "h", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[0]),
    Message(name: "get_release", signature: "n", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[3]),
  ]

  zwp_linux_surface_synchronization_v1_interface* {.exportc.} = Interface(
    name: "zwp_linux_surface_synchronization_v1",
    version: 2,
    method_count: 3,
    methods: addr zwp_linux_surface_synchronization_v1_requests[0],
  )

  zwp_linux_buffer_release_v1_events {.exportc.} = [
    Message(name: "fenced_release", signature: "h", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[0]),
    Message(name: "immediate_release", signature: "", types: addr zwp_linux_explicit_synchronization_unstable_v1_types[0]),
  ]

  zwp_linux_buffer_release_v1_interface* {.exportc.} = Interface(
    name: "zwp_linux_buffer_release_v1",
    version: 1,
    event_count: 2,
    events: addr zwp_linux_buffer_release_v1_events[0],
  )


type ZwpLinuxExplicitSynchronizationV1Error* {.size: sizeof(uint32).} = enum
  error_synchronization_exists = 0
func since*(e: ZwpLinuxExplicitSynchronizationV1Error): int =
  case e
  of error_synchronization_exists: 1
proc isValid*(e: ZwpLinuxExplicitSynchronizationV1Error; version: int): bool =
  version >= e.since

type ZwpLinuxSurfaceSynchronizationV1Error* {.size: sizeof(uint32).} = enum
  error_invalid_fence = 0
  error_duplicate_fence = 1
  error_duplicate_release = 2
  error_no_surface = 3
  error_unsupported_buffer = 4
  error_no_buffer = 5
func since*(e: ZwpLinuxSurfaceSynchronizationV1Error): int =
  case e
  of error_invalid_fence: 1
  of error_duplicate_fence: 1
  of error_duplicate_release: 1
  of error_no_surface: 1
  of error_unsupported_buffer: 1
  of error_no_buffer: 1
proc isValid*(e: ZwpLinuxSurfaceSynchronizationV1Error; version: int): bool =
  version >= e.since

type ZwpLinuxExplicitSynchronizationV1Request* {.size: sizeof(uint32).} = enum
  ZwpLinuxExplicitSynchronizationV1Request_destroy
  ZwpLinuxExplicitSynchronizationV1Request_get_synchronization
proc since*(e: ZwpLinuxExplicitSynchronizationV1Request): int =
  case e
  of ZwpLinuxExplicitSynchronizationV1Request_destroy: 1
  of ZwpLinuxExplicitSynchronizationV1Request_get_synchronization: 1

type ZwpLinuxSurfaceSynchronizationV1Request* {.size: sizeof(uint32).} = enum
  ZwpLinuxSurfaceSynchronizationV1Request_destroy
  ZwpLinuxSurfaceSynchronizationV1Request_set_acquire_fence
  ZwpLinuxSurfaceSynchronizationV1Request_get_release
proc since*(e: ZwpLinuxSurfaceSynchronizationV1Request): int =
  case e
  of ZwpLinuxSurfaceSynchronizationV1Request_destroy: 1
  of ZwpLinuxSurfaceSynchronizationV1Request_set_acquire_fence: 1
  of ZwpLinuxSurfaceSynchronizationV1Request_get_release: 1

type ZwpLinuxBufferReleaseV1Event* {.size: sizeof(uint32).} = enum
  ZwpLinuxBufferReleaseV1Event_fenced_release
  ZwpLinuxBufferReleaseV1Event_immediate_release
proc since*(e: ZwpLinuxBufferReleaseV1Event): int =
  case e
  of ZwpLinuxBufferReleaseV1Event_fenced_release: 1
  of ZwpLinuxBufferReleaseV1Event_immediate_release: 1

zwpLinuxExplicitSynchronizationUnstableV1_types = [
  nil,
  addr zwp_linux_surface_synchronization_v1_interface,
  addr wl_surface_interface,
  addr zwp_linux_buffer_release_v1_interface,
]


