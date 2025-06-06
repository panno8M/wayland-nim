import std/[unittest]
import wayland/native as wl

type
  Server = object
    display: ptr wl.Display
    loop: ptr wl.EventLoop
    sync_count: int

  Client = object
    display: ptr wl.Display
    callback_a: ptr wl.Callback
    callback_b: ptr wl.Callback
    callback_count: int

var server: Server
var client: Client

let tag_a* = allocCStringArray ["tag", "TAG"]

let tag_b* = allocCStringArray ["tag", "TAG"]

proc callback_done*(data: pointer; cb: ptr wl.Callback; time: uint32) =
  var expected_tag: cstringArray
  var tag: cstringArray
  if cb == client.callback_a:
    expected_tag = tag_a
  elif cb == client.callback_b:
    expected_tag = tag_b
  else:
    assert false # unexpected callback
  tag = cast[ptr wl.Proxy](cb).get_tag
  assert tag == expected_tag
  assert tag[0] == "tag"
  destroy cb
  inc client.callback_count

let callback_listener* = wl.CallbackListener(done: callback_done)

proc logger_func*(user_data: pointer; `type`: wl.ProtocolLoggerType;
                 message: ptr wl.ProtocolLoggerMessage) =
  if `type` != WL_PROTOCOL_LOGGER_REQUEST:
    return
  assert message.resource.get_class == "wl_display"
  assert message.message.name == "sync"
  inc server.sync_count

suite "proxy":
  test "proxy_tag":
    check addr(tag_a) != addr(tag_b)
    server.display = create_display()
    check server.display != nil
    server.loop = server.display.get_event_loop
    check server.loop != nil
    let socket = server.display.add_socket_auto
    check socket != nil
    let logger = server.display.add_protocol_logger(logger_func, nil)
    check logger != nil
    client.display = socket.connect_display
    check client.display != nil
    client.callback_a = client.display.sync
    discard client.callback_a.add_listener(addr callback_listener, nil)
    cast[ptr wl.Proxy](client.callback_a).set_tag tag_a
    client.callback_b = client.display.sync
    discard client.callback_b.add_listener(addr callback_listener, nil)
    cast[ptr wl.Proxy](client.callback_b).set_tag tag_b
    check cast[ptr wl.Proxy](client.callback_b).get_display == client.display
    discard flush client.display
    while server.sync_count < 2:
      discard server.loop.dispatch(-1)
      flush_clients server.display
    discard dispatch client.display
    check client.callback_count == 2
    destroy logger
    disconnect client.display
    discard server.loop.dispatch(100)
    destroy server.display
