{.push, header: "wayland-cursor.h".}
type WlCursorTheme {.importc: "struct wl_cursor_theme".} = object
type WlBuffer {.importc: "struct wl_buffer".} = object
type WlShm {.importc: "struct wl_shm".} = object
type WlCursorImage* {.bycopy, importc: "struct wl_cursor_image".} = object
  width*: uint32
  height*: uint32
  hotspotX*: uint32
  hotspotY*: uint32
  delay*: uint32
type WlCursor* {.bycopy, importc: "struct wl_cursor".} = object
  imageCount*: cuint
  images*: ptr UncheckedArray[WlCursorImage]
  name*: cstring
{.pop.}


{.push, dynlib: "libwayland-cursor.so".}
proc wlCursorThemeLoad*(name: cstring; size: cint; shm: ptr WlShm): ptr WlCursorTheme {.cdecl, importc: "wl_cursor_theme_load".}
proc wlCursorThemeDestroy*(theme: ptr WlCursorTheme) {.cdecl, importc: "wl_cursor_theme_destroy".}
proc wlCursorThemeGetCursor*(theme: ptr WlCursorTheme; name: cstring): ptr WlCursor {.cdecl, importc: "wl_cursor_theme_get_cursor".}
proc wlCursorImageGetBuffer*(image: ptr WlCursorImage): ptr WlBuffer {.cdecl, importc: "wl_cursor_image_get_buffer".}
proc wlCursorFrame*(cursor: ptr WlCursor; time: uint32): cint {.cdecl, importc: "wl_cursor_frame".}
proc wlCursorFrameAndDuration*(cursor: ptr WlCursor; time: uint32; duration: ptr uint32): cint {.cdecl, importc: "wl_cursor_frame_and_duration".}
{.pop.}