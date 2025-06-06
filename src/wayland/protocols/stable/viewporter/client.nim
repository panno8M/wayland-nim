# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/client
import wayland/native/common
import code
export code

## The viewporter CLIENT protocol
## ##############################
## 
## Interfaces
## ==========
## 
## * wp_viewporter
## * wp_viewport
## 
## Copyright
## =========
## 
## Copyright © 2013-2016 Collabora, Ltd.
## 
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice (including the next
## paragraph) shall be included in all copies or substantial portions of the
## Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.
## 

proc setUserData*(wpViewporter: ptr WpViewporter; userData: pointer) {.inline.} =
  cast[ptr Proxy](wpViewporter).set_user_data(user_data)
proc getUserData*(wpViewporter: ptr WpViewporter): pointer {.inline.} =
  cast[ptr Proxy](wpViewporter).get_user_data()
proc getVersion*(wpViewporter: ptr WpViewporter): uint32 {.inline.} =
  cast[ptr Proxy](wpViewporter).get_version()
proc destroy*(wpViewporter: ptr WpViewporter) {.inline.} =
  ## unbind from the cropping and scaling interface
  ## 
  ## Informs the server that the client will not be using this
  ## 	protocol object anymore. This does not affect any other objects,
  ## 	wp_viewport objects included.
  ## 
  cast[ptr Proxy](wpViewporter).marshal_flags(WpViewporterRequest_destroy.ord, nil, cast[ptr Proxy](wpViewporter).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc getViewport*(wpViewporter: ptr WpViewporter; surface: ptr Surface): ptr WpViewport {.inline.} =
  ## extend surface interface for crop and scale
  ## 
  ## Instantiate an interface extension for the given wl_surface to
  ## 	crop and scale its content. If the given wl_surface already has
  ## 	a wp_viewport object associated, the viewport_exists
  ## 	protocol error is raised.
  ## 
  cast[ptr WpViewport](cast[ptr Proxy](wpViewporter).marshal_flags(WpViewporterRequest_get_viewport.ord, addr wp_viewport_interface, cast[ptr Proxy](wpViewporter).get_version(), 0, nil, surface))
proc setUserData*(wpViewport: ptr WpViewport; userData: pointer) {.inline.} =
  cast[ptr Proxy](wpViewport).set_user_data(user_data)
proc getUserData*(wpViewport: ptr WpViewport): pointer {.inline.} =
  cast[ptr Proxy](wpViewport).get_user_data()
proc getVersion*(wpViewport: ptr WpViewport): uint32 {.inline.} =
  cast[ptr Proxy](wpViewport).get_version()
proc destroy*(wpViewport: ptr WpViewport) {.inline.} =
  ## remove scaling and cropping from the surface
  ## 
  ## The associated wl_surface's crop and scale state is removed.
  ## 	The change is applied on the next wl_surface.commit.
  ## 
  cast[ptr Proxy](wpViewport).marshal_flags(WpViewportRequest_destroy.ord, nil, cast[ptr Proxy](wpViewport).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc setSource*(wpViewport: ptr WpViewport; x: Fixed; y: Fixed; width: Fixed; height: Fixed) {.inline.} =
  ## set the source rectangle for cropping
  ## 
  ## Set the source rectangle of the associated wl_surface. See
  ## 	wp_viewport for the description, and relation to the wl_buffer
  ## 	size.
  ## 
  ## 	If all of x, y, width and height are -1.0, the source rectangle is
  ## 	unset instead. Any other set of values where width or height are zero
  ## 	or negative, or x or y are negative, raise the bad_value protocol
  ## 	error.
  ## 
  ## 	The crop and scale state is double-buffered, see wl_surface.commit.
  ## 
  cast[ptr Proxy](wpViewport).marshal_flags(WpViewportRequest_set_source.ord, nil, cast[ptr Proxy](wpViewport).get_version(), 0, x, y, width, height)
proc setDestination*(wpViewport: ptr WpViewport; width: int32; height: int32) {.inline.} =
  ## set the surface size for scaling
  ## 
  ## Set the destination size of the associated wl_surface. See
  ## 	wp_viewport for the description, and relation to the wl_buffer
  ## 	size.
  ## 
  ## 	If width is -1 and height is -1, the destination size is unset
  ## 	instead. Any other pair of values for width and height that
  ## 	contains zero or negative values raises the bad_value protocol
  ## 	error.
  ## 
  ## 	The crop and scale state is double-buffered, see wl_surface.commit.
  ## 
  cast[ptr Proxy](wpViewport).marshal_flags(WpViewportRequest_set_destination.ord, nil, cast[ptr Proxy](wpViewport).get_version(), 0, width, height)
