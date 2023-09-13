import waylandUtil

type WlEvent {.size: sizeof(cuint).} = enum
  WlEvent_readable
  WlEvent_writable
  WlEvent_hangup
  WlEvent_error
  `--MAX--` = 31

type WlProtocolLoggerType* {.size: sizeof(cuint).} = enum
  WlProtocolLogger_request
  WlProtocolLogger_event

type pid_t* {.header: "<sys/types.h>", importc.} = cint
type gid_t* {.header: "<sys/types.h>", importc.} = cint
type uid_t* {.header: "<sys/types.h>", importc.} = cint

{.push, header: "wayland-server-core.h".}
type
  WlEventLoop* {.importc: "wl_event_loop".} = object
  WlEventSource* {.importc: "wl_event_source".} = object
  WlDisplay* {.importc: "wl_display".} = object
  WlClient* {.importc: "wl_client".} = object
  WlResource* {.importc: "wl_resource".} = object
  WlGlobal* {.importc: "wl_global".} = object
  WlShmBuffer* {.importc: "wl_shm_buffer".} = object
  WlShmPool* {.importc: "wl_shm_pool".} = object
  WlProtocolLogger* {.importc: "wl_protocol_logger".} = object

  WlEventLoopFdFuncT* {.importc: "wl_event_loop_fd_func_t".} = proc (fd: cint; mask: set[WlEvent]; data: pointer): cint {.cdecl.}
  WlEventLoopTimerFuncT* {.importc: "wl_event_loop_timer_func_t".} = proc (data: pointer): cint {.cdecl.}
  WlEventLoopSignalFuncT* {.importc: "wl_event_loop_signal_func_t".} = proc (signalNumber: cint; data: pointer): cint {.cdecl.}
  WlEventLoopIdleFuncT* {.importc: "wl_event_loop_idle_func_t".} = proc (data: pointer) {.cdecl.}
  WlNotifyFuncT* {.importc: "wl_notify_func_t".} = proc (listener: ptr WlListener; data: pointer) {.cdecl.}
  WlGlobalBindFuncT* {.importc: "wl_global_bind_func_t".} = proc (client: ptr WlClient; data: pointer; version: uint32; id: uint32) {.cdecl.}
  WlDisplayGlobalFilterFuncT* {.importc: "wl_display_global_filter_func_t".} = proc (client: ptr WlClient; global: ptr WlGlobal; data: pointer): bool {.cdecl.}
  WlClientForEachResourceIteratorFuncT* {.importc: "wl_client_for_each_resource_iterator_func_t".} = proc (resource: ptr WlResource; userData: pointer): WlIteratorResult {.cdecl.}
  WlResourceDestroyFuncT* {.importc: "wl_resource_destroy_func_t".} = proc (resource: ptr WlResource) {.cdecl.}
  WlProtocolLoggerFuncT* {.importc: "wl_protocol_logger_func_t".} = proc (userData: pointer; direction: WlProtocolLoggerType; message: ptr WlProtocolLoggerMessage) {.cdecl.}

  WlProtocolLoggerMessage* {.bycopy, importc: "wl_protocol_logger_message".} = object
    resource*: ptr WlResource
    message_opcode*: cint
    message*: ptr WlMessage
    arguments_count*: cint
    arguments*: ptr WlArgument
  WlListener* {.bycopy, importc: "wl_listener".} = object
    link*: WlList
    notify*: WlNotifyFuncT
  WlSignal* {.bycopy, importc: "wl_signal".} = object
    listener_list*: WlList


proc wlSignalInit*(signal: ptr WlSignal) {.inline, cdecl, importc: "wl_signal_init".}
proc wlSignalAdd*(signal: ptr WlSignal; listener: ptr WlListener) {.inline, cdecl, importc: "wl_signal_add".}
proc wlSignalGet*(signal: ptr WlSignal; notify: WlNotifyFuncT): ptr WlListener {.inline, cdecl, importc: "wl_signal_get".}
proc wlSignalEmit*(signal: ptr WlSignal; data: pointer) {.inline, cdecl, importc: "wl_signal_emit".}

{.pop.}

{.push, dynlib: "libwayland-server.so".}
proc wlEventLoopCreate*(): ptr WlEventLoop {.cdecl, importc: "wl_event_loop_create".}
proc wlEventLoopDestroy*(loop: ptr WlEventLoop) {.cdecl, importc: "wl_event_loop_destroy".}
proc wlEventLoopAddFd*(loop: ptr WlEventLoop; fd: cint; mask: set[WlEvent]; `func`: WlEventLoopFdFuncT; data: pointer): ptr WlEventSource {.  cdecl, importc: "wl_event_loop_add_fd".}
proc wlEventSourceFdUpdate*(source: ptr WlEventSource; mask: set[WlEvent]): cint {.cdecl, importc: "wl_event_source_fd_update".}
proc wlEventLoopAddTimer*(loop: ptr WlEventLoop; `func`: WlEventLoopTimerFuncT; data: pointer): ptr WlEventSource {.cdecl, importc: "wl_event_loop_add_timer".}
proc wlEventLoopAddSignal*(loop: ptr WlEventLoop; signalNumber: cint; `func`: WlEventLoopSignalFuncT; data: pointer): ptr WlEventSource {.  cdecl, importc: "wl_event_loop_add_signal".}
proc wlEventSourceTimerUpdate*(source: ptr WlEventSource; msDelay: cint): cint {.cdecl, importc: "wl_event_source_timer_update".}
proc wlEventSourceRemove*(source: ptr WlEventSource): cint {.cdecl, importc: "wl_event_source_remove".}
proc wlEventSourceCheck*(source: ptr WlEventSource) {.cdecl, importc: "wl_event_source_check".}
proc wlEventLoopDispatch*(loop: ptr WlEventLoop; timeout: cint): cint {.cdecl, importc: "wl_event_loop_dispatch".}
proc wlEventLoopDispatchIdle*(loop: ptr WlEventLoop) {.cdecl, importc: "wl_event_loop_dispatch_idle".}
proc wlEventLoopAddIdle*(loop: ptr WlEventLoop; `func`: WlEventLoopIdleFuncT; data: pointer): ptr WlEventSource {.cdecl, importc: "wl_event_loop_add_idle".}
proc wlEventLoopGetFd*(loop: ptr WlEventLoop): cint {.cdecl, importc: "wl_event_loop_get_fd".}

proc wlEventLoopAddDestroyListener*(loop: ptr WlEventLoop; listener: ptr WlListener) {.  cdecl, importc: "wl_event_loop_add_destroy_listener".}
proc wlEventLoopGetDestroyListener*(loop: ptr WlEventLoop; notify: WlNotifyFuncT): ptr WlListener {.  cdecl, importc: "wl_event_loop_get_destroy_listener".}
proc wlDisplayCreate*(): ptr WlDisplay {.cdecl, importc: "wl_display_create".}
proc wlDisplayDestroy*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_destroy".}
proc wlDisplayGetEventLoop*(display: ptr WlDisplay): ptr WlEventLoop {.cdecl, importc: "wl_display_get_event_loop".}
proc wlDisplayAddSocket*(display: ptr WlDisplay; name: cstring): cint {.cdecl, importc: "wl_display_add_socket".}
proc wlDisplayAddSocketAuto*(display: ptr WlDisplay): cstring {.cdecl, importc: "wl_display_add_socket_auto".}
proc wlDisplayAddSocketFd*(display: ptr WlDisplay; sockFd: cint): cint {.cdecl, importc: "wl_display_add_socket_fd".}
proc wlDisplayTerminate*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_terminate".}
proc wlDisplayRun*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_run".}
proc wlDisplayFlushClients*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_flush_clients".}
proc wlDisplayDestroyClients*(display: ptr WlDisplay) {.cdecl, importc: "wl_display_destroy_clients".}

proc wlDisplayGetSerial*(display: ptr WlDisplay): uint32 {.cdecl, importc: "wl_display_get_serial".}
proc wlDisplayNextSerial*(display: ptr WlDisplay): uint32 {.cdecl, importc: "wl_display_next_serial".}
proc wlDisplayAddDestroyListener*(display: ptr WlDisplay; listener: ptr WlListener) {.  cdecl, importc: "wl_display_add_destroy_listener".}
proc wlDisplayAddClientCreatedListener*(display: ptr WlDisplay; listener: ptr WlListener) {.cdecl, importc: "wl_display_add_client_created_listener".}
proc wlDisplayGetDestroyListener*(display: ptr WlDisplay; notify: WlNotifyFuncT): ptr WlListener {.  cdecl, importc: "wl_display_get_destroy_listener".}
proc wlGlobalCreate*(display: ptr WlDisplay; `interface`: ptr WlInterface; version: cint; data: pointer; `bind`: WlGlobalBindFuncT): ptr WlGlobal {.  cdecl, importc: "wl_global_create".}
proc wlGlobalRemove*(global: ptr WlGlobal) {.cdecl, importc: "wl_global_remove".}
proc wlGlobalDestroy*(global: ptr WlGlobal) {.cdecl, importc: "wl_global_destroy".}

proc wlDisplaySetGlobalFilter*(display: ptr WlDisplay; filter: WlDisplayGlobalFilterFuncT; data: pointer) {.  cdecl, importc: "wl_display_set_global_filter".}
proc wlGlobalGetInterface*(global: ptr WlGlobal): ptr WlInterface {.cdecl, importc: "wl_global_get_interface".}
proc wlGlobalGetName*(global: ptr WlGlobal; client: ptr WlClient): uint32 {.cdecl, importc: "wl_global_get_name".}
proc wlGlobalGetVersion*(global: ptr WlGlobal): uint32 {.cdecl, importc: "wl_global_get_version".}
proc wlGlobalGetDisplay*(global: ptr WlGlobal): ptr WlDisplay {.cdecl, importc: "wl_global_get_display".}
proc wlGlobalGetUserData*(global: ptr WlGlobal): pointer {.cdecl, importc: "wl_global_get_user_data".}
proc wlGlobalSetUserData*(global: ptr WlGlobal; data: pointer) {.cdecl, importc: "wl_global_set_user_data".}
proc wlClientCreate*(display: ptr WlDisplay; fd: cint): ptr WlClient {.cdecl, importc: "wl_client_create".}
proc wlDisplayGetClientList*(display: ptr WlDisplay): ptr WlList {.cdecl, importc: "wl_display_get_client_list".}
proc wlClientGetLink*(client: ptr WlClient): ptr WlList {.cdecl, importc: "wl_client_get_link".}
proc wlClientFromLink*(link: ptr WlList): ptr WlClient {.cdecl, importc: "wl_client_from_link".}

proc wlClientDestroy*(client: ptr WlClient) {.cdecl, importc: "wl_client_destroy".}
proc wlClientFlush*(client: ptr WlClient) {.cdecl, importc: "wl_client_flush".}
proc wlClientGetCredentials*(client: ptr WlClient; pid: ptr pid_t; uid: ptr uid_t; gid: ptr gid_t) {.cdecl, importc: "wl_client_get_credentials".}
proc wlClientGetFd*(client: ptr WlClient): cint {.cdecl, importc: "wl_client_get_fd".}
proc wlClientAddDestroyListener*(client: ptr WlClient; listener: ptr WlListener) {.  cdecl, importc: "wl_client_add_destroy_listener".}
proc wlClientGetDestroyListener*(client: ptr WlClient; notify: WlNotifyFuncT): ptr WlListener {.  cdecl, importc: "wl_client_get_destroy_listener".}
proc wlClientAddDestroyLateListener*(client: ptr WlClient; listener: ptr WlListener) {.  cdecl, importc: "wl_client_add_destroy_late_listener".}
proc wlClientGetDestroyLateListener*(client: ptr WlClient; notify: WlNotifyFuncT): ptr WlListener {.  cdecl, importc: "wl_client_get_destroy_late_listener".}
proc wlClientGetObject*(client: ptr WlClient; id: uint32): ptr WlResource {.cdecl, importc: "wl_client_get_object".}
proc wlClientPostNoMemory*(client: ptr WlClient) {.cdecl, importc: "wl_client_post_no_memory".}
proc wlClientPostImplementationError*(client: ptr WlClient; msg: cstring) {.varargs, cdecl, importc: "wl_client_post_implementation_error".}
proc wlClientAddResourceCreatedListener*(client: ptr WlClient; listener: ptr WlListener) {.cdecl, importc: "wl_client_add_resource_created_listener".}

proc wlClientForEachResource*(client: ptr WlClient; `iterator`: WlClientForEachResourceIteratorFuncT; userData: pointer) {.cdecl, importc: "wl_client_for_each_resource".}

proc wlSignalEmitMutable*(signal: ptr WlSignal; data: pointer) {.cdecl, importc: "wl_signal_emit_mutable".}

proc wlResourcePostEvent*(resource: ptr WlResource; opcode: uint32) {.varargs, cdecl, importc: "wl_resource_post_event".}
proc wlResourcePostEventArray*(resource: ptr WlResource; opcode: uint32; args: ptr WlArgument) {.cdecl, importc: "wl_resource_post_event_array".}
proc wlResourceQueueEvent*(resource: ptr WlResource; opcode: uint32) {.varargs, cdecl, importc: "wl_resource_queue_event".}
proc wlResourceQueueEventArray*(resource: ptr WlResource; opcode: uint32; args: ptr WlArgument) {.cdecl, importc: "wl_resource_queue_event_array".}

proc wlResourcePostError*(resource: ptr WlResource; code: uint32; msg: cstring) {.  varargs, cdecl, importc: "wl_resource_post_error".}
proc wlResourcePostNoMemory*(resource: ptr WlResource) {.cdecl, importc: "wl_resource_post_no_memory".}
proc wlClientGetDisplay*(client: ptr WlClient): ptr WlDisplay {.cdecl, importc: "wl_client_get_display".}
proc wlResourceCreate*(client: ptr WlClient; `interface`: ptr WlInterface; version: cint; id: uint32): ptr WlResource {.cdecl, importc: "wl_resource_create".}
proc wlResourceSetImplementation*(resource: ptr WlResource; implementation: pointer; data: pointer; destroy: WlResourceDestroyFuncT) {.  cdecl, importc: "wl_resource_set_implementation".}
proc wlResourceSetDispatcher*(resource: ptr WlResource; dispatcher: WlDispatcherFuncT; implementation: pointer; data: pointer; destroy: WlResourceDestroyFuncT) {.cdecl, importc: "wl_resource_set_dispatcher".}
proc wlResourceDestroy*(resource: ptr WlResource) {.cdecl, importc: "wl_resource_destroy".}
proc wlResourceGetId*(resource: ptr WlResource): uint32 {.cdecl, importc: "wl_resource_get_id".}
proc wlResourceGetLink*(resource: ptr WlResource): ptr WlList {.cdecl, importc: "wl_resource_get_link".}
proc wlResourceFromLink*(resource: ptr WlList): ptr WlResource {.cdecl, importc: "wl_resource_from_link".}
proc wlResourceFindForClient*(list: ptr WlList; client: ptr WlClient): ptr WlResource {.  cdecl, importc: "wl_resource_find_for_client".}
proc wlResourceGetClient*(resource: ptr WlResource): ptr WlClient {.cdecl, importc: "wl_resource_get_client".}
proc wlResourceSetUserData*(resource: ptr WlResource; data: pointer) {.cdecl, importc: "wl_resource_set_user_data".}
proc wlResourceGetUserData*(resource: ptr WlResource): pointer {.cdecl, importc: "wl_resource_get_user_data".}
proc wlResourceGetVersion*(resource: ptr WlResource): cint {.cdecl, importc: "wl_resource_get_version".}
proc wlResourceSetDestructor*(resource: ptr WlResource; destroy: WlResourceDestroyFuncT) {.cdecl, importc: "wl_resource_set_destructor".}
proc wlResourceInstanceOf*(resource: ptr WlResource; `interface`: ptr WlInterface; implementation: pointer): cint {.cdecl, importc: "wl_resource_instance_of".}
proc wlResourceGetClass*(resource: ptr WlResource): cstring {.cdecl, importc: "wl_resource_get_class".}
proc wlResourceAddDestroyListener*(resource: ptr WlResource; listener: ptr WlListener) {.cdecl, importc: "wl_resource_add_destroy_listener".}
proc wlResourceGetDestroyListener*(resource: ptr WlResource; notify: WlNotifyFuncT): ptr WlListener {.  cdecl, importc: "wl_resource_get_destroy_listener".}
proc wlShmBufferGet*(resource: ptr WlResource): ptr WlShmBuffer {.cdecl, importc: "wl_shm_buffer_get".}
proc wlShmBufferBeginAccess*(buffer: ptr WlShmBuffer) {.cdecl, importc: "wl_shm_buffer_begin_access".}
proc wlShmBufferEndAccess*(buffer: ptr WlShmBuffer) {.cdecl, importc: "wl_shm_buffer_end_access".}
proc wlShmBufferGetData*(buffer: ptr WlShmBuffer): pointer {.cdecl, importc: "wl_shm_buffer_get_data".}
proc wlShmBufferGetStride*(buffer: ptr WlShmBuffer): int32 {.cdecl, importc: "wl_shm_buffer_get_stride".}
proc wlShmBufferGetFormat*(buffer: ptr WlShmBuffer): uint32 {.cdecl, importc: "wl_shm_buffer_get_format".}
proc wlShmBufferGetWidth*(buffer: ptr WlShmBuffer): int32 {.cdecl, importc: "wl_shm_buffer_get_width".}
proc wlShmBufferGetHeight*(buffer: ptr WlShmBuffer): int32 {.cdecl, importc: "wl_shm_buffer_get_height".}
proc wlShmBufferRefPool*(buffer: ptr WlShmBuffer): ptr WlShmPool {.cdecl, importc: "wl_shm_buffer_ref_pool".}
proc wlShmPoolUnref*(pool: ptr WlShmPool) {.cdecl, importc: "wl_shm_pool_unref".}
proc wlDisplayInitShm*(display: ptr WlDisplay): cint {.cdecl, importc: "wl_display_init_shm".}
proc wlDisplayAddShmFormat*(display: ptr WlDisplay; format: uint32): ptr uint32 {.cdecl, importc: "wl_display_add_shm_format".}
proc wlShmBufferCreate*(client: ptr WlClient; id: uint32; width: int32; height: int32; stride: int32; format: uint32): ptr WlShmBuffer {.cdecl, importc: "wl_shm_buffer_create".}
proc wlLogSetHandlerServer*(handler: WlLogFuncT) {.cdecl, importc: "wl_log_set_handler_server".}

proc wlDisplayAddProtocolLogger*(display: ptr WlDisplay; a2: WlProtocolLoggerFuncT; userData: pointer): ptr WlProtocolLogger {.cdecl, importc: "wl_display_add_protocol_logger".}
proc wlProtocolLoggerDestroy*(logger: ptr WlProtocolLogger) {.cdecl, importc: "wl_protocol_logger_destroy".}
{.pop.}