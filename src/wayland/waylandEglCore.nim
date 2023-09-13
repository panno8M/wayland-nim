import waylandEglBackend

{.push, header: "wayland-egl-core.h".}
var WL_EGL_PLATFORM* {.importc.}: int
type WlSurface {.importc: "struct wl_surface".} = object
{.pop.}

{.push, dynlib: "libwayland-egl.so".}
proc wlEglWindowCreate*(surface: ptr WlSurface; width: cint; height: cint): ptr WlEglWindow {.cdecl, importc: "wl_egl_window_create".}
proc wlEglWindowDestroy*(eglWindow: ptr WlEglWindow) {.cdecl, importc: "wl_egl_window_destroy".}
proc wlEglWindowResize*(eglWindow: ptr WlEglWindow; width: cint; height: cint; dx: cint; dy: cint) {.cdecl, importc: "wl_egl_window_resize".}
proc wlEglWindowGetAttachedSize*(eglWindow: ptr WlEglWindow; width: ptr cint; height: ptr cint) {.cdecl, importc: "wl_egl_window_get_attached_size".}
{.pop.}