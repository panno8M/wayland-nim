import common
import server
type wl_cursor_theme* = object
discard "forward decl of wl_cursor_theme"
discard "forward decl of wl_buffer"
discard "forward decl of wl_shm"
type
  image* {.bycopy.} = object
    width*: uint32
    height*: uint32
    hotspot_x*: uint32
    hotspot_y*: uint32
    delay*: uint32
  wl_cursor* {.bycopy.} = object
    image_count*: cuint
    images*: ptr ptr image
    name*: cstring
proc load_cursor_theme*(name: cstring; size: cint; shm: ptr wl_shm): ptr theme {.nimcall,
    importc: "wl_cursor_theme_load", dynlib: "libwayland-cursor.so".}
proc destroy*(theme: ptr theme) {.nimcall, importc: "wl_cursor_theme_destroy",
                              dynlib: "libwayland-cursor.so".}
proc get_cursor*(theme: ptr theme; name: cstring): ptr wl_cursor {.nimcall,
    importc: "wl_cursor_theme_get_cursor", dynlib: "libwayland-cursor.so".}
proc get_buffer*(image: ptr image): ptr wl_buffer {.nimcall,
    importc: "wl_cursor_image_get_buffer", dynlib: "libwayland-cursor.so".}
proc frame*(cursor: ptr wl_cursor; time: uint32): cint {.nimcall,
    importc: "wl_cursor_frame", dynlib: "libwayland-cursor.so".}
proc frame_and_duration*(cursor: ptr wl_cursor; time: uint32; duration: ptr uint32): cint {.
    nimcall, importc: "wl_cursor_frame_and_duration", dynlib: "libwayland-cursor.so".}