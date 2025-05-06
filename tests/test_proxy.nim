import std/[unittest]
import wayland/native/[server as wl_server, client as wl_client]

type
  Server = object
    display: ptr wl_display
    loop: ptr wl_event_loop
    sync_count: int

  Client = object
    display: ptr wl_display
    callback_a: ptr wl_callback
    callback_b: ptr wl_callback
    callback_count: int

var server: Server
var client: Client

let tag_a* = allocCStringArray ["tag", "TAG"]

let tag_b* = allocCStringArray ["tag", "TAG"]

proc callback_done*(data: pointer; cb: ptr wl_callback; time: uint32) =
  var expected_tag: cstringArray
  var tag: cstringArray
  if cb == client.callback_a:
    expected_tag = tag_a
  elif cb == client.callback_b:
    expected_tag = tag_b
  else:
    assert false # unexpected callback
  tag = wl_proxy_get_tag(cast[ptr wl_proxy](cb))
  assert tag == expected_tag
  assert tag[0] == "tag"
  destroy cb
  inc client.callback_count

let callback_listener* = WlCallbackListener(done: callback_done)

proc logger_func*(user_data: pointer; `type`: wl_protocol_logger_type;
                 message: ptr wl_protocol_logger_message) =
  if `type` != WL_PROTOCOL_LOGGER_REQUEST:
    return
  assert wl_resource_get_class(message.resource) == "wl_display"
  assert message.message.name == "sync"
  inc server.sync_count

suite "proxy":
  test "proxy_tag":
    check addr(tag_a) != addr(tag_b)
    server.display = wl_display_create()
    check server.display != nil
    server.loop = wl_display_get_event_loop(server.display)
    check server.loop != nil
    let socket = wl_display_add_socket_auto(server.display)
    check socket != nil
    let logger = wl_display_add_protocol_logger(server.display, logger_func, nil)
    check logger != nil
    client.display = wl_display_connect(socket)
    check client.display != nil
    client.callback_a = client.display.sync
    discard client.callback_a.add_listener(addr callback_listener, nil)
    wl_proxy_set_tag(cast[ptr wl_proxy](client.callback_a), tag_a)
    client.callback_b = client.display.sync
    discard client.callback_b.add_listener(addr callback_listener, nil)
    wl_proxy_set_tag(cast[ptr wl_proxy](client.callback_b), tag_b)
    check wl_proxy_get_display(cast[ptr wl_proxy](client.callback_b)) ==
        client.display
    discard wl_display_flush(client.display)
    while server.sync_count < 2:
      discard wl_event_loop_dispatch(server.loop, -1)
      wl_display_flush_clients(server.display)
    discard wl_display_dispatch(client.display)
    check client.callback_count == 2
    wl_protocol_logger_destroy(logger)
    wl_display_disconnect(client.display)
    discard wl_event_loop_dispatch(server.loop, 100)
    wl_display_destroy(server.display)
