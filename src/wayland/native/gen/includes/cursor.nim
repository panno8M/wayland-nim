
discard "forward decl of wl_cursor_theme"
discard "forward decl of wl_buffer"
discard "forward decl of wl_shm"
type
  CursorImage* {.bycopy.} = object
    width*: uint32
    height*: uint32
    hotspot_x*: uint32
    hotspot_y*: uint32
    delay*: uint32
  Cursor* {.bycopy.} = object
    image_count*: cuint
    images*: ptr UncheckedArray[ptr CursorImage]
    name*: cstring
proc load_cursor_theme*(name: cstring; size: cint; shm: ptr Shm): ptr CursorTheme {.
    importc: "wl_cursor_theme_load", dynlib: "libwayland-cursor.so".}
proc destroy*(theme: ptr CursorTheme) {.importc: "wl_cursor_theme_destroy",
                                        dynlib: "libwayland-cursor.so".}
proc get_cursor*(theme: ptr CursorTheme; name: cstring): ptr Cursor {.
    importc: "wl_cursor_theme_get_cursor", dynlib: "libwayland-cursor.so".}
proc get_buffer*(image: ptr CursorImage): ptr Buffer {.
    importc: "wl_cursor_image_get_buffer", dynlib: "libwayland-cursor.so".}
proc frame*(cursor: ptr Cursor; time: uint32): cint {.
    importc: "wl_cursor_frame", dynlib: "libwayland-cursor.so".}
proc frame_and_duration*(cursor: ptr Cursor; time: uint32; duration: ptr uint32): cint {.
    importc: "wl_cursor_frame_and_duration", dynlib: "libwayland-cursor.so".}