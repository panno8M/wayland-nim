import common

include gen/includes/server_core

# Signal

proc init*(signal: ptr Signal) {.inline.} =
  init signal.listener_list

proc init*(signal: var Signal) {.inline.} =
  init(addr(signal))

proc add*(signal: ptr Signal; listener: ptr Listener) {.inline.} =
  signal.listener_list.prev.insert(listener.link)
proc add*(signal: var Signal; listener: var Listener) {.inline.} =
  add(addr(signal), addr(listener))
proc add*(signal: ptr Signal; listener: var Listener) {.inline.} =
  add(signal, addr(listener))
proc add*(signal: var Signal; listener: ptr Listener) {.inline.} =
  add(addr(signal), listener)

proc get*(signal: ptr Signal; notify: wl_notify_func_t): ptr Listener {.inline.} =
  var l: ptr Listener
  wl_list_for_each(l, addr signal.listener_list, link):
    if l.notify == notify:
      return l
  return nil
proc get*(signal: var Signal; notify: wl_notify_func_t): ptr Listener {.inline.} =
  get(addr(signal), notify)

proc emit*(signal: ptr Signal; data: pointer) {.inline.} =
  var
    l: ptr Listener
    next: ptr Listener
  wl_list_for_each_safe(l, next, addr signal.listener_list, link):
    l.notify(l, data)
proc emit*(signal: var Signal; data: pointer) {.inline.} =
  emit(addr(signal), data)
proc emit*[T](signal: ptr Signal; data: var T) {.inline.} =
  emit(signal, addr data)
proc emit*[T](signal: var Signal; data: var T) {.inline.} =
  emit(signal, addr data)

proc emit_mutable*(signal: var Signal; data: pointer) {.inline.} =
  emit_mutable(addr(signal), data)
proc emit_mutable*[T](signal: ptr Signal; data: var T) {.inline.} =
  emit_mutable(signal, addr data)
proc emit_mutable*[T](signal: var Signal; data: var T) {.inline.} =
  emit_mutable(signal, addr data)