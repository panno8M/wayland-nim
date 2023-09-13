
type intptr_t {.header: "<stdint.h>", importc.} = clong

{.push, header: "wayland-egl-backend.h".}
var WL_EGL_WINDOW_VERSION* {.compileTime, importc.}: int
type WlSurface {.importc: "struct wl_surface".} = object
type WlEglWindow* {.bycopy, importc: "struct wl_egl_window".} = object
  version* : intptr_t
  width* : cint
  height* : cint
  dx* : cint
  dy* : cint
  attached_width* : cint
  attached_height* : cint
  driver_private* : pointer
  resize_callback* : proc (a1: ptr WlEglWindow; a2: pointer) {.cdecl.}
  destroy_window_callback* : proc (a1: pointer) {.cdecl.}
  surface* : ptr WlSurface
{.pop.}