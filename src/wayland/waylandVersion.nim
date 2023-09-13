{.pragma: from_header, header: "wayland-version.h".}

var WAYLAND_VERSION_MAJOR* {.from_header, importc.}: int
var WAYLAND_VERSION_MINOR* {.from_header, importc.}: int
var WAYLAND_VERSION_MICRO* {.from_header, importc.}: int
var WAYLAND_VERSION* {.from_header, importc.}: cstring