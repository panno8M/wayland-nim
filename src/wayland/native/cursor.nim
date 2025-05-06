import common
import server
type wl_cursor_theme* = object
discard "forward decl of wl_cursor_theme"
discard "forward decl of wl_buffer"
discard "forward decl of wl_shm"
type
  wl_cursor_image* {.bycopy.} = object
    width*: uint32
    height*: uint32
    hotspot_x*: uint32
    hotspot_y*: uint32
    delay*: uint32
  wl_cursor* {.bycopy.} = object
    image_count*: cuint
    images*: ptr ptr wl_cursor_image
    name*: cstring
proc wl_cursor_theme_load*(name: cstring; size: cint; shm: ptr wl_shm): ptr wl_cursor_theme {.
    nimcall, importc: "wl_cursor_theme_load", dynlib: "libwayland-cursor.so".}
proc wl_cursor_theme_destroy*(theme: ptr wl_cursor_theme) {.nimcall,
    importc: "wl_cursor_theme_destroy", dynlib: "libwayland-cursor.so".}
proc wl_cursor_theme_get_cursor*(theme: ptr wl_cursor_theme; name: cstring): ptr wl_cursor {.
    nimcall, importc: "wl_cursor_theme_get_cursor", dynlib: "libwayland-cursor.so".}
proc wl_cursor_image_get_buffer*(image: ptr wl_cursor_image): ptr wl_buffer {.nimcall,
    importc: "wl_cursor_image_get_buffer", dynlib: "libwayland-cursor.so".}
proc wl_cursor_frame*(cursor: ptr wl_cursor; time: uint32): cint {.nimcall,
    importc: "wl_cursor_frame", dynlib: "libwayland-cursor.so".}
proc wl_cursor_frame_and_duration*(cursor: ptr wl_cursor; time: uint32;
                                  duration: ptr uint32): cint {.nimcall,
    importc: "wl_cursor_frame_and_duration", dynlib: "libwayland-cursor.so".}