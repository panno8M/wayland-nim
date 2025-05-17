discard "forward decl of wl_proxy"
discard "forward decl of wl_display"
discard "forward decl of wl_event_queue"
const
  WL_MARSHAL_FLAG_DESTROY* = (1 shl 0)
proc destroy*(queue: ptr EventQueue) {.nimcall, importc: "wl_event_queue_destroy",
                                   dynlib: "libwayland-client.so".}
proc marshal_flags*(proxy: ptr Proxy; opcode: uint32; `interface`: ptr Interface;
                   version: uint32; flags: uint32): ptr Proxy {.discardable, varargs,
    nimcall, importc: "wl_proxy_marshal_flags", dynlib: "libwayland-client.so".}
proc marshal_array_flags*(proxy: ptr Proxy; opcode: uint32;
                         `interface`: ptr Interface; version: uint32; flags: uint32;
                         args: ptr Argument): ptr Proxy {.nimcall,
    importc: "wl_proxy_marshal_array_flags", dynlib: "libwayland-client.so".}
proc marshal*(p: ptr Proxy; opcode: uint32) {.varargs, nimcall,
                                        importc: "wl_proxy_marshal",
                                        dynlib: "libwayland-client.so".}
proc marshal_array*(p: ptr Proxy; opcode: uint32; args: ptr Argument) {.nimcall,
    importc: "wl_proxy_marshal_array", dynlib: "libwayland-client.so".}
proc create*(factory: ptr Proxy; `interface`: ptr Interface): ptr Proxy {.nimcall,
    importc: "wl_proxy_create", dynlib: "libwayland-client.so".}
proc wl_proxy_create_wrapper*(proxy: pointer): pointer {.nimcall,
    importc: "wl_proxy_create_wrapper", dynlib: "libwayland-client.so".}
proc wl_proxy_wrapper_destroy*(proxy_wrapper: pointer) {.nimcall,
    importc: "wl_proxy_wrapper_destroy", dynlib: "libwayland-client.so".}
proc marshal_constructor*(proxy: ptr Proxy; opcode: uint32; `interface`: ptr Interface): ptr Proxy {.
    varargs, nimcall, importc: "wl_proxy_marshal_constructor",
    dynlib: "libwayland-client.so".}
proc marshal_constructor_versioned*(proxy: ptr Proxy; opcode: uint32;
                                   `interface`: ptr Interface; version: uint32): ptr Proxy {.
    varargs, nimcall, importc: "wl_proxy_marshal_constructor_versioned",
    dynlib: "libwayland-client.so".}
proc marshal_array_constructor*(proxy: ptr Proxy; opcode: uint32; args: ptr Argument;
                               `interface`: ptr Interface): ptr Proxy {.nimcall,
    importc: "wl_proxy_marshal_array_constructor", dynlib: "libwayland-client.so".}
proc marshal_array_constructor_versioned*(proxy: ptr Proxy; opcode: uint32;
    args: ptr Argument; `interface`: ptr Interface; version: uint32): ptr Proxy {.nimcall,
    importc: "wl_proxy_marshal_array_constructor_versioned",
    dynlib: "libwayland-client.so".}
proc destroy*(proxy: ptr Proxy) {.nimcall, importc: "wl_proxy_destroy",
                              dynlib: "libwayland-client.so".}
proc add_listener*(proxy: ptr Proxy; implementation: pointer; data: pointer): cint {.
    nimcall, importc: "wl_proxy_add_listener", dynlib: "libwayland-client.so".}
proc get_listener*(proxy: ptr Proxy): pointer {.nimcall,
    importc: "wl_proxy_get_listener", dynlib: "libwayland-client.so".}
proc add_dispatcher*(proxy: ptr Proxy; dispatcher_func: wl_dispatcher_func_t;
                    dispatcher_data: pointer; data: pointer): cint {.nimcall,
    importc: "wl_proxy_add_dispatcher", dynlib: "libwayland-client.so".}
proc set_user_data*(proxy: ptr Proxy; user_data: pointer) {.nimcall,
    importc: "wl_proxy_set_user_data", dynlib: "libwayland-client.so".}
proc get_user_data*(proxy: ptr Proxy): pointer {.nimcall,
    importc: "wl_proxy_get_user_data", dynlib: "libwayland-client.so".}
proc get_version*(proxy: ptr Proxy): uint32 {.nimcall, importc: "wl_proxy_get_version",
    dynlib: "libwayland-client.so".}
proc get_id*(proxy: ptr Proxy): uint32 {.nimcall, importc: "wl_proxy_get_id",
                                    dynlib: "libwayland-client.so".}
proc set_tag*(proxy: ptr Proxy; tag: cstringArray) {.nimcall,
    importc: "wl_proxy_set_tag", dynlib: "libwayland-client.so".}
proc get_tag*(proxy: ptr Proxy): cstringArray {.nimcall, importc: "wl_proxy_get_tag",
    dynlib: "libwayland-client.so".}
proc get_class*(proxy: ptr Proxy): cstring {.nimcall, importc: "wl_proxy_get_class",
                                        dynlib: "libwayland-client.so".}
proc get_display*(proxy: ptr Proxy): ptr Display {.nimcall,
    importc: "wl_proxy_get_display", dynlib: "libwayland-client.so".}
proc set_queue*(proxy: ptr Proxy; queue: ptr EventQueue) {.nimcall,
    importc: "wl_proxy_set_queue", dynlib: "libwayland-client.so".}
proc get_queue*(proxy: ptr Proxy): ptr EventQueue {.nimcall,
    importc: "wl_proxy_get_queue", dynlib: "libwayland-client.so".}
proc get_name*(queue: ptr EventQueue): cstring {.nimcall,
    importc: "wl_event_queue_get_name", dynlib: "libwayland-client.so".}
proc connect_display*(name: cstring): ptr Display {.nimcall,
    importc: "wl_display_connect", dynlib: "libwayland-client.so".}
proc connect_display_to_fd*(fd: cint): ptr Display {.nimcall,
    importc: "wl_display_connect_to_fd", dynlib: "libwayland-client.so".}
proc disconnect*(display: ptr Display) {.nimcall, importc: "wl_display_disconnect",
                                     dynlib: "libwayland-client.so".}
proc get_fd*(display: ptr Display): cint {.nimcall, importc: "wl_display_get_fd",
                                      dynlib: "libwayland-client.so".}
proc dispatch*(display: ptr Display): cint {.nimcall, importc: "wl_display_dispatch",
                                        dynlib: "libwayland-client.so".}
proc dispatch_queue*(display: ptr Display; queue: ptr EventQueue): cint {.nimcall,
    importc: "wl_display_dispatch_queue", dynlib: "libwayland-client.so".}
proc dispatch_queue_pending*(display: ptr Display; queue: ptr EventQueue): cint {.nimcall,
    importc: "wl_display_dispatch_queue_pending", dynlib: "libwayland-client.so".}
proc dispatch_pending*(display: ptr Display): cint {.nimcall,
    importc: "wl_display_dispatch_pending", dynlib: "libwayland-client.so".}
proc get_error*(display: ptr Display): cint {.nimcall, importc: "wl_display_get_error",
    dynlib: "libwayland-client.so".}
proc get_protocol_error*(display: ptr Display; `interface`: ptr UncheckedArray[ptr Interface];
                        id: ptr uint32): uint32 {.nimcall,
    importc: "wl_display_get_protocol_error", dynlib: "libwayland-client.so".}
proc flush*(display: ptr Display): cint {.nimcall, importc: "wl_display_flush",
                                     dynlib: "libwayland-client.so".}
proc roundtrip_queue*(display: ptr Display; queue: ptr EventQueue): cint {.nimcall,
    importc: "wl_display_roundtrip_queue", dynlib: "libwayland-client.so".}
proc roundtrip*(display: ptr Display): cint {.nimcall, importc: "wl_display_roundtrip",
    dynlib: "libwayland-client.so".}
proc create_queue*(display: ptr Display): ptr EventQueue {.nimcall,
    importc: "wl_display_create_queue", dynlib: "libwayland-client.so".}
proc create_queue_with_name*(display: ptr Display; name: cstring): ptr EventQueue {.
    nimcall, importc: "wl_display_create_queue_with_name",
    dynlib: "libwayland-client.so".}
proc prepare_read_queue*(display: ptr Display; queue: ptr EventQueue): cint {.nimcall,
    importc: "wl_display_prepare_read_queue", dynlib: "libwayland-client.so".}
proc prepare_read*(display: ptr Display): cint {.nimcall,
    importc: "wl_display_prepare_read", dynlib: "libwayland-client.so".}
proc cancel_read*(display: ptr Display) {.nimcall, importc: "wl_display_cancel_read",
                                      dynlib: "libwayland-client.so".}
proc read_events*(display: ptr Display): cint {.nimcall,
    importc: "wl_display_read_events", dynlib: "libwayland-client.so".}
proc set_handler_client*(handler: wl_log_func_t) {.nimcall,
    importc: "wl_log_set_handler_client", dynlib: "libwayland-client.so".}
proc set_max_buffer_size*(display: ptr Display; max_buffer_size: csize_t) {.nimcall,
    importc: "wl_display_set_max_buffer_size", dynlib: "libwayland-client.so".}