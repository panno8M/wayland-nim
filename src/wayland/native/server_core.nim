import common
type
  Resource* {.bycopy.} = object
    `object`*: Object
    destroy*: destroy_func_t
    link*: List
    destroy_signal*: Signal
    client*: ptr Client
    data*: pointer
  fd_func_t* = proc (fd: cint; mask: uint32; data: pointer): cint {.nimcall.}
  timer_func_t* = proc (data: pointer): cint {.nimcall.}
  signal_func_t* = proc (signal_number: cint; data: pointer): cint {.nimcall.}
  idle_func_t* = proc (data: pointer) {.nimcall.}
  wl_notify_func_t* = proc (listener: ptr Listener; data: pointer) {.nimcall.}
  bind_func_t* = proc (client: ptr Client; data: pointer; version: uint32; id: uint32) {.
      nimcall.}
  global_filter_func_t* = proc (client: ptr Client; global: ptr Global; data: pointer): bool {.
      nimcall.}
  for_each_resource_iterator_func_t* = proc (resource: ptr Resource;
      user_data: pointer): wl_iterator_result {.nimcall.}
  wl_user_data_destroy_func_t* = proc (data: pointer) {.nimcall.}
  Listener* {.bycopy.} = object
    link*: List
    notify*: wl_notify_func_t
  Signal* {.bycopy.} = object
    listener_list*: List
  destroy_func_t* = proc (resource: ptr Resource) {.nimcall.}
  ProtocolLoggerType* {.size: sizeof(cint).} = enum
    WL_PROTOCOL_LOGGER_REQUEST, WL_PROTOCOL_LOGGER_EVENT
  ProtocolLoggerMessage* {.bycopy.} = object
    resource*: ptr Resource
    message_opcode*: cint
    message*: ptr Message
    arguments_count*: cint
    arguments*: ptr Argument
  func_t* = proc (user_data: pointer; direction: ProtocolLoggerType;
               message: ptr ProtocolLoggerMessage) {.nimcall.}
const
  WL_EVENT_READABLE* = 0x01
  WL_EVENT_WRITABLE* = 0x02
  WL_EVENT_HANGUP* = 0x04
  WL_EVENT_ERROR* = 0x08
proc create_event_loop*(): ptr EventLoop {.nimcall, importc: "wl_event_loop_create",
                                       dynlib: "libwayland-server.so".}
proc destroy*(loop: ptr EventLoop) {.nimcall, importc: "wl_event_loop_destroy",
                                 dynlib: "libwayland-server.so".}
proc add_fd*(loop: ptr EventLoop; fd: cint; mask: uint32; `func`: fd_func_t; data: pointer): ptr EventSource {.
    nimcall, importc: "wl_event_loop_add_fd", dynlib: "libwayland-server.so".}
proc fd_update*(source: ptr EventSource; mask: uint32): cint {.nimcall,
    importc: "wl_event_source_fd_update", dynlib: "libwayland-server.so".}
proc add_timer*(loop: ptr EventLoop; `func`: timer_func_t; data: pointer): ptr EventSource {.
    nimcall, importc: "wl_event_loop_add_timer", dynlib: "libwayland-server.so".}
proc add_signal*(loop: ptr EventLoop; signal_number: cint; `func`: signal_func_t;
                data: pointer): ptr EventSource {.nimcall,
    importc: "wl_event_loop_add_signal", dynlib: "libwayland-server.so".}
proc timer_update*(source: ptr EventSource; ms_delay: cint): cint {.nimcall,
    importc: "wl_event_source_timer_update", dynlib: "libwayland-server.so".}
proc remove*(source: ptr EventSource): cint {.nimcall,
    importc: "wl_event_source_remove", dynlib: "libwayland-server.so".}
proc check*(source: ptr EventSource) {.nimcall, importc: "wl_event_source_check",
                                   dynlib: "libwayland-server.so".}
proc dispatch*(loop: ptr EventLoop; timeout: cint): cint {.nimcall,
    importc: "wl_event_loop_dispatch", dynlib: "libwayland-server.so".}
proc dispatch_idle*(loop: ptr EventLoop) {.nimcall,
                                       importc: "wl_event_loop_dispatch_idle",
                                       dynlib: "libwayland-server.so".}
proc add_idle*(loop: ptr EventLoop; `func`: idle_func_t; data: pointer): ptr EventSource {.
    nimcall, importc: "wl_event_loop_add_idle", dynlib: "libwayland-server.so".}
proc get_fd*(loop: ptr EventLoop): cint {.nimcall, importc: "wl_event_loop_get_fd",
                                     dynlib: "libwayland-server.so".}
discard "forward decl of wl_listener"
proc add_destroy_listener*(loop: ptr EventLoop; listener: ptr Listener) {.nimcall,
    importc: "wl_event_loop_add_destroy_listener", dynlib: "libwayland-server.so".}
proc get_destroy_listener*(loop: ptr EventLoop; notify: wl_notify_func_t): ptr Listener {.
    nimcall, importc: "wl_event_loop_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc create_display*(): ptr Display {.nimcall, importc: "wl_display_create",
                                  dynlib: "libwayland-server.so".}
proc destroy*(display: ptr Display) {.nimcall, importc: "wl_display_destroy",
                                  dynlib: "libwayland-server.so".}
proc get_event_loop*(display: ptr Display): ptr EventLoop {.nimcall,
    importc: "wl_display_get_event_loop", dynlib: "libwayland-server.so".}
proc add_socket*(display: ptr Display; name: cstring): cint {.nimcall,
    importc: "wl_display_add_socket", dynlib: "libwayland-server.so".}
proc add_socket_auto*(display: ptr Display): cstring {.nimcall,
    importc: "wl_display_add_socket_auto", dynlib: "libwayland-server.so".}
proc add_socket_fd*(display: ptr Display; sock_fd: cint): cint {.nimcall,
    importc: "wl_display_add_socket_fd", dynlib: "libwayland-server.so".}
proc terminate*(display: ptr Display) {.nimcall, importc: "wl_display_terminate",
                                    dynlib: "libwayland-server.so".}
proc run*(display: ptr Display) {.nimcall, importc: "wl_display_run",
                              dynlib: "libwayland-server.so".}
proc flush_clients*(display: ptr Display) {.nimcall,
                                        importc: "wl_display_flush_clients",
                                        dynlib: "libwayland-server.so".}
proc destroy_clients*(display: ptr Display) {.nimcall,
    importc: "wl_display_destroy_clients", dynlib: "libwayland-server.so".}
proc set_default_max_buffer_size*(display: ptr Display; max_buffer_size: csize_t) {.
    nimcall, importc: "wl_display_set_default_max_buffer_size",
    dynlib: "libwayland-server.so".}
discard "forward decl of wl_client"
proc get_serial*(display: ptr Display): uint32 {.nimcall,
    importc: "wl_display_get_serial", dynlib: "libwayland-server.so".}
proc next_serial*(display: ptr Display): uint32 {.nimcall,
    importc: "wl_display_next_serial", dynlib: "libwayland-server.so".}
proc add_destroy_listener*(display: ptr Display; listener: ptr Listener) {.nimcall,
    importc: "wl_display_add_destroy_listener", dynlib: "libwayland-server.so".}
proc add_client_created_listener*(display: ptr Display; listener: ptr Listener) {.
    nimcall, importc: "wl_display_add_client_created_listener",
    dynlib: "libwayland-server.so".}
proc get_destroy_listener*(display: ptr Display; notify: wl_notify_func_t): ptr Listener {.
    nimcall, importc: "wl_display_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc create_global*(display: ptr Display; `interface`: ptr Interface; version: cint;
                   data: pointer; `bind`: bind_func_t): ptr Global {.nimcall,
    importc: "wl_global_create", dynlib: "libwayland-server.so".}
proc remove*(global: ptr Global) {.nimcall, importc: "wl_global_remove",
                               dynlib: "libwayland-server.so".}
proc destroy*(global: ptr Global) {.nimcall, importc: "wl_global_destroy",
                                dynlib: "libwayland-server.so".}
proc set_global_filter*(display: ptr Display; filter: global_filter_func_t;
                       data: pointer) {.nimcall,
                                      importc: "wl_display_set_global_filter",
                                      dynlib: "libwayland-server.so".}
proc get_interface*(global: ptr Global): ptr Interface {.nimcall,
    importc: "wl_global_get_interface", dynlib: "libwayland-server.so".}
proc get_name*(global: ptr Global; client: ptr Client): uint32 {.nimcall,
    importc: "wl_global_get_name", dynlib: "libwayland-server.so".}
proc get_version*(global: ptr Global): uint32 {.nimcall,
    importc: "wl_global_get_version", dynlib: "libwayland-server.so".}
proc get_display*(global: ptr Global): ptr Display {.nimcall,
    importc: "wl_global_get_display", dynlib: "libwayland-server.so".}
proc get_user_data*(global: ptr Global): pointer {.nimcall,
    importc: "wl_global_get_user_data", dynlib: "libwayland-server.so".}
proc set_user_data*(global: ptr Global; data: pointer) {.nimcall,
    importc: "wl_global_set_user_data", dynlib: "libwayland-server.so".}
proc create_client*(display: ptr Display; fd: cint): ptr Client {.nimcall,
    importc: "wl_client_create", dynlib: "libwayland-server.so".}
proc get_client_list*(display: ptr Display): ptr List {.nimcall,
    importc: "wl_display_get_client_list", dynlib: "libwayland-server.so".}
proc get_link*(client: ptr Client): ptr List {.nimcall, importc: "wl_client_get_link",
    dynlib: "libwayland-server.so".}
proc client_from_link*(link: ptr List): ptr Client {.nimcall,
    importc: "wl_client_from_link", dynlib: "libwayland-server.so".}
proc destroy*(client: ptr Client) {.nimcall, importc: "wl_client_destroy",
                                dynlib: "libwayland-server.so".}
proc flush*(client: ptr Client) {.nimcall, importc: "wl_client_flush",
                              dynlib: "libwayland-server.so".}
proc get_credentials*(client: ptr Client; pid: ptr pid_t; uid: ptr uid_t; gid: ptr gid_t) {.
    nimcall, importc: "wl_client_get_credentials", dynlib: "libwayland-server.so".}
proc get_fd*(client: ptr Client): cint {.nimcall, importc: "wl_client_get_fd",
                                    dynlib: "libwayland-server.so".}
proc add_destroy_listener*(client: ptr Client; listener: ptr Listener) {.nimcall,
    importc: "wl_client_add_destroy_listener", dynlib: "libwayland-server.so".}
proc get_destroy_listener*(client: ptr Client; notify: wl_notify_func_t): ptr Listener {.
    nimcall, importc: "wl_client_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc add_destroy_late_listener*(client: ptr Client; listener: ptr Listener) {.nimcall,
    importc: "wl_client_add_destroy_late_listener", dynlib: "libwayland-server.so".}
proc get_destroy_late_listener*(client: ptr Client; notify: wl_notify_func_t): ptr Listener {.
    nimcall, importc: "wl_client_get_destroy_late_listener",
    dynlib: "libwayland-server.so".}
proc get_object*(client: ptr Client; id: uint32): ptr Resource {.nimcall,
    importc: "wl_client_get_object", dynlib: "libwayland-server.so".}
proc post_no_memory*(client: ptr Client) {.nimcall,
                                       importc: "wl_client_post_no_memory",
                                       dynlib: "libwayland-server.so".}
proc post_implementation_error*(client: ptr Client; msg: cstring) {.varargs, nimcall,
    importc: "wl_client_post_implementation_error", dynlib: "libwayland-server.so".}
proc add_resource_created_listener*(client: ptr Client; listener: ptr Listener) {.
    nimcall, importc: "wl_client_add_resource_created_listener",
    dynlib: "libwayland-server.so".}
proc for_each_resource*(client: ptr Client;
                       `iterator`: for_each_resource_iterator_func_t;
                       user_data: pointer) {.nimcall,
    importc: "wl_client_for_each_resource", dynlib: "libwayland-server.so".}
proc set_user_data*(client: ptr Client; data: pointer;
                   dtor: wl_user_data_destroy_func_t) {.nimcall,
    importc: "wl_client_set_user_data", dynlib: "libwayland-server.so".}
proc get_user_data*(client: ptr Client): pointer {.nimcall,
    importc: "wl_client_get_user_data", dynlib: "libwayland-server.so".}
proc set_max_buffer_size*(client: ptr Client; max_buffer_size: csize_t) {.nimcall,
    importc: "wl_client_set_max_buffer_size", dynlib: "libwayland-server.so".}
proc emit_mutable*(signal: ptr Signal; data: pointer) {.nimcall,
    importc: "wl_signal_emit_mutable", dynlib: "libwayland-server.so".}
include includes/signal
proc post_event*(resource: ptr Resource; opcode: uint32) {.varargs, nimcall,
    importc: "wl_resource_post_event", dynlib: "libwayland-server.so".}
proc post_event_array*(resource: ptr Resource; opcode: uint32; args: ptr Argument) {.
    nimcall, importc: "wl_resource_post_event_array", dynlib: "libwayland-server.so".}
proc queue_event*(resource: ptr Resource; opcode: uint32) {.varargs, nimcall,
    importc: "wl_resource_queue_event", dynlib: "libwayland-server.so".}
proc queue_event_array*(resource: ptr Resource; opcode: uint32; args: ptr Argument) {.
    nimcall, importc: "wl_resource_queue_event_array", dynlib: "libwayland-server.so".}
proc post_error*(resource: ptr Resource; code: uint32; msg: cstring) {.varargs, nimcall,
    importc: "wl_resource_post_error", dynlib: "libwayland-server.so".}
proc post_no_memory*(resource: ptr Resource) {.nimcall,
    importc: "wl_resource_post_no_memory", dynlib: "libwayland-server.so".}
proc get_display*(client: ptr Client): ptr Display {.nimcall,
    importc: "wl_client_get_display", dynlib: "libwayland-server.so".}
proc create_resource*(client: ptr Client; `interface`: ptr Interface; version: cint;
                     id: uint32): ptr Resource {.nimcall,
    importc: "wl_resource_create", dynlib: "libwayland-server.so".}
proc set_implementation*(resource: ptr Resource; implementation: pointer;
                        data: pointer; destroy: destroy_func_t) {.nimcall,
    importc: "wl_resource_set_implementation", dynlib: "libwayland-server.so".}
proc set_dispatcher*(resource: ptr Resource; dispatcher: wl_dispatcher_func_t;
                    implementation: pointer; data: pointer; destroy: destroy_func_t) {.
    nimcall, importc: "wl_resource_set_dispatcher", dynlib: "libwayland-server.so".}
proc destroy*(resource: ptr Resource) {.nimcall, importc: "wl_resource_destroy",
                                    dynlib: "libwayland-server.so".}
proc get_id*(resource: ptr Resource): uint32 {.nimcall, importc: "wl_resource_get_id",
    dynlib: "libwayland-server.so".}
proc get_link*(resource: ptr Resource): ptr List {.nimcall,
    importc: "wl_resource_get_link", dynlib: "libwayland-server.so".}
proc resource_from_link*(resource: ptr List): ptr Resource {.nimcall,
    importc: "wl_resource_from_link", dynlib: "libwayland-server.so".}
proc find_for_client*(list: ptr List; client: ptr Client): ptr Resource {.nimcall,
    importc: "wl_resource_find_for_client", dynlib: "libwayland-server.so".}
proc get_client*(resource: ptr Resource): ptr Client {.nimcall,
    importc: "wl_resource_get_client", dynlib: "libwayland-server.so".}
proc set_user_data*(resource: ptr Resource; data: pointer) {.nimcall,
    importc: "wl_resource_set_user_data", dynlib: "libwayland-server.so".}
proc get_user_data*(resource: ptr Resource): pointer {.nimcall,
    importc: "wl_resource_get_user_data", dynlib: "libwayland-server.so".}
proc get_version*(resource: ptr Resource): cint {.nimcall,
    importc: "wl_resource_get_version", dynlib: "libwayland-server.so".}
proc set_destructor*(resource: ptr Resource; destroy: destroy_func_t) {.nimcall,
    importc: "wl_resource_set_destructor", dynlib: "libwayland-server.so".}
proc instance_of*(resource: ptr Resource; `interface`: ptr Interface;
                 implementation: pointer): cint {.nimcall,
    importc: "wl_resource_instance_of", dynlib: "libwayland-server.so".}
proc get_class*(resource: ptr Resource): cstring {.nimcall,
    importc: "wl_resource_get_class", dynlib: "libwayland-server.so".}
proc add_destroy_listener*(resource: ptr Resource; listener: ptr Listener) {.nimcall,
    importc: "wl_resource_add_destroy_listener", dynlib: "libwayland-server.so".}
proc get_destroy_listener*(resource: ptr Resource; notify: wl_notify_func_t): ptr Listener {.
    nimcall, importc: "wl_resource_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc get_shm_buffer*(resource: ptr Resource): ptr ShmBuffer {.nimcall,
    importc: "wl_shm_buffer_get", dynlib: "libwayland-server.so".}
proc begin_access*(buffer: ptr ShmBuffer) {.nimcall,
                                        importc: "wl_shm_buffer_begin_access",
                                        dynlib: "libwayland-server.so".}
proc end_access*(buffer: ptr ShmBuffer) {.nimcall, importc: "wl_shm_buffer_end_access",
                                      dynlib: "libwayland-server.so".}
proc get_data*(buffer: ptr ShmBuffer): pointer {.nimcall,
    importc: "wl_shm_buffer_get_data", dynlib: "libwayland-server.so".}
proc get_stride*(buffer: ptr ShmBuffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_stride", dynlib: "libwayland-server.so".}
proc get_format*(buffer: ptr ShmBuffer): uint32 {.nimcall,
    importc: "wl_shm_buffer_get_format", dynlib: "libwayland-server.so".}
proc get_width*(buffer: ptr ShmBuffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_width", dynlib: "libwayland-server.so".}
proc get_height*(buffer: ptr ShmBuffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_height", dynlib: "libwayland-server.so".}
proc ref_pool*(buffer: ptr ShmBuffer): ptr ShmPool {.nimcall,
    importc: "wl_shm_buffer_ref_pool", dynlib: "libwayland-server.so".}
proc unref*(pool: ptr ShmPool) {.nimcall, importc: "wl_shm_pool_unref",
                             dynlib: "libwayland-server.so".}
proc init_shm*(display: ptr Display): cint {.nimcall, importc: "wl_display_init_shm",
                                        dynlib: "libwayland-server.so".}
proc add_shm_format*(display: ptr Display; format: uint32): ptr uint32 {.nimcall,
    importc: "wl_display_add_shm_format", dynlib: "libwayland-server.so".}
proc create_shm_buffer*(client: ptr Client; id: uint32; width: int32; height: int32;
                       stride: int32; format: uint32): ptr ShmBuffer {.nimcall,
    importc: "wl_shm_buffer_create", dynlib: "libwayland-server.so".}
proc set_handler_server*(handler: wl_log_func_t) {.nimcall,
    importc: "wl_log_set_handler_server", dynlib: "libwayland-server.so".}
proc add_protocol_logger*(display: ptr Display; a2: func_t; user_data: pointer): ptr ProtocolLogger {.
    nimcall, importc: "wl_display_add_protocol_logger",
    dynlib: "libwayland-server.so".}
proc destroy*(logger: ptr ProtocolLogger) {.nimcall,
                                        importc: "wl_protocol_logger_destroy",
                                        dynlib: "libwayland-server.so".}