import std/posix

type
  gid_t* = Gid
  pid_t* = Pid
  uid_t* = Uid

  Buffer* {.exportc: "wl_buffer".} = object
  Callback* {.exportc: "wl_callback".} = object
  Client* {.exportc: "wl_client".} = object
  Compositor* {.exportc: "wl_compositor".} = object
  Connection* {.exportc: "wl_connection".} = object
  DataDevice* {.exportc: "wl_data_device".} = object
  DataDeviceManager* {.exportc: "wl_data_device_manager".} = object
  DataOffer* {.exportc: "wl_data_offer".} = object
  DataSource* {.exportc: "wl_data_source".} = object
  Display* {.exportc: "wl_display".} = object
  EventLoop* {.exportc: "wl_event_loop".} = object
  EventQueue* {.exportc: "wl_event_queue".} = object
  EventSource* {.exportc: "wl_event_source".} = object
  Fixes* {.exportc: "wl_fixes".} = object
  Global* {.exportc: "wl_global".} = object
  Keyboard* {.exportc: "wl_keyboard".} = object
  Output* {.exportc: "wl_output".} = object
  Pointer* {.exportc: "wl_pointer".} = object
  Protocol_logger* {.exportc: "wl_protocol_logger".} = object
  Proxy* {.exportc: "wl_proxy".} = object
  Region* {.exportc: "wl_region".} = object
  Registry* {.exportc: "wl_registry".} = object
  Seat* {.exportc: "wl_seat".} = object
  Shell* {.exportc: "wl_shell".} = object
  ShellSurface* {.exportc: "wl_shell_surface".} = object
  Shm* {.exportc: "wl_shm".} = object
  ShmBuffer* {.exportc: "wl_shm_buffer".} = object
  ShmPool* {.exportc: "wl_shm_pool".} = object
  Subcompositor* {.exportc: "wl_subcompositor".} = object
  Subsurface* {.exportc: "wl_subsurface".} = object
  Surface* {.exportc: "wl_surface".} = object
  Touch* {.exportc: "wl_touch".} = object

  Message* {.bycopy.} = object
    name*: cstring
    signature*: cstring
    types*: ptr ptr Interface

  Interface* {.bycopy.} = object
    name*: cstring
    version*: cint
    method_count*: cint
    methods*: ptr Message
    event_count*: cint
    events*: ptr Message

  List* {.bycopy.} = object
    prev*: ptr List
    next*: ptr List

  Array* {.bycopy.} = object
    size*: csize_t
    alloc*: csize_t
    data*: pointer

  Fixed* = int32

  Argument* {.bycopy, union.} = object
    i*: int32
    u*: uint32
    f*: Fixed
    s*: cstring
    o*: ptr Object
    n*: uint32
    a*: ptr Array
    h*: int32

  Object* {.exportc: "wl_object".} = object
    `interface`*: ptr Interface
    implementation*: pointer
    id*: uint32

  wl_dispatcher_func_t* = proc (user_data: pointer; target: pointer;
                                opcode: uint32; msg: ptr Message;
                                args: ptr Argument): cint
  wl_log_func_t* = proc (fmt: cstring; args: va_list)
  wl_iterator_result* {.size: sizeof(cint).} = enum
    WL_ITERATOR_STOP, WL_ITERATOR_CONTINUE

  va_list* {.importc: "va_list", header: "<stdarg.h>".} = object

{.push, dynlib: "libwayland-client.so".}

func init*(list: ptr List) {.importc: "wl_list_init".}
func insert*(list: ptr List; elm: ptr List) {.importc: "wl_list_insert".}
func remove*(elm: ptr List) {.importc: "wl_list_remove".}
func length*(list: ptr List): cint {.importc: "wl_list_length".}
func empty*(list: ptr List): bool {.importc: "wl_list_empty".}
func insert_list*(list: ptr List; other: ptr List) {.importc: "wl_list_insert_list".}

func init*(list: var List) = init(addr(list))
func insert*(list: var List; elm: var List) = insert(addr(list), addr(elm))
func insert*(list: ptr List; elm: var List) = insert(list, addr(elm))
func insert*(list: var List; elm: ptr List) = insert(addr(list), elm)
func remove*(elm: var List) = remove(addr(elm))
func length*(list: var List): cint = length(addr(list))
func empty*(list: var List): bool = empty(addr(list))
func insert_list*(list: var List; other: var List) = insert_list(addr(list), addr(other))
func insert_list*(list: ptr List; other: var List) = insert_list(list, addr(other))
func insert_list*(list: var List; other: ptr List) = insert_list(addr(list), other)

template wl_container_of*(`ptr`, sample, member: untyped): untyped =
  cast[typeof sample](cast[int](`ptr`) - offsetof(typeof(sample[]), member))

template wl_list_for_each*(pos, head, member; body): untyped =
  pos = wl_container_of(head.next, pos, member)
  while pos.member.addr != head:
    body
    pos = wl_container_of(pos.member.next, pos, member)

template wl_list_for_each_safe*(pos, tmp, head, member; body): untyped =
  pos = wl_container_of(head.next, pos, member)
  tmp = wl_container_of(pos.member.next, tmp, member)
  while pos.member.addr != head:
    body
    pos = tmp
    tmp = wl_container_of(pos.member.next, tmp, member)

template wl_list_for_each_reverse*(pos, head, member; body): untyped =
  pos = wl_container_of(head.prev, pos, member)
  while pos.member.addr != head:
    body
    pos = wl_container_of(pos.member.prev, pos, member)

func init*(array: ptr Array) {.importc: "wl_array_init".}
func release*(array: ptr Array) {.importc: "wl_array_release".}
func add*(array: ptr Array; size: csize_t): pointer {.importc: "wl_array_add".}
func copy*(array: ptr Array; source: ptr Array): cint {.importc: "wl_array_copy".}

func init*(array: var Array) = init(addr(array))
func release*(array: var Array) = release(addr(array))
func add*(array: var Array; size: csize_t): pointer = add(addr(array), size)
func copy*(array: var Array; source: var Array): cint = copy(addr(array), addr(source))
func copy*(array: ptr Array; source: var Array): cint = copy(array, addr(source))
func copy*(array: var Array; source: ptr Array): cint = copy(addr(array), source)

func add*[T](array: ptr Array; _: typedesc[T]): ptr T =
  cast[ptr T](array.add csize_t sizeof T)
func add*[T](array: var Array; _: typedesc[T]): ptr T =
  cast[ptr T](array.add csize_t sizeof T)

template wl_array_for_each*(pos, array; body) =
  pos = cast[typeof pos](array.data)
  while array.size != 0 and cast[uint](pos) < cast[uint](array.data) + array.size:
    body
    pos = cast[typeof pos](cast[uint](pos) + uint sizeof pos[])

func to_double*(f: Fixed): cdouble {.inline, importc: "wl_fixed_to_double".}
func wl_fixed_from_double*(d: cdouble): Fixed {.inline,
    importc: "wl_fixed_from_double".}
func to_int*(f: Fixed): cint {.inline, importc: "wl_fixed_to_int".}
func wl_fixed_from_int*(i: cint): Fixed {.inline,
    importc: "wl_fixed_from_int".}

func to_fixed*(d: cdouble): Fixed {.inline.} = wl_fixed_from_double d
func to_fixed*(i: cint): Fixed {.inline.} = wl_fixed_from_int i