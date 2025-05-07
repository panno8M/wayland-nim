import std/posix

type
  gid_t* = Gid
  pid_t* = Pid
  uid_t* = Uid

  wl_buffer* {.exportc: "wl_buffer".} = object
  wl_callback* {.exportc: "wl_callback".} = object
  wl_client* {.exportc: "wl_client".} = object
  wl_compositor* {.exportc: "wl_compositor".} = object
  wl_connection* {.exportc: "wl_connection".} = object
  wl_data_device* {.exportc: "wl_data_device".} = object
  wl_data_device_manager* {.exportc: "wl_data_device_manager".} = object
  wl_data_offer* {.exportc: "wl_data_offer".} = object
  wl_data_source* {.exportc: "wl_data_source".} = object
  wl_display* {.exportc: "wl_display".} = object
  wl_event_loop* {.exportc: "wl_event_loop".} = object
  wl_event_queue* {.exportc: "wl_event_queue".} = object
  wl_event_source* {.exportc: "wl_event_source".} = object
  wl_fixes* {.exportc: "wl_fixes".} = object
  wl_global* {.exportc: "wl_global".} = object
  wl_keyboard* {.exportc: "wl_keyboard".} = object
  wl_output* {.exportc: "wl_output".} = object
  wl_pointer* {.exportc: "wl_pointer".} = object
  wl_protocol_logger* {.exportc: "wl_protocol_logger".} = object
  wl_proxy* {.exportc: "wl_proxy".} = object
  wl_region* {.exportc: "wl_region".} = object
  wl_registry* {.exportc: "wl_registry".} = object
  wl_seat* {.exportc: "wl_seat".} = object
  wl_shell* {.exportc: "wl_shell".} = object
  wl_shell_surface* {.exportc: "wl_shell_surface".} = object
  wl_shm* {.exportc: "wl_shm".} = object
  wl_shm_buffer* {.exportc: "wl_shm_buffer".} = object
  wl_shm_pool* {.exportc: "wl_shm_pool".} = object
  wl_subcompositor* {.exportc: "wl_subcompositor".} = object
  wl_subsurface* {.exportc: "wl_subsurface".} = object
  wl_surface* {.exportc: "wl_surface".} = object
  wl_touch* {.exportc: "wl_touch".} = object

  wl_message* {.bycopy.} = object
    name*: cstring
    signature*: cstring
    types*: ptr ptr wl_interface

  wl_interface* {.bycopy.} = object
    name*: cstring
    version*: cint
    method_count*: cint
    methods*: ptr wl_message
    event_count*: cint
    events*: ptr wl_message

  wl_list* {.bycopy.} = object
    prev*: ptr wl_list
    next*: ptr wl_list

  wl_array* {.bycopy.} = object
    size*: csize_t
    alloc*: csize_t
    data*: pointer

  wl_fixed_t* = int32

  wl_argument* {.bycopy, union.} = object
    i*: int32
    u*: uint32
    f*: wl_fixed_t
    s*: cstring
    o*: ptr wl_object
    n*: uint32
    a*: ptr wl_array
    h*: int32

  wl_object* {.exportc: "wl_object".} = object
    `interface`*: ptr wl_interface
    implementation*: pointer
    id*: uint32

  wl_dispatcher_func_t* = proc (user_data: pointer; target: pointer;
                                opcode: uint32; msg: ptr wl_message;
                                args: ptr wl_argument): cint
  wl_log_func_t* = proc (fmt: cstring; args: va_list)
  wl_iterator_result* {.size: sizeof(cint).} = enum
    WL_ITERATOR_STOP, WL_ITERATOR_CONTINUE

  va_list* {.importc: "va_list", header: "<stdarg.h>".} = object

{.push, dynlib: "libwayland-client.so".}

func init*(list: ptr wl_list) {.importc: "wl_list_init".}
func insert*(list: ptr wl_list; elm: ptr wl_list | var wl_list) {.importc: "wl_list_insert".}
func remove*(elm: ptr wl_list) {.importc: "wl_list_remove".}
func length*(list: ptr wl_list): cint {.importc: "wl_list_length".}
func empty*(list: ptr wl_list): bool {.importc: "wl_list_empty".}
func insert_list*(list: ptr wl_list; other: ptr wl_list) {.importc: "wl_list_insert_list".}

func init*(list: var wl_list) = init(addr(list))
func insert*(list: var wl_list; elm: var wl_list) = insert(addr(list), addr(elm))
func insert*(list: ptr wl_list; elm: var wl_list) = insert(list, addr(elm))
func insert*(list: var wl_list; elm: ptr wl_list) = insert(addr(list), elm)
func remove*(elm: var wl_list) = remove(addr(elm))
func length*(list: var wl_list): cint = length(addr(list))
func empty*(list: var wl_list): bool = empty(addr(list))
func insert_list*(list: var wl_list; other: var wl_list) = insert_list(addr(list), addr(other))
func insert_list*(list: ptr wl_list; other: var wl_list) = insert_list(list, addr(other))
func insert_list*(list: var wl_list; other: ptr wl_list) = insert_list(addr(list), other)

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

func init*(array: ptr wl_array) {.importc: "wl_array_init".}
func release*(array: ptr wl_array) {.importc: "wl_array_release".}
func add*(array: ptr wl_array; size: csize_t): pointer {.importc: "wl_array_add".}
func copy*(array: ptr wl_array; source: ptr wl_array): cint {.importc: "wl_array_copy".}

func init*(array: var wl_array) = init(addr(array))
func release*(array: var wl_array) = release(addr(array))
func add*(array: var wl_array; size: csize_t): pointer = add(addr(array), size)
func copy*(array: var wl_array; source: var wl_array): cint = copy(addr(array), addr(source))
func copy*(array: ptr wl_array; source: var wl_array): cint = copy(array, addr(source))
func copy*(array: var wl_array; source: ptr wl_array): cint = copy(addr(array), source)

func add*[T](array: ptr wl_array; _: typedesc[T]): ptr T =
  cast[ptr T](array.add csize_t sizeof T)
func add*[T](array: var wl_array; _: typedesc[T]): ptr T =
  cast[ptr T](array.add csize_t sizeof T)

template wl_array_for_each*(pos, array; body) =
  pos = cast[typeof pos](array.data)
  while array.size != 0 and cast[uint](pos) < cast[uint](array.data) + array.size:
    body
    pos = cast[typeof pos](cast[uint](pos) + uint sizeof pos[])

func to_double*(f: wl_fixed_t): cdouble {.inline, importc: "wl_fixed_to_double".}
func wl_fixed_from_double*(d: cdouble): wl_fixed_t {.inline,
    importc: "wl_fixed_from_double".}
func to_int*(f: wl_fixed_t): cint {.inline, importc: "wl_fixed_to_int".}
func wl_fixed_from_int*(i: cint): wl_fixed_t {.inline,
    importc: "wl_fixed_from_int".}

func to_fixed*(d: cdouble): wl_fixed_t {.inline.} = wl_fixed_from_double d
func to_fixed*(i: cint): wl_fixed_t {.inline.} = wl_fixed_from_int i