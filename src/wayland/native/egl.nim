import common
import client
type wl_egl_window* = object
const
  WL_EGL_PLATFORM* = 1
discard "forward decl of wl_egl_window"
discard "forward decl of wl_surface"
proc wl_egl_window_create*(surface: ptr wl_surface; width: cint; height: cint): ptr wl_egl_window {.
    nimcall, importc: "wl_egl_window_create", dynlib: "libwayland-egl.so".}
proc wl_egl_window_destroy*(egl_window: ptr wl_egl_window) {.nimcall,
    importc: "wl_egl_window_destroy", dynlib: "libwayland-egl.so".}
proc wl_egl_window_resize*(egl_window: ptr wl_egl_window; width: cint; height: cint;
                          dx: cint; dy: cint) {.nimcall,
    importc: "wl_egl_window_resize", dynlib: "libwayland-egl.so".}
proc wl_egl_window_get_attached_size*(egl_window: ptr wl_egl_window;
                                     width: ptr cint; height: ptr cint) {.nimcall,
    importc: "wl_egl_window_get_attached_size", dynlib: "libwayland-egl.so".}