
{.push, header: "wayland-util.h".}
type WlObject* {.importc: "wl_object".} = object

type
  WlInterface* {.bycopy, importc: "wl_interface".} = object
    name*: cstring
    version*: cint
    method_count*: cint
    methods*: ptr WlMessage
    event_count*: cint
    events*: ptr WlMessage
  WlMessage* {.bycopy, importc: "wl_message".} = object
    name*: cstring
    signature*: cstring
    types*: ptr ptr WlInterface
type WlList* {.bycopy, importc: "wl_list".} = object
  prev*: ptr WlList
  next*: ptr WlList
type WlArray* {.bycopy, importc: "wl_array".} = object
  size*: csize_t
  alloc*: csize_t
  data*: pointer
{.pop.}


{.push, dynlib: "libwayland-client.so".}
proc wlListInit*(list: ptr WlList) {.cdecl, importc: "wl_list_init".}

proc wlListInsert*(list: ptr WlList; elm: ptr WlList) {.cdecl, importc: "wl_list_insert".}
proc wlListRemove*(elm: ptr WlList) {.cdecl, importc: "wl_list_remove".}
proc wlListLength*(list: ptr WlList): cint {.cdecl, importc: "wl_list_length".}
proc wlListEmpty*(list: ptr WlList): cint {.cdecl, importc: "wl_list_empty".}
proc wlListInsertList*(list: ptr WlList; other: ptr WlList) {.cdecl, importc: "wl_list_insert_list".}


# proc wlContainerOf*(`ptr`: untyped; sample: untyped; member: untyped) {.  importc: "wl_container_of", header: "wayland-util.h".}


proc wlArrayInit*(array: ptr WlArray) {.cdecl, importc: "wl_array_init".}
proc wlArrayRelease*(array: ptr WlArray) {.cdecl, importc: "wl_array_release".}
proc wlArrayAdd*(array: ptr WlArray; size: csize_t): pointer {.cdecl, importc: "wl_array_add".}
proc wlArrayCopy*(array: ptr WlArray; source: ptr WlArray): cint {.cdecl, importc: "wl_array_copy".}

{.pop.}


type WlFixedT* = int32

type va_list {.header: "<stdarg.h>", importc.} = object

{.push, header: "wayland-util.h".}
proc wlFixedToDouble*(f: WlFixedT): cdouble {.inline, cdecl, importc: "wl_fixed_to_double".}
proc wlFixedFromDouble*(d: cdouble): WlFixedT {.inline, cdecl, importc: "wl_fixed_from_double".}
proc wlFixedToInt*(f: WlFixedT): cint {.inline, cdecl, importc: "wl_fixed_to_int".}
proc wlFixedFromInt*(i: cint): WlFixedT {.inline, cdecl, importc: "wl_fixed_from_int".}

type WlArgument* {.bycopy, union, importc: "wl_argument".} = object
  i*: int32
  u*: uint32
  f*: WlFixedT
  s*: cstring
  o*: ptr WlObject
  n*: uint32
  a*: ptr WlArray
  h*: int32

type WlDispatcherFuncT* {.importc: "wl_dispatcher_func_t".} = proc (userData: pointer; target: pointer; opcode: uint32; msg: ptr WlMessage; args: ptr WlArgument): cint {.cdecl.}
type WlLogFuncT* = proc (fmt: cstring; args: va_list) {.cdecl.}
type WlIteratorResult* = enum
  WL_ITERATOR_STOP, WL_ITERATOR_CONTINUE
{.pop.}