# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/client
import wayland/native/common
import code
export code

## The input_timestamps_unstable_v1 CLIENT protocol
## ################################################
## 
## Interfaces
## ==========
## 
## * zwp_input_timestamps_manager_v1
## * zwp_input_timestamps_v1
## 
## Copyright
## =========
## 
## Copyright © 2017 Collabora, Ltd.
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

proc setUserData*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsManagerV1).set_user_data(user_data)
proc getUserData*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1): pointer {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsManagerV1).get_user_data()
proc getVersion*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1): uint32 {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsManagerV1).get_version()
proc destroy*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1) {.inline.} =
  ## destroy the input timestamps manager object
  ## 
  ## Informs the server that the client will no longer be using this
  ## protocol object. Existing objects created by this object are not
  ## affected.
  ## 
  cast[ptr Proxy](zwpInputTimestampsManagerV1).marshal_flags(ZwpInputTimestampsManagerV1Request_destroy.ord, nil, cast[ptr Proxy](zwpInputTimestampsManagerV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc getKeyboardTimestamps*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1; keyboard: ptr Keyboard): ptr ZwpInputTimestampsV1 {.inline.} =
  ## subscribe to high-resolution keyboard timestamp events
  ## 
  ## Creates a new input timestamps object that represents a subscription
  ## to high-resolution timestamp events for all wl_keyboard events that
  ## carry a timestamp.
  ## 
  ## If the associated wl_keyboard object is invalidated, either through
  ## client action (e.g. release) or server-side changes, the input
  ## timestamps object becomes inert and the client should destroy it
  ## by calling zwp_input_timestamps_v1.destroy.
  ## 
  cast[ptr ZwpInputTimestampsV1](cast[ptr Proxy](zwpInputTimestampsManagerV1).marshal_flags(ZwpInputTimestampsManagerV1Request_get_keyboard_timestamps.ord, addr zwp_input_timestamps_v1_interface, cast[ptr Proxy](zwpInputTimestampsManagerV1).get_version(), 0, nil, keyboard))
proc getPointerTimestamps*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1; pointer: ptr Pointer): ptr ZwpInputTimestampsV1 {.inline.} =
  ## subscribe to high-resolution pointer timestamp events
  ## 
  ## Creates a new input timestamps object that represents a subscription
  ## to high-resolution timestamp events for all wl_pointer events that
  ## carry a timestamp.
  ## 
  ## If the associated wl_pointer object is invalidated, either through
  ## client action (e.g. release) or server-side changes, the input
  ## timestamps object becomes inert and the client should destroy it
  ## by calling zwp_input_timestamps_v1.destroy.
  ## 
  cast[ptr ZwpInputTimestampsV1](cast[ptr Proxy](zwpInputTimestampsManagerV1).marshal_flags(ZwpInputTimestampsManagerV1Request_get_pointer_timestamps.ord, addr zwp_input_timestamps_v1_interface, cast[ptr Proxy](zwpInputTimestampsManagerV1).get_version(), 0, nil, pointer))
proc getTouchTimestamps*(zwpInputTimestampsManagerV1: ptr ZwpInputTimestampsManagerV1; touch: ptr Touch): ptr ZwpInputTimestampsV1 {.inline.} =
  ## subscribe to high-resolution touch timestamp events
  ## 
  ## Creates a new input timestamps object that represents a subscription
  ## to high-resolution timestamp events for all wl_touch events that
  ## carry a timestamp.
  ## 
  ## If the associated wl_touch object becomes invalid, either through
  ## client action (e.g. release) or server-side changes, the input
  ## timestamps object becomes inert and the client should destroy it
  ## by calling zwp_input_timestamps_v1.destroy.
  ## 
  cast[ptr ZwpInputTimestampsV1](cast[ptr Proxy](zwpInputTimestampsManagerV1).marshal_flags(ZwpInputTimestampsManagerV1Request_get_touch_timestamps.ord, addr zwp_input_timestamps_v1_interface, cast[ptr Proxy](zwpInputTimestampsManagerV1).get_version(), 0, nil, touch))
type ZwpInputTimestampsV1Listener* = object
  timestamp*: proc(
    data: pointer;
    zwpInputTimestampsV1: ptr ZwpInputTimestampsV1;
    tvSecHi: uint32;
    tvSecLo: uint32;
    tvNsec: uint32;
  ) {.nimcall.}
proc addListener*(zwpInputTimestampsV1: ptr ZwpInputTimestampsV1; listener: ptr ZwpInputTimestampsV1Listener; data: pointer): int {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsV1).add_listener(listener, data)

proc setUserData*(zwpInputTimestampsV1: ptr ZwpInputTimestampsV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsV1).set_user_data(user_data)
proc getUserData*(zwpInputTimestampsV1: ptr ZwpInputTimestampsV1): pointer {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsV1).get_user_data()
proc getVersion*(zwpInputTimestampsV1: ptr ZwpInputTimestampsV1): uint32 {.inline.} =
  cast[ptr Proxy](zwpInputTimestampsV1).get_version()
proc destroy*(zwpInputTimestampsV1: ptr ZwpInputTimestampsV1) {.inline.} =
  ## destroy the input timestamps object
  ## 
  ## Informs the server that the client will no longer be using this
  ## protocol object. After the server processes the request, no more
  ## timestamp events will be emitted.
  ## 
  cast[ptr Proxy](zwpInputTimestampsV1).marshal_flags(ZwpInputTimestampsV1Request_destroy.ord, nil, cast[ptr Proxy](zwpInputTimestampsV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
