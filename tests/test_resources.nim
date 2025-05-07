import std/[unittest, posix]
import wayland/native/[server]

proc res_destroy_func*(res: ptr wl_resource) =
  assert res != nil
  let destr = cast[ptr bool](res.get_user_data)
  destr[] = true

var notify_called*: bool

proc destroy_notify*(l: ptr wl_listener; data: pointer) =
  assert l != nil and data != nil
  notify_called = true
  ##  In real code it's common to free the structure holding the
  ##  listener at this point, but not to remove it from the list.
  ##
  ##  That's fine since this is a destruction notification and
  ##  it's the last time this signal can fire.  We set these
  ##  to NULL so we can check them later to ensure no write after
  ##  "free" occurred.
  ##
  l.link.prev = nil
  l.link.next = nil

proc display_destroy_notify*(l: ptr wl_listener; data: pointer) =
  l.link.prev = nil
  l.link.next = nil

proc client_resource_check*(resource: ptr wl_resource; data: pointer): wl_iterator_result =
  ##  Ensure there is no iteration over already freed resources.
  assert resource.get_user_data == nil
  return WL_ITERATOR_CONTINUE

proc resource_destroy_notify*(l: ptr wl_listener; data: pointer) =
  let resource = cast[ptr wl_resource](data)
  let client: ptr wl_client = resource.client
  client.for_each_resource(client_resource_check, nil)
  ##  Set user data to flag the resource has been deleted. The resource should
  ##  not be accessible from this point forward.
  resource.set_user_data client

suite "resources":
  test "create_resource":
    var s: array[2, cint]
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = create_display()
    check display != nil
    let client = display.create_client(s[0])
    check client != nil
    let res = client.create_resource(addr wl_seat_interface, 4, 0)
    check res != nil
    ##  setters/getters
    check res.get_version == 4
    check client == res.get_client
    let id = res.get_id
    check client.get_object(id) == res
    let link = res.get_link
    check link != nil
    check resource_from_link(link) == res
    res.set_user_data cast[pointer](0xbee)
    check res.get_user_data == cast[pointer](0xbee)
    destroy res
    destroy client
    destroy display
    discard close s[1]

  test "destroy_resource":
    var s: array[2, cint]
    var destroyed: bool
    let destroy_listener = wl_listener(notify: destroy_notify)
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = create_display()
    check display != nil
    let client = display.create_client(s[0])
    check client != nil
    var res = client.create_resource(addr wl_seat_interface, 4, 0)
    check res != nil
    res.set_implementation(nil, addr destroyed, res_destroy_func)
    res.add_destroy_listener(addr destroy_listener)
    let id = res.get_id
    let link = res.get_link
    check link != nil
    destroy res
    check destroyed
    check notify_called
    ##  check if signal was emitted
    check client.get_object(id) == nil
    check destroy_listener.link.prev == nil
    check destroy_listener.link.next == nil
    res = client.create_resource(addr wl_seat_interface, 2, 0)
    check res != nil
    destroyed = false
    notify_called = false
    res.set_destructor(res_destroy_func)
    res.set_user_data(addr destroyed)
    res.add_destroy_listener(addr destroy_listener)
    ##  client should destroy the resource upon its destruction
    destroy client
    check destroyed
    check notify_called
    check destroy_listener.link.prev == nil
    check destroy_listener.link.next == nil
    destroy display
    discard close s[1]

  test "create_resource_with_same_id":
    var s: array[2, cint]
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = create_display()
    check display != nil
    let client = display.create_client(s[0])
    check client != nil
    let res = client.create_resource(addr wl_seat_interface, 2, 0)
    check res != nil
    let id = res.get_id
    check client.get_object(id) == res
    ##  this one should replace the old one
    let res2 = client.create_resource(addr wl_seat_interface, 1, id)
    check res2 != nil
    check client.get_object(id) == res2
    destroy res2
    destroy res
    destroy client
    destroy display
    discard close s[1]

  test "free_without_remove":
    let a = wl_listener(notify: display_destroy_notify)
    let b = wl_listener(notify: display_destroy_notify)
    let display = create_display()
    display.add_destroy_listener addr a
    display.add_destroy_listener addr b
    destroy display
    check a.link.next == a.link.prev and a.link.next == nil
    check b.link.next == b.link.prev and b.link.next == nil

  test "resource_destroy_iteration":
    var s: array[2, cint]
    let destroy_listener1 = wl_listener(notify: resource_destroy_notify)
    let destroy_listener2 = wl_listener(notify: resource_destroy_notify)
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = create_display()
    check display != nil
    let client = display.create_client(s[0])
    check client != nil
    let resource1 = client.create_resource(addr wl_callback_interface, 1, 0)
    let resource2 = client.create_resource(addr wl_callback_interface, 1, 0)
    check resource1 != nil
    check resource2 != nil
    resource1.add_destroy_listener addr destroy_listener1
    resource2.add_destroy_listener addr destroy_listener2
    destroy client
    discard close s[0]
    discard close s[1]
    destroy display
