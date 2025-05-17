const
  WL_EGL_PLATFORM* = 1
discard "forward decl of wl_egl_window"
discard "forward decl of wl_surface"
proc create_egl_window*(surface: ptr Surface; width: cint; height: cint): ptr EglWindow {.
    nimcall, importc: "wl_egl_window_create", dynlib: "libwayland-egl.so".}
proc destroy*(egl_window: ptr EglWindow) {.nimcall, importc: "wl_egl_window_destroy",
                                       dynlib: "libwayland-egl.so".}
proc resize*(egl_window: ptr EglWindow; width: cint; height: cint; dx: cint; dy: cint) {.
    nimcall, importc: "wl_egl_window_resize", dynlib: "libwayland-egl.so".}
proc get_attached_size*(egl_window: ptr EglWindow; width: ptr cint; height: ptr cint) {.
    nimcall, importc: "wl_egl_window_get_attached_size", dynlib: "libwayland-egl.so".}