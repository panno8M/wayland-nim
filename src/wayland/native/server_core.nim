import common
type
  wl_resource* {.bycopy.} = object
    `object`*: wl_object
    destroy*: wl_resource_destroy_func_t
    link*: wl_list
    destroy_signal*: wl_signal
    client*: ptr wl_client
    data*: pointer
  wl_event_loop_fd_func_t* = proc (fd: cint; mask: uint32; data: pointer): cint {.nimcall.}
  wl_event_loop_timer_func_t* = proc (data: pointer): cint {.nimcall.}
  wl_event_loop_signal_func_t* = proc (signal_number: cint; data: pointer): cint {.nimcall.}
  wl_event_loop_idle_func_t* = proc (data: pointer) {.nimcall.}
  wl_notify_func_t* = proc (listener: ptr wl_listener; data: pointer) {.nimcall.}
  wl_global_bind_func_t* = proc (client: ptr wl_client; data: pointer; version: uint32;
                              id: uint32) {.nimcall.}
  wl_display_global_filter_func_t* = proc (client: ptr wl_client;
                                        global: ptr wl_global; data: pointer): bool {.
      nimcall.}
  wl_client_for_each_resource_iterator_func_t* = proc (resource: ptr wl_resource;
      user_data: pointer): wl_iterator_result {.nimcall.}
  wl_user_data_destroy_func_t* = proc (data: pointer) {.nimcall.}
  wl_listener* {.bycopy.} = object
    link*: wl_list
    notify*: wl_notify_func_t
  wl_signal* {.bycopy.} = object
    listener_list*: wl_list
  wl_resource_destroy_func_t* = proc (resource: ptr wl_resource) {.nimcall.}
  wl_protocol_logger_type* {.size: sizeof(cint).} = enum
    WL_PROTOCOL_LOGGER_REQUEST, WL_PROTOCOL_LOGGER_EVENT
  wl_protocol_logger_message* {.bycopy.} = object
    resource*: ptr wl_resource
    message_opcode*: cint
    message*: ptr wl_message
    arguments_count*: cint
    arguments*: ptr wl_argument
  wl_protocol_logger_func_t* = proc (user_data: pointer;
                                  direction: wl_protocol_logger_type;
                                  message: ptr wl_protocol_logger_message) {.nimcall.}
const
  WL_EVENT_READABLE* = 0x01
  WL_EVENT_WRITABLE* = 0x02
  WL_EVENT_HANGUP* = 0x04
  WL_EVENT_ERROR* = 0x08
proc wl_event_loop_create*(): ptr wl_event_loop {.nimcall,
    importc: "wl_event_loop_create", dynlib: "libwayland-server.so".}
proc wl_event_loop_destroy*(loop: ptr wl_event_loop) {.nimcall,
    importc: "wl_event_loop_destroy", dynlib: "libwayland-server.so".}
proc wl_event_loop_add_fd*(loop: ptr wl_event_loop; fd: cint; mask: uint32;
                          `func`: wl_event_loop_fd_func_t; data: pointer): ptr wl_event_source {.
    nimcall, importc: "wl_event_loop_add_fd", dynlib: "libwayland-server.so".}
proc wl_event_source_fd_update*(source: ptr wl_event_source; mask: uint32): cint {.
    nimcall, importc: "wl_event_source_fd_update", dynlib: "libwayland-server.so".}
proc wl_event_loop_add_timer*(loop: ptr wl_event_loop;
                             `func`: wl_event_loop_timer_func_t; data: pointer): ptr wl_event_source {.
    nimcall, importc: "wl_event_loop_add_timer", dynlib: "libwayland-server.so".}
proc wl_event_loop_add_signal*(loop: ptr wl_event_loop; signal_number: cint;
                              `func`: wl_event_loop_signal_func_t; data: pointer): ptr wl_event_source {.
    nimcall, importc: "wl_event_loop_add_signal", dynlib: "libwayland-server.so".}
proc wl_event_source_timer_update*(source: ptr wl_event_source; ms_delay: cint): cint {.
    nimcall, importc: "wl_event_source_timer_update", dynlib: "libwayland-server.so".}
proc wl_event_source_remove*(source: ptr wl_event_source): cint {.nimcall,
    importc: "wl_event_source_remove", dynlib: "libwayland-server.so".}
proc wl_event_source_check*(source: ptr wl_event_source) {.nimcall,
    importc: "wl_event_source_check", dynlib: "libwayland-server.so".}
proc wl_event_loop_dispatch*(loop: ptr wl_event_loop; timeout: cint): cint {.nimcall,
    importc: "wl_event_loop_dispatch", dynlib: "libwayland-server.so".}
proc wl_event_loop_dispatch_idle*(loop: ptr wl_event_loop) {.nimcall,
    importc: "wl_event_loop_dispatch_idle", dynlib: "libwayland-server.so".}
proc wl_event_loop_add_idle*(loop: ptr wl_event_loop;
                            `func`: wl_event_loop_idle_func_t; data: pointer): ptr wl_event_source {.
    nimcall, importc: "wl_event_loop_add_idle", dynlib: "libwayland-server.so".}
proc wl_event_loop_get_fd*(loop: ptr wl_event_loop): cint {.nimcall,
    importc: "wl_event_loop_get_fd", dynlib: "libwayland-server.so".}
discard "forward decl of wl_listener"
proc wl_event_loop_add_destroy_listener*(loop: ptr wl_event_loop;
                                        listener: ptr wl_listener) {.nimcall,
    importc: "wl_event_loop_add_destroy_listener", dynlib: "libwayland-server.so".}
proc wl_event_loop_get_destroy_listener*(loop: ptr wl_event_loop;
                                        notify: wl_notify_func_t): ptr wl_listener {.
    nimcall, importc: "wl_event_loop_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc wl_display_create*(): ptr wl_display {.nimcall, importc: "wl_display_create",
                                        dynlib: "libwayland-server.so".}
proc wl_display_destroy*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_destroy", dynlib: "libwayland-server.so".}
proc wl_display_get_event_loop*(display: ptr wl_display): ptr wl_event_loop {.nimcall,
    importc: "wl_display_get_event_loop", dynlib: "libwayland-server.so".}
proc wl_display_add_socket*(display: ptr wl_display; name: cstring): cint {.nimcall,
    importc: "wl_display_add_socket", dynlib: "libwayland-server.so".}
proc wl_display_add_socket_auto*(display: ptr wl_display): cstring {.nimcall,
    importc: "wl_display_add_socket_auto", dynlib: "libwayland-server.so".}
proc wl_display_add_socket_fd*(display: ptr wl_display; sock_fd: cint): cint {.nimcall,
    importc: "wl_display_add_socket_fd", dynlib: "libwayland-server.so".}
proc wl_display_terminate*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_terminate", dynlib: "libwayland-server.so".}
proc wl_display_run*(display: ptr wl_display) {.nimcall, importc: "wl_display_run",
    dynlib: "libwayland-server.so".}
proc wl_display_flush_clients*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_flush_clients", dynlib: "libwayland-server.so".}
proc wl_display_destroy_clients*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_destroy_clients", dynlib: "libwayland-server.so".}
proc wl_display_set_default_max_buffer_size*(display: ptr wl_display;
    max_buffer_size: csize_t) {.nimcall, importc: "wl_display_set_default_max_buffer_size",
                              dynlib: "libwayland-server.so".}
discard "forward decl of wl_client"
proc wl_display_get_serial*(display: ptr wl_display): uint32 {.nimcall,
    importc: "wl_display_get_serial", dynlib: "libwayland-server.so".}
proc wl_display_next_serial*(display: ptr wl_display): uint32 {.nimcall,
    importc: "wl_display_next_serial", dynlib: "libwayland-server.so".}
proc wl_display_add_destroy_listener*(display: ptr wl_display;
                                     listener: ptr wl_listener) {.nimcall,
    importc: "wl_display_add_destroy_listener", dynlib: "libwayland-server.so".}
proc wl_display_add_client_created_listener*(display: ptr wl_display;
    listener: ptr wl_listener) {.nimcall, importc: "wl_display_add_client_created_listener",
                              dynlib: "libwayland-server.so".}
proc wl_display_get_destroy_listener*(display: ptr wl_display;
                                     notify: wl_notify_func_t): ptr wl_listener {.
    nimcall, importc: "wl_display_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc wl_global_create*(display: ptr wl_display; `interface`: ptr wl_interface;
                      version: cint; data: pointer; `bind`: wl_global_bind_func_t): ptr wl_global {.
    nimcall, importc: "wl_global_create", dynlib: "libwayland-server.so".}
proc wl_global_remove*(global: ptr wl_global) {.nimcall, importc: "wl_global_remove",
    dynlib: "libwayland-server.so".}
proc wl_global_destroy*(global: ptr wl_global) {.nimcall, importc: "wl_global_destroy",
    dynlib: "libwayland-server.so".}
proc wl_display_set_global_filter*(display: ptr wl_display;
                                  filter: wl_display_global_filter_func_t;
                                  data: pointer) {.nimcall,
    importc: "wl_display_set_global_filter", dynlib: "libwayland-server.so".}
proc wl_global_get_interface*(global: ptr wl_global): ptr wl_interface {.nimcall,
    importc: "wl_global_get_interface", dynlib: "libwayland-server.so".}
proc wl_global_get_name*(global: ptr wl_global; client: ptr wl_client): uint32 {.nimcall,
    importc: "wl_global_get_name", dynlib: "libwayland-server.so".}
proc wl_global_get_version*(global: ptr wl_global): uint32 {.nimcall,
    importc: "wl_global_get_version", dynlib: "libwayland-server.so".}
proc wl_global_get_display*(global: ptr wl_global): ptr wl_display {.nimcall,
    importc: "wl_global_get_display", dynlib: "libwayland-server.so".}
proc wl_global_get_user_data*(global: ptr wl_global): pointer {.nimcall,
    importc: "wl_global_get_user_data", dynlib: "libwayland-server.so".}
proc wl_global_set_user_data*(global: ptr wl_global; data: pointer) {.nimcall,
    importc: "wl_global_set_user_data", dynlib: "libwayland-server.so".}
proc wl_client_create*(display: ptr wl_display; fd: cint): ptr wl_client {.nimcall,
    importc: "wl_client_create", dynlib: "libwayland-server.so".}
proc wl_display_get_client_list*(display: ptr wl_display): ptr wl_list {.nimcall,
    importc: "wl_display_get_client_list", dynlib: "libwayland-server.so".}
proc wl_client_get_link*(client: ptr wl_client): ptr wl_list {.nimcall,
    importc: "wl_client_get_link", dynlib: "libwayland-server.so".}
proc wl_client_from_link*(link: ptr wl_list): ptr wl_client {.nimcall,
    importc: "wl_client_from_link", dynlib: "libwayland-server.so".}
proc wl_client_destroy*(client: ptr wl_client) {.nimcall, importc: "wl_client_destroy",
    dynlib: "libwayland-server.so".}
proc wl_client_flush*(client: ptr wl_client) {.nimcall, importc: "wl_client_flush",
    dynlib: "libwayland-server.so".}
proc wl_client_get_credentials*(client: ptr wl_client; pid: ptr pid_t; uid: ptr uid_t;
                               gid: ptr gid_t) {.nimcall,
    importc: "wl_client_get_credentials", dynlib: "libwayland-server.so".}
proc wl_client_get_fd*(client: ptr wl_client): cint {.nimcall,
    importc: "wl_client_get_fd", dynlib: "libwayland-server.so".}
proc wl_client_add_destroy_listener*(client: ptr wl_client;
                                    listener: ptr wl_listener) {.nimcall,
    importc: "wl_client_add_destroy_listener", dynlib: "libwayland-server.so".}
proc wl_client_get_destroy_listener*(client: ptr wl_client; notify: wl_notify_func_t): ptr wl_listener {.
    nimcall, importc: "wl_client_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc wl_client_add_destroy_late_listener*(client: ptr wl_client;
    listener: ptr wl_listener) {.nimcall,
                              importc: "wl_client_add_destroy_late_listener",
                              dynlib: "libwayland-server.so".}
proc wl_client_get_destroy_late_listener*(client: ptr wl_client;
    notify: wl_notify_func_t): ptr wl_listener {.nimcall,
    importc: "wl_client_get_destroy_late_listener", dynlib: "libwayland-server.so".}
proc wl_client_get_object*(client: ptr wl_client; id: uint32): ptr wl_resource {.nimcall,
    importc: "wl_client_get_object", dynlib: "libwayland-server.so".}
proc wl_client_post_no_memory*(client: ptr wl_client) {.nimcall,
    importc: "wl_client_post_no_memory", dynlib: "libwayland-server.so".}
proc wl_client_post_implementation_error*(client: ptr wl_client; msg: cstring) {.
    varargs, nimcall, importc: "wl_client_post_implementation_error",
    dynlib: "libwayland-server.so".}
proc wl_client_add_resource_created_listener*(client: ptr wl_client;
    listener: ptr wl_listener) {.nimcall, importc: "wl_client_add_resource_created_listener",
                              dynlib: "libwayland-server.so".}
proc wl_client_for_each_resource*(client: ptr wl_client; `iterator`: wl_client_for_each_resource_iterator_func_t;
                                 user_data: pointer) {.nimcall,
    importc: "wl_client_for_each_resource", dynlib: "libwayland-server.so".}
proc wl_client_set_user_data*(client: ptr wl_client; data: pointer;
                             dtor: wl_user_data_destroy_func_t) {.nimcall,
    importc: "wl_client_set_user_data", dynlib: "libwayland-server.so".}
proc wl_client_get_user_data*(client: ptr wl_client): pointer {.nimcall,
    importc: "wl_client_get_user_data", dynlib: "libwayland-server.so".}
proc wl_client_set_max_buffer_size*(client: ptr wl_client; max_buffer_size: csize_t) {.
    nimcall, importc: "wl_client_set_max_buffer_size", dynlib: "libwayland-server.so".}
include includes/signal
proc wl_signal_emit_mutable*(signal: ptr wl_signal; data: pointer) {.nimcall,
    importc: "wl_signal_emit_mutable", dynlib: "libwayland-server.so".}
proc wl_resource_post_event*(resource: ptr wl_resource; opcode: uint32) {.varargs,
    nimcall, importc: "wl_resource_post_event", dynlib: "libwayland-server.so".}
proc wl_resource_post_event_array*(resource: ptr wl_resource; opcode: uint32;
                                  args: ptr wl_argument) {.nimcall,
    importc: "wl_resource_post_event_array", dynlib: "libwayland-server.so".}
proc wl_resource_queue_event*(resource: ptr wl_resource; opcode: uint32) {.varargs,
    nimcall, importc: "wl_resource_queue_event", dynlib: "libwayland-server.so".}
proc wl_resource_queue_event_array*(resource: ptr wl_resource; opcode: uint32;
                                   args: ptr wl_argument) {.nimcall,
    importc: "wl_resource_queue_event_array", dynlib: "libwayland-server.so".}
proc wl_resource_post_error*(resource: ptr wl_resource; code: uint32; msg: cstring) {.
    varargs, nimcall, importc: "wl_resource_post_error",
    dynlib: "libwayland-server.so".}
proc wl_resource_post_no_memory*(resource: ptr wl_resource) {.nimcall,
    importc: "wl_resource_post_no_memory", dynlib: "libwayland-server.so".}
proc wl_client_get_display*(client: ptr wl_client): ptr wl_display {.nimcall,
    importc: "wl_client_get_display", dynlib: "libwayland-server.so".}
proc wl_resource_create*(client: ptr wl_client; `interface`: ptr wl_interface;
                        version: cint; id: uint32): ptr wl_resource {.nimcall,
    importc: "wl_resource_create", dynlib: "libwayland-server.so".}
proc wl_resource_set_implementation*(resource: ptr wl_resource;
                                    implementation: pointer; data: pointer;
                                    destroy: wl_resource_destroy_func_t) {.nimcall,
    importc: "wl_resource_set_implementation", dynlib: "libwayland-server.so".}
proc wl_resource_set_dispatcher*(resource: ptr wl_resource;
                                dispatcher: wl_dispatcher_func_t;
                                implementation: pointer; data: pointer;
                                destroy: wl_resource_destroy_func_t) {.nimcall,
    importc: "wl_resource_set_dispatcher", dynlib: "libwayland-server.so".}
proc wl_resource_destroy*(resource: ptr wl_resource) {.nimcall,
    importc: "wl_resource_destroy", dynlib: "libwayland-server.so".}
proc wl_resource_get_id*(resource: ptr wl_resource): uint32 {.nimcall,
    importc: "wl_resource_get_id", dynlib: "libwayland-server.so".}
proc wl_resource_get_link*(resource: ptr wl_resource): ptr wl_list {.nimcall,
    importc: "wl_resource_get_link", dynlib: "libwayland-server.so".}
proc wl_resource_from_link*(resource: ptr wl_list): ptr wl_resource {.nimcall,
    importc: "wl_resource_from_link", dynlib: "libwayland-server.so".}
proc wl_resource_find_for_client*(list: ptr wl_list; client: ptr wl_client): ptr wl_resource {.
    nimcall, importc: "wl_resource_find_for_client", dynlib: "libwayland-server.so".}
proc wl_resource_get_client*(resource: ptr wl_resource): ptr wl_client {.nimcall,
    importc: "wl_resource_get_client", dynlib: "libwayland-server.so".}
proc wl_resource_set_user_data*(resource: ptr wl_resource; data: pointer) {.nimcall,
    importc: "wl_resource_set_user_data", dynlib: "libwayland-server.so".}
proc wl_resource_get_user_data*(resource: ptr wl_resource): pointer {.nimcall,
    importc: "wl_resource_get_user_data", dynlib: "libwayland-server.so".}
proc wl_resource_get_version*(resource: ptr wl_resource): cint {.nimcall,
    importc: "wl_resource_get_version", dynlib: "libwayland-server.so".}
proc wl_resource_set_destructor*(resource: ptr wl_resource;
                                destroy: wl_resource_destroy_func_t) {.nimcall,
    importc: "wl_resource_set_destructor", dynlib: "libwayland-server.so".}
proc wl_resource_instance_of*(resource: ptr wl_resource;
                             `interface`: ptr wl_interface; implementation: pointer): cint {.
    nimcall, importc: "wl_resource_instance_of", dynlib: "libwayland-server.so".}
proc wl_resource_get_class*(resource: ptr wl_resource): cstring {.nimcall,
    importc: "wl_resource_get_class", dynlib: "libwayland-server.so".}
proc wl_resource_add_destroy_listener*(resource: ptr wl_resource;
                                      listener: ptr wl_listener) {.nimcall,
    importc: "wl_resource_add_destroy_listener", dynlib: "libwayland-server.so".}
proc wl_resource_get_destroy_listener*(resource: ptr wl_resource;
                                      notify: wl_notify_func_t): ptr wl_listener {.
    nimcall, importc: "wl_resource_get_destroy_listener",
    dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get*(resource: ptr wl_resource): ptr wl_shm_buffer {.nimcall,
    importc: "wl_shm_buffer_get", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_begin_access*(buffer: ptr wl_shm_buffer) {.nimcall,
    importc: "wl_shm_buffer_begin_access", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_end_access*(buffer: ptr wl_shm_buffer) {.nimcall,
    importc: "wl_shm_buffer_end_access", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get_data*(buffer: ptr wl_shm_buffer): pointer {.nimcall,
    importc: "wl_shm_buffer_get_data", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get_stride*(buffer: ptr wl_shm_buffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_stride", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get_format*(buffer: ptr wl_shm_buffer): uint32 {.nimcall,
    importc: "wl_shm_buffer_get_format", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get_width*(buffer: ptr wl_shm_buffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_width", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_get_height*(buffer: ptr wl_shm_buffer): int32 {.nimcall,
    importc: "wl_shm_buffer_get_height", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_ref_pool*(buffer: ptr wl_shm_buffer): ptr wl_shm_pool {.nimcall,
    importc: "wl_shm_buffer_ref_pool", dynlib: "libwayland-server.so".}
proc wl_shm_pool_unref*(pool: ptr wl_shm_pool) {.nimcall, importc: "wl_shm_pool_unref",
    dynlib: "libwayland-server.so".}
proc wl_display_init_shm*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_init_shm", dynlib: "libwayland-server.so".}
proc wl_display_add_shm_format*(display: ptr wl_display; format: uint32): ptr uint32 {.
    nimcall, importc: "wl_display_add_shm_format", dynlib: "libwayland-server.so".}
proc wl_shm_buffer_create*(client: ptr wl_client; id: uint32; width: int32;
                          height: int32; stride: int32; format: uint32): ptr wl_shm_buffer {.
    nimcall, importc: "wl_shm_buffer_create", dynlib: "libwayland-server.so".}
proc wl_log_set_handler_server*(handler: wl_log_func_t) {.nimcall,
    importc: "wl_log_set_handler_server", dynlib: "libwayland-server.so".}
proc wl_display_add_protocol_logger*(display: ptr wl_display;
                                    a2: wl_protocol_logger_func_t;
                                    user_data: pointer): ptr wl_protocol_logger {.
    nimcall, importc: "wl_display_add_protocol_logger",
    dynlib: "libwayland-server.so".}
proc wl_protocol_logger_destroy*(logger: ptr wl_protocol_logger) {.nimcall,
    importc: "wl_protocol_logger_destroy", dynlib: "libwayland-server.so".}