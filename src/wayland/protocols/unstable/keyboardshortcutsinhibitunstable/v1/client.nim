# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/client
import wayland/native/common
import code
export code

## The keyboard_shortcuts_inhibit_unstable_v1 CLIENT protocol
## ##########################################################
## 
## Interfaces
## ==========
## 
## * zwp_keyboard_shortcuts_inhibit_manager_v1
## * zwp_keyboard_shortcuts_inhibitor_v1
## 
## Copyright
## =========
## 
## Copyright © 2017 Red Hat Inc.
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

proc setUserData*(zwpKeyboardShortcutsInhibitManagerV1: ptr ZwpKeyboardShortcutsInhibitManagerV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).set_user_data(user_data)
proc getUserData*(zwpKeyboardShortcutsInhibitManagerV1: ptr ZwpKeyboardShortcutsInhibitManagerV1): pointer {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).get_user_data()
proc getVersion*(zwpKeyboardShortcutsInhibitManagerV1: ptr ZwpKeyboardShortcutsInhibitManagerV1): uint32 {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).get_version()
proc destroy*(zwpKeyboardShortcutsInhibitManagerV1: ptr ZwpKeyboardShortcutsInhibitManagerV1) {.inline.} =
  ## destroy the keyboard shortcuts inhibitor object
  ## 
  ## Destroy the keyboard shortcuts inhibitor manager.
  ## 
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).marshal_flags(ZwpKeyboardShortcutsInhibitManagerV1Request_destroy.ord, nil, cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc inhibitShortcuts*(zwpKeyboardShortcutsInhibitManagerV1: ptr ZwpKeyboardShortcutsInhibitManagerV1; surface: ptr Surface; seat: ptr Seat): ptr ZwpKeyboardShortcutsInhibitorV1 {.inline.} =
  ## create a new keyboard shortcuts inhibitor object
  ## 
  ## Create a new keyboard shortcuts inhibitor object associated with
  ## 	the given surface for the given seat.
  ## 
  ## 	If shortcuts are already inhibited for the specified seat and surface,
  ## 	a protocol error "already_inhibited" is raised by the compositor.
  ## 
  cast[ptr ZwpKeyboardShortcutsInhibitorV1](cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).marshal_flags(ZwpKeyboardShortcutsInhibitManagerV1Request_inhibit_shortcuts.ord, addr zwp_keyboard_shortcuts_inhibitor_v1_interface, cast[ptr Proxy](zwpKeyboardShortcutsInhibitManagerV1).get_version(), 0, nil, surface, seat))
type ZwpKeyboardShortcutsInhibitorV1Listener* = object
  active*: proc(
    data: pointer;
    zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1;
  ) {.nimcall.}
  inactive*: proc(
    data: pointer;
    zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1;
  ) {.nimcall.}
proc addListener*(zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1; listener: ptr ZwpKeyboardShortcutsInhibitorV1Listener; data: pointer): int {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).add_listener(listener, data)

proc setUserData*(zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).set_user_data(user_data)
proc getUserData*(zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1): pointer {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).get_user_data()
proc getVersion*(zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1): uint32 {.inline.} =
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).get_version()
proc destroy*(zwpKeyboardShortcutsInhibitorV1: ptr ZwpKeyboardShortcutsInhibitorV1) {.inline.} =
  ## destroy the keyboard shortcuts inhibitor object
  ## 
  ## Remove the keyboard shortcuts inhibitor from the associated wl_surface.
  ## 
  cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).marshal_flags(ZwpKeyboardShortcutsInhibitorV1Request_destroy.ord, nil, cast[ptr Proxy](zwpKeyboardShortcutsInhibitorV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
