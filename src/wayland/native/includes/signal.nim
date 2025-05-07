proc init*(signal: ptr wl_signal) {.inline.} =
  init signal.listener_list

proc init*(signal: var wl_signal) {.inline.} =
  init(addr(signal))

proc add*(signal: ptr wl_signal; listener: ptr wl_listener) {.inline.} =
  signal.listener_list.prev.insert(listener.link)
proc add*(signal: var wl_signal; listener: var wl_listener) {.inline.} =
  add(addr(signal), addr(listener))
proc add*(signal: ptr wl_signal; listener: var wl_listener) {.inline.} =
  add(signal, addr(listener))
proc add*(signal: var wl_signal; listener: ptr wl_listener) {.inline.} =
  add(addr(signal), listener)

proc get*(signal: ptr wl_signal; notify: wl_notify_func_t): ptr wl_listener {.inline.} =
  var l: ptr wl_listener
  wl_list_for_each(l, addr signal.listener_list, link):
    if l.notify == notify:
      return l
  return nil
proc get*(signal: var wl_signal; notify: wl_notify_func_t): ptr wl_listener {.inline.} =
  get(addr(signal), notify)

proc emit*(signal: ptr wl_signal; data: pointer) {.inline.} =
  var
    l: ptr wl_listener
    next: ptr wl_listener
  wl_list_for_each_safe(l, next, addr signal.listener_list, link):
    l.notify(l, data)
proc emit*(signal: var wl_signal; data: pointer) {.inline.} =
  emit(addr(signal), data)
proc emit*[T](signal: ptr wl_signal; data: var T) {.inline.} =
  emit(signal, addr data)
proc emit*[T](signal: var wl_signal; data: var T) {.inline.} =
  emit(signal, addr data)

proc emit_mutable*(signal: var wl_signal; data: pointer) {.inline.} =
  emit_mutable(addr(signal), data)
proc emit_mutable*[T](signal: ptr wl_signal; data: var T) {.inline.} =
  emit_mutable(signal, addr data)
proc emit_mutable*[T](signal: var wl_signal; data: var T) {.inline.} =
  emit_mutable(signal, addr data)