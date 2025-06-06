# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/client
import wayland/native/common
import code
export code

## The ext_idle_notify_v1 CLIENT protocol
## ######################################
## 
## Interfaces
## ==========
## 
## * ext_idle_notifier_v1
## * ext_idle_notification_v1
## 
## Copyright
## =========
## 
## Copyright © 2015 Martin Gräßlin
## Copyright © 2022 Simon Ser
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

proc setUserData*(extIdleNotifierV1: ptr ExtIdleNotifierV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](extIdleNotifierV1).set_user_data(user_data)
proc getUserData*(extIdleNotifierV1: ptr ExtIdleNotifierV1): pointer {.inline.} =
  cast[ptr Proxy](extIdleNotifierV1).get_user_data()
proc getVersion*(extIdleNotifierV1: ptr ExtIdleNotifierV1): uint32 {.inline.} =
  cast[ptr Proxy](extIdleNotifierV1).get_version()
proc destroy*(extIdleNotifierV1: ptr ExtIdleNotifierV1) {.inline.} =
  ## destroy the manager
  ## 
  ## Destroy the manager object. All objects created via this interface
  ## remain valid.
  ## 
  cast[ptr Proxy](extIdleNotifierV1).marshal_flags(ExtIdleNotifierV1Request_destroy.ord, nil, cast[ptr Proxy](extIdleNotifierV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc getIdleNotification*(extIdleNotifierV1: ptr ExtIdleNotifierV1; timeout: uint32; seat: ptr Seat): ptr ExtIdleNotificationV1 {.inline.} =
  ## create a notification object
  ## 
  ## Create a new idle notification object.
  ## 
  ## The notification object has a minimum timeout duration and is tied to a
  ## seat. The client will be notified if the seat is inactive for at least
  ## the provided timeout. See ext_idle_notification_v1 for more details.
  ## 
  ## A zero timeout is valid and means the client wants to be notified as
  ## soon as possible when the seat is inactive.
  ## 
  cast[ptr ExtIdleNotificationV1](cast[ptr Proxy](extIdleNotifierV1).marshal_flags(ExtIdleNotifierV1Request_get_idle_notification.ord, addr ext_idle_notification_v1_interface, cast[ptr Proxy](extIdleNotifierV1).get_version(), 0, nil, timeout, seat))
proc getInputIdleNotification*(extIdleNotifierV1: ptr ExtIdleNotifierV1; timeout: uint32; seat: ptr Seat): ptr ExtIdleNotificationV1 {.inline.} =
  ## create a notification object
  ## 
  ## Create a new idle notification object to track input from the
  ## user, such as keyboard and mouse movement. Because this object is
  ## meant to track user input alone, it ignores idle inhibitors.
  ## 
  ## The notification object has a minimum timeout duration and is tied to a
  ## seat. The client will be notified if the seat is inactive for at least
  ## the provided timeout. See ext_idle_notification_v1 for more details.
  ## 
  ## A zero timeout is valid and means the client wants to be notified as
  ## soon as possible when the seat is inactive.
  ## 
  cast[ptr ExtIdleNotificationV1](cast[ptr Proxy](extIdleNotifierV1).marshal_flags(ExtIdleNotifierV1Request_get_input_idle_notification.ord, addr ext_idle_notification_v1_interface, cast[ptr Proxy](extIdleNotifierV1).get_version(), 0, nil, timeout, seat))
type ExtIdleNotificationV1Listener* = object
  idled*: proc(
    data: pointer;
    extIdleNotificationV1: ptr ExtIdleNotificationV1;
  ) {.nimcall.}
  resumed*: proc(
    data: pointer;
    extIdleNotificationV1: ptr ExtIdleNotificationV1;
  ) {.nimcall.}
proc addListener*(extIdleNotificationV1: ptr ExtIdleNotificationV1; listener: ptr ExtIdleNotificationV1Listener; data: pointer): int {.inline.} =
  cast[ptr Proxy](extIdleNotificationV1).add_listener(listener, data)

proc setUserData*(extIdleNotificationV1: ptr ExtIdleNotificationV1; userData: pointer) {.inline.} =
  cast[ptr Proxy](extIdleNotificationV1).set_user_data(user_data)
proc getUserData*(extIdleNotificationV1: ptr ExtIdleNotificationV1): pointer {.inline.} =
  cast[ptr Proxy](extIdleNotificationV1).get_user_data()
proc getVersion*(extIdleNotificationV1: ptr ExtIdleNotificationV1): uint32 {.inline.} =
  cast[ptr Proxy](extIdleNotificationV1).get_version()
proc destroy*(extIdleNotificationV1: ptr ExtIdleNotificationV1) {.inline.} =
  ## destroy the notification object
  ## 
  ## Destroy the notification object.
  ## 
  cast[ptr Proxy](extIdleNotificationV1).marshal_flags(ExtIdleNotificationV1Request_destroy.ord, nil, cast[ptr Proxy](extIdleNotificationV1).get_version(), WL_MARSHAL_FLAG_DESTROY)
