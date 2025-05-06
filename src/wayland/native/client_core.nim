import common
discard "forward decl of wl_proxy"
discard "forward decl of wl_display"
discard "forward decl of wl_event_queue"
const
  WL_MARSHAL_FLAG_DESTROY* = (1 shl 0)
proc wl_event_queue_destroy*(queue: ptr wl_event_queue) {.nimcall,
    importc: "wl_event_queue_destroy", dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_flags*(proxy: ptr wl_proxy; opcode: uint32;
                            `interface`: ptr wl_interface; version: uint32;
                            flags: uint32): ptr wl_proxy {.discardable, varargs,
    nimcall, importc: "wl_proxy_marshal_flags", dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_array_flags*(proxy: ptr wl_proxy; opcode: uint32;
                                  `interface`: ptr wl_interface; version: uint32;
                                  flags: uint32; args: ptr wl_argument): ptr wl_proxy {.
    nimcall, importc: "wl_proxy_marshal_array_flags", dynlib: "libwayland-client.so".}
proc wl_proxy_marshal*(p: ptr wl_proxy; opcode: uint32) {.varargs, nimcall,
    importc: "wl_proxy_marshal", dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_array*(p: ptr wl_proxy; opcode: uint32; args: ptr wl_argument) {.
    nimcall, importc: "wl_proxy_marshal_array", dynlib: "libwayland-client.so".}
proc wl_proxy_create*(factory: ptr wl_proxy; `interface`: ptr wl_interface): ptr wl_proxy {.
    nimcall, importc: "wl_proxy_create", dynlib: "libwayland-client.so".}
proc wl_proxy_create_wrapper*(proxy: pointer): pointer {.nimcall,
    importc: "wl_proxy_create_wrapper", dynlib: "libwayland-client.so".}
proc wl_proxy_wrapper_destroy*(proxy_wrapper: pointer) {.nimcall,
    importc: "wl_proxy_wrapper_destroy", dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_constructor*(proxy: ptr wl_proxy; opcode: uint32;
                                  `interface`: ptr wl_interface): ptr wl_proxy {.
    varargs, nimcall, importc: "wl_proxy_marshal_constructor",
    dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_constructor_versioned*(proxy: ptr wl_proxy; opcode: uint32;
    `interface`: ptr wl_interface; version: uint32): ptr wl_proxy {.varargs, nimcall,
    importc: "wl_proxy_marshal_constructor_versioned",
    dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_array_constructor*(proxy: ptr wl_proxy; opcode: uint32;
                                        args: ptr wl_argument;
                                        `interface`: ptr wl_interface): ptr wl_proxy {.
    nimcall, importc: "wl_proxy_marshal_array_constructor",
    dynlib: "libwayland-client.so".}
proc wl_proxy_marshal_array_constructor_versioned*(proxy: ptr wl_proxy;
    opcode: uint32; args: ptr wl_argument; `interface`: ptr wl_interface;
    version: uint32): ptr wl_proxy {.nimcall, importc: "wl_proxy_marshal_array_constructor_versioned",
                                 dynlib: "libwayland-client.so".}
proc wl_proxy_destroy*(proxy: ptr wl_proxy) {.nimcall, importc: "wl_proxy_destroy",
    dynlib: "libwayland-client.so".}
proc wl_proxy_add_listener*(proxy: ptr wl_proxy; implementation: pointer;
                           data: pointer): cint {.nimcall,
    importc: "wl_proxy_add_listener", dynlib: "libwayland-client.so".}
proc wl_proxy_get_listener*(proxy: ptr wl_proxy): pointer {.nimcall,
    importc: "wl_proxy_get_listener", dynlib: "libwayland-client.so".}
proc wl_proxy_add_dispatcher*(proxy: ptr wl_proxy;
                             dispatcher_func: wl_dispatcher_func_t;
                             dispatcher_data: pointer; data: pointer): cint {.nimcall,
    importc: "wl_proxy_add_dispatcher", dynlib: "libwayland-client.so".}
proc wl_proxy_set_user_data*(proxy: ptr wl_proxy; user_data: pointer) {.nimcall,
    importc: "wl_proxy_set_user_data", dynlib: "libwayland-client.so".}
proc wl_proxy_get_user_data*(proxy: ptr wl_proxy): pointer {.nimcall,
    importc: "wl_proxy_get_user_data", dynlib: "libwayland-client.so".}
proc wl_proxy_get_version*(proxy: ptr wl_proxy): uint32 {.nimcall,
    importc: "wl_proxy_get_version", dynlib: "libwayland-client.so".}
proc wl_proxy_get_id*(proxy: ptr wl_proxy): uint32 {.nimcall,
    importc: "wl_proxy_get_id", dynlib: "libwayland-client.so".}
proc wl_proxy_set_tag*(proxy: ptr wl_proxy; tag: cstringArray) {.nimcall,
    importc: "wl_proxy_set_tag", dynlib: "libwayland-client.so".}
proc wl_proxy_get_tag*(proxy: ptr wl_proxy): cstringArray {.nimcall,
    importc: "wl_proxy_get_tag", dynlib: "libwayland-client.so".}
proc wl_proxy_get_class*(proxy: ptr wl_proxy): cstring {.nimcall,
    importc: "wl_proxy_get_class", dynlib: "libwayland-client.so".}
proc wl_proxy_get_display*(proxy: ptr wl_proxy): ptr wl_display {.nimcall,
    importc: "wl_proxy_get_display", dynlib: "libwayland-client.so".}
proc wl_proxy_set_queue*(proxy: ptr wl_proxy; queue: ptr wl_event_queue) {.nimcall,
    importc: "wl_proxy_set_queue", dynlib: "libwayland-client.so".}
proc wl_proxy_get_queue*(proxy: ptr wl_proxy): ptr wl_event_queue {.nimcall,
    importc: "wl_proxy_get_queue", dynlib: "libwayland-client.so".}
proc wl_event_queue_get_name*(queue: ptr wl_event_queue): cstring {.nimcall,
    importc: "wl_event_queue_get_name", dynlib: "libwayland-client.so".}
proc wl_display_connect*(name: cstring): ptr wl_display {.nimcall,
    importc: "wl_display_connect", dynlib: "libwayland-client.so".}
proc wl_display_connect_to_fd*(fd: cint): ptr wl_display {.nimcall,
    importc: "wl_display_connect_to_fd", dynlib: "libwayland-client.so".}
proc wl_display_disconnect*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_disconnect", dynlib: "libwayland-client.so".}
proc wl_display_get_fd*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_get_fd", dynlib: "libwayland-client.so".}
proc wl_display_dispatch*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_dispatch", dynlib: "libwayland-client.so".}
proc wl_display_dispatch_queue*(display: ptr wl_display; queue: ptr wl_event_queue): cint {.
    nimcall, importc: "wl_display_dispatch_queue", dynlib: "libwayland-client.so".}
proc wl_display_dispatch_queue_pending*(display: ptr wl_display;
                                       queue: ptr wl_event_queue): cint {.nimcall,
    importc: "wl_display_dispatch_queue_pending", dynlib: "libwayland-client.so".}
proc wl_display_dispatch_pending*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_dispatch_pending", dynlib: "libwayland-client.so".}
proc wl_display_get_error*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_get_error", dynlib: "libwayland-client.so".}
proc wl_display_get_protocol_error*(display: ptr wl_display;
                                   `interface`: ptr ptr wl_interface; id: ptr uint32): uint32 {.
    nimcall, importc: "wl_display_get_protocol_error", dynlib: "libwayland-client.so".}
proc wl_display_flush*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_flush", dynlib: "libwayland-client.so".}
proc wl_display_roundtrip_queue*(display: ptr wl_display; queue: ptr wl_event_queue): cint {.
    nimcall, importc: "wl_display_roundtrip_queue", dynlib: "libwayland-client.so".}
proc wl_display_roundtrip*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_roundtrip", dynlib: "libwayland-client.so".}
proc wl_display_create_queue*(display: ptr wl_display): ptr wl_event_queue {.nimcall,
    importc: "wl_display_create_queue", dynlib: "libwayland-client.so".}
proc wl_display_create_queue_with_name*(display: ptr wl_display; name: cstring): ptr wl_event_queue {.
    nimcall, importc: "wl_display_create_queue_with_name",
    dynlib: "libwayland-client.so".}
proc wl_display_prepare_read_queue*(display: ptr wl_display;
                                   queue: ptr wl_event_queue): cint {.nimcall,
    importc: "wl_display_prepare_read_queue", dynlib: "libwayland-client.so".}
proc wl_display_prepare_read*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_prepare_read", dynlib: "libwayland-client.so".}
proc wl_display_cancel_read*(display: ptr wl_display) {.nimcall,
    importc: "wl_display_cancel_read", dynlib: "libwayland-client.so".}
proc wl_display_read_events*(display: ptr wl_display): cint {.nimcall,
    importc: "wl_display_read_events", dynlib: "libwayland-client.so".}
proc wl_log_set_handler_client*(handler: wl_log_func_t) {.nimcall,
    importc: "wl_log_set_handler_client", dynlib: "libwayland-client.so".}
proc wl_display_set_max_buffer_size*(display: ptr wl_display;
                                    max_buffer_size: csize_t) {.nimcall,
    importc: "wl_display_set_max_buffer_size", dynlib: "libwayland-client.so".}