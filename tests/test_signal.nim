import wayland/native/[server]
import std/[unittest]

type
  signal_emit_mutable_data* {.bycopy.} = object
    count*: cint
    remove_listener*: ptr wl_listener

proc signal_notify*(listener: ptr wl_listener; data: pointer) =
  ##  only increase counter
  inc(((cast[ptr cint](data))[]))

proc signal_notify_mutable*(listener: ptr wl_listener; data: pointer) =
  let test_data = cast[ptr signal_emit_mutable_data](data)
  inc test_data.count

proc signal_notify_and_remove_mutable*(listener: ptr wl_listener; data: pointer) =
  let test_data = cast[ptr signal_emit_mutable_data](data)
  signal_notify_mutable(listener, test_data)
  wl_list_remove(addr test_data.remove_listener.link)

suite "signal":
  test "signal_init":
    var signal: wl_signal
    wl_signal_init(addr signal)
    ##  Test if listeners' list is initialized
    check addr(signal.listener_list) == signal.listener_list.next # Maybe wl_signal implementation changed?
    check signal.listener_list.next == signal.listener_list.prev # Maybe wl_signal implementation changed?

  test "signal_add_get":
    var signal: wl_signal
    ##  we just need different values of notify
    var l1 = wl_listener(notify: cast[wl_notify_func_t](0x1))
    var l2 = wl_listener(notify: cast[wl_notify_func_t](0x2))
    var l3 = wl_listener(notify: cast[wl_notify_func_t](0x3))
    ##  one real, why not
    var l4 = wl_listener(notify: signal_notify)
    wl_signal_init(addr signal)
    wl_signal_add(addr signal, addr l1)
    wl_signal_add(addr signal, addr l2)
    wl_signal_add(addr signal, addr l3)
    wl_signal_add(addr signal, addr l4)
    check wl_signal_get(addr signal, signal_notify) == addr l4
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x3)) == addr l3
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x2)) == addr l2
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x1)) == addr l1
    ##  get should not be destructive
    check wl_signal_get(addr signal, signal_notify) == addr l4
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x3)) == addr l3
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x2)) == addr l2
    check wl_signal_get(addr signal, cast[wl_notify_func_t](0x1)) == addr l1

  test "signal_emit_to_one_listener":
    var count: cint = 0
    var counter: cint
    var signal: wl_signal
    var l1 = wl_listener(notify: signal_notify)
    wl_signal_init(addr signal)
    wl_signal_add(addr signal, addr l1)
    counter = 0
    while counter < 100:
      wl_signal_emit(addr signal, addr count)
      inc counter
    check counter == count

  test "signal_emit_to_more_listeners":
    var count: cint = 0
    var counter: cint
    var signal: wl_signal
    var l1 = wl_listener(notify: signal_notify)
    var l2 = wl_listener(notify: signal_notify)
    var l3 = wl_listener(notify: signal_notify)
    wl_signal_init(addr signal)
    wl_signal_add(addr signal, addr l1)
    wl_signal_add(addr signal, addr l2)
    wl_signal_add(addr signal, addr l3)
    counter = 0
    while counter < 100:
      wl_signal_emit(addr signal, addr count)
      inc counter
    check 3 * counter == count

  test "signal_emit_mutable":
    var data: signal_emit_mutable_data = signal_emit_mutable_data(count: 0)
    ##  l2 will remove l3 before l3 is notified
    var signal: wl_signal
    var l1 = wl_listener(notify: signal_notify_mutable)
    var l2 = wl_listener(notify: signal_notify_and_remove_mutable)
    var l3 = wl_listener(notify: signal_notify_mutable)
    wl_signal_init(addr signal)
    wl_signal_add(addr signal, addr l1)
    wl_signal_add(addr signal, addr l2)
    wl_signal_add(addr signal, addr l3)
    data.remove_listener = addr l3
    wl_signal_emit_mutable(addr signal, addr data)
    check data.count == 2
