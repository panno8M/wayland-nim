import wayland/native/server as wl
import std/[unittest]

type
  signal_emit_mutable_data* {.bycopy.} = object
    count*: cint
    remove_listener*: ptr wl.Listener

proc signal_notify*(listener: ptr wl.Listener; data: pointer) =
  ##  only increase counter
  inc(((cast[ptr cint](data))[]))

proc signal_notify_mutable*(listener: ptr wl.Listener; data: pointer) =
  let test_data = cast[ptr signal_emit_mutable_data](data)
  inc test_data.count

proc signal_notify_and_remove_mutable*(listener: ptr wl.Listener; data: pointer) =
  let test_data = cast[ptr signal_emit_mutable_data](data)
  signal_notify_mutable(listener, test_data)
  remove test_data.remove_listener.link

suite "signal":
  test "signal_init":
    var signal: wl.Signal
    init signal
    ##  Test if listeners' list is initialized
    check addr(signal.listener_list) == signal.listener_list.next # Maybe wl_signal implementation changed?
    check signal.listener_list.next == signal.listener_list.prev # Maybe wl_signal implementation changed?

  test "signal_add_get":
    var signal: wl.Signal
    ##  we just need different values of notify
    var l1 = wl.Listener(notify: cast[wl_notify_func_t](0x1))
    var l2 = wl.Listener(notify: cast[wl_notify_func_t](0x2))
    var l3 = wl.Listener(notify: cast[wl_notify_func_t](0x3))
    ##  one real, why not
    var l4 = wl.Listener(notify: signal_notify)
    init signal
    signal.add l1
    signal.add l2
    signal.add l3
    signal.add l4
    check signal.get(signal_notify) == addr l4
    check signal.get(cast[wl_notify_func_t](0x3)) == addr l3
    check signal.get(cast[wl_notify_func_t](0x2)) == addr l2
    check signal.get(cast[wl_notify_func_t](0x1)) == addr l1
    ##  get should not be destructive
    check signal.get(signal_notify) == addr l4
    check signal.get(cast[wl_notify_func_t](0x3)) == addr l3
    check signal.get(cast[wl_notify_func_t](0x2)) == addr l2
    check signal.get(cast[wl_notify_func_t](0x1)) == addr l1

  test "signal_emit_to_one_listener":
    var count: cint = 0
    var counter: cint
    var signal: wl.Signal
    var l1 = wl.Listener(notify: signal_notify)
    init signal
    signal.add l1
    counter = 0
    while counter < 100:
      signal.emit count
      inc counter
    check counter == count

  test "signal_emit_to_more_listeners":
    var count: cint = 0
    var counter: cint
    var signal: wl.Signal
    var l1 = wl.Listener(notify: signal_notify)
    var l2 = wl.Listener(notify: signal_notify)
    var l3 = wl.Listener(notify: signal_notify)
    init signal
    signal.add l1
    signal.add l2
    signal.add l3
    counter = 0
    while counter < 100:
      signal.emit count
      inc counter
    check 3 * counter == count

  test "signal_emit_mutable":
    var data: signal_emit_mutable_data = signal_emit_mutable_data(count: 0)
    ##  l2 will remove l3 before l3 is notified
    var signal: wl.Signal
    var l1 = wl.Listener(notify: signal_notify_mutable)
    var l2 = wl.Listener(notify: signal_notify_and_remove_mutable)
    var l3 = wl.Listener(notify: signal_notify_mutable)
    init signal
    signal.add l1
    signal.add l2
    signal.add l3
    data.remove_listener = addr l3
    signal.emit_mutable data
    check data.count == 2
