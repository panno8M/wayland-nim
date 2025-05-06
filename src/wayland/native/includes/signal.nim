proc wl_signal_init*(signal: ptr wl_signal) {.inline, nimcall.} =
  wl_list_init(addr(signal.listener_list))

proc wl_signal_add*(signal: ptr wl_signal; listener: ptr wl_listener) {.inline, nimcall.} =
  wl_list_insert(signal.listener_list.prev, addr(listener.link))

proc wl_signal_get*(signal: ptr wl_signal; notify: wl_notify_func_t): ptr wl_listener {.inline, nimcall.} =
  var l: ptr wl_listener
  wl_list_for_each(l, addr signal.listener_list, link):
    if l.notify == notify:
      return l
  return nil

proc wl_signal_emit*(signal: ptr wl_signal; data: pointer) {.inline, nimcall.} =
  var
    l: ptr wl_listener
    next: ptr wl_listener
  wl_list_for_each_safe(l, next, addr signal.listener_list, link):
    l.notify(l, data)