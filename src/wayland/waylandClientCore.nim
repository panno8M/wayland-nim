import waylandUtil

{.push, header: "wayland-client-core.h".}
var WL_MARSHAL_FLAG_DESTROY* {.importc.}: int

type WlProxy* {.importc: "wl_proxy".} = object
type WlDisplay* {.importc: "wl_display".} = object
type WlEventQueue* {.importc: "wl_event_queue".} = object
{.pop.}

{.push, dynlib: "libwayland-client.so".}
proc wlEventQueueDestroy*(queue: ptr WlEventQueue) {.cdecl, importc: "wl_event_queue_destroy".}
proc wlProxyMarshalFlags*(proxy: ptr WlProxy; opcode: uint32; `interface`: ptr WlInterface; version: uint32; flags: uint32): ptr WlProxy {.varargs, cdecl, importc: "wl_proxy_marshal_flags".}
proc wlProxyMarshalArrayFlags*(proxy: ptr WlProxy; opcode: uint32; `interface`: ptr WlInterface; version: uint32; flags: uint32; args: ptr WlArgument): ptr WlProxy {.cdecl, importc: "wl_proxy_marshal_array_flags".}
proc wlProxyMarshal*(p: ptr WlProxy; opcode: uint32) {.varargs, cdecl, importc: "wl_proxy_marshal".}
proc wlProxyMarshalArray*(p: ptr WlProxy; opcode: uint32; args: ptr WlArgument) {.cdecl, importc: "wl_proxy_marshal_array".}
proc wlProxyCreate*(factory: ptr WlProxy; `interface`: ptr WlInterface): ptr WlProxy {.cdecl, importc: "wl_proxy_create".}
proc wlProxyCreateWrapper*(proxy: pointer): pointer {.cdecl, importc: "wl_proxy_create_wrapper".}
proc wlProxyWrapperDestroy*(proxyWrapper: pointer) {.cdecl, importc: "wl_proxy_wrapper_destroy".}
proc wlProxyMarshalConstructor*(proxy: ptr WlProxy; opcode: uint32; `interface`: ptr WlInterface): ptr WlProxy {.varargs, cdecl, importc: "wl_proxy_marshal_constructor".}
proc wlProxyMarshalConstructorVersioned*(proxy: ptr WlProxy; opcode: uint32; `interface`: ptr WlInterface; version: uint32): ptr WlProxy {.varargs, cdecl, importc: "wl_proxy_marshal_constructor_versioned".}
proc wlProxyMarshalArrayConstructor*(proxy: ptr WlProxy; opcode: uint32; args: ptr WlArgument; `interface`: ptr WlInterface): ptr WlProxy {.cdecl, importc: "wl_proxy_marshal_array_constructor".}
proc wlProxyMarshalArrayConstructorVersioned*(proxy: ptr WlProxy; opcode: uint32; args: ptr WlArgument; `interface`: ptr WlInterface; version: uint32): ptr WlProxy {.cdecl, importc: "wl_proxy_marshal_array_constructor_versioned".}
proc wlProxyDestroy*(proxy: ptr WlProxy) {.cdecl, importc: "wl_proxy_destroy".}
proc wlProxyAddListener*(proxy: ptr WlProxy; implementation: proc () {.cdecl.}; data: pointer): cint {.cdecl, importc: "wl_proxy_add_listener".}
proc wlProxyGetListener*(proxy: ptr WlProxy): pointer {.cdecl, importc: "wl_proxy_get_listener".}
proc wlProxyAddDispatcher*(proxy: ptr WlProxy; dispatcherFunc: WlDispatcherFuncT; dispatcherData: pointer; data: pointer): cint {.cdecl, importc: "wl_proxy_add_dispatcher".}
proc wlProxySetUserData*(proxy: ptr WlProxy; userData: pointer) {.cdecl, importc: "wl_proxy_set_user_data".}
proc wlProxyGetUserData*(proxy: ptr WlProxy): pointer {.cdecl, importc: "wl_proxy_get_user_data".}
proc wlProxyGetVersion*(proxy: ptr WlProxy): uint32 {.cdecl, importc: "wl_proxy_get_version".}
proc wlProxyGetId*(proxy: ptr WlProxy): uint32 {.cdecl, importc: "wl_proxy_get_id".}
proc wlProxySetTag*(proxy: ptr WlProxy; tag: cstringArray) {.cdecl, importc: "wl_proxy_set_tag".}
proc wlProxyGetTag*(proxy: ptr WlProxy): cstringArray {.cdecl, importc: "wl_proxy_get_tag".}
proc wlProxyGetClass*(proxy: ptr WlProxy): cstring {.cdecl, importc: "wl_proxy_get_class".}
proc wlProxySetQueue*(proxy: ptr WlProxy; queue: ptr WlEventQueue) {.cdecl, importc: "wl_proxy_set_queue".}
proc wlDisplayConnect*(name: cstring): ptr WlDisplay {.cdecl, importc: "wl_display_connect".}
proc wlDisplayConnectToFd*(fd: cint): ptr WlDisplay {.cdecl, importc: "wl_display_connect_to_fd".}
proc wlDisplayDisconnect*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_disconnect".}
proc wlDisplayGetFd*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_get_fd".}
proc wlDisplayDispatch*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_dispatch".}
proc wlDisplayDispatchQueue*(display: ptr WlDisplay; queue: ptr WlEventQueue): cint {.cdecl, importc: "wl_display_dispatch_queue".}
proc wlDisplayDispatchQueuePending*(display: ptr WlDisplay; queue: ptr WlEventQueue): cint {.cdecl, importc: "wl_display_dispatch_queue_pending".}
proc wlDisplayDispatchPending*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_dispatch_pending".}
proc wlDisplayGetError*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_get_error".}
proc wlDisplayGetProtocolError*(display: ptr WlDisplay; `interface`: ptr ptr WlInterface; id: ptr uint32): uint32 {.cdecl, importc: "wl_display_get_protocol_error".}
proc wlDisplayFlush*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_flush".}
proc wlDisplayRoundtripQueue*(display: ptr WlDisplay; queue: ptr WlEventQueue): cint {.cdecl, importc: "wl_display_roundtrip_queue".}
proc wlDisplayRoundtrip*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_roundtrip".}
proc wlDisplayCreateQueue*(display: ptr WlDisplay): ptr WlEventQueue {.cdecl, importc: "wl_display_create_queue".}
proc wlDisplayPrepareReadQueue*(display: ptr WlDisplay; queue: ptr WlEventQueue): cint {.cdecl, importc: "wl_display_prepare_read_queue".}
proc wlDisplayPrepareRead*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_prepare_read".}
proc wlDisplayCancelRead*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_cancel_read".}
proc wlDisplayReadEvents*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_read_events".}
proc wlLogSetHandlerClient*(handler: WlLogFuncT) {.cdecl, importc: "wl_log_set_handler_client".}
{.pop.}