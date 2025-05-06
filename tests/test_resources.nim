import std/[unittest, posix]
import wayland/native/[server]

proc res_destroy_func*(res: ptr wl_resource) =
  assert res != nil
  let destr = cast[ptr bool](wl_resource_get_user_data res)
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
  assert wl_resource_get_user_data(resource) == nil
  return WL_ITERATOR_CONTINUE

proc resource_destroy_notify*(l: ptr wl_listener; data: pointer) =
  let resource = cast[ptr wl_resource](data)
  let client: ptr wl_client = resource.client
  wl_client_for_each_resource(client, client_resource_check, nil)
  ##  Set user data to flag the resource has been deleted. The resource should
  ##  not be accessible from this point forward.
  wl_resource_set_user_data(resource, client)

suite "resources":
  test "create_resource":
    var s: array[2, cint]
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = wl_display_create()
    check display != nil
    let client = wl_client_create(display, s[0])
    check client != nil
    let res = wl_resource_create(client, addr wl_seat_interface, 4, 0)
    check res != nil
    ##  setters/getters
    check wl_resource_get_version(res) == 4
    check client == wl_resource_get_client(res)
    let id = wl_resource_get_id(res)
    check wl_client_get_object(client, id) == res
    let link = wl_resource_get_link(res)
    check link != nil
    check wl_resource_from_link(link) == res
    wl_resource_set_user_data(res, cast[pointer](0xbee))
    check wl_resource_get_user_data(res) == cast[pointer](0xbee)
    wl_resource_destroy(res)
    wl_client_destroy(client)
    wl_display_destroy(display)
    discard close s[1]

  test "destroy_resource":
    var s: array[2, cint]
    var destroyed: bool
    let destroy_listener = wl_listener(notify: destroy_notify)
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = wl_display_create()
    check display != nil
    let client = wl_client_create(display, s[0])
    check client != nil
    var res = wl_resource_create(client, addr wl_seat_interface, 4, 0)
    check res != nil
    wl_resource_set_implementation(res, nil, addr destroyed, res_destroy_func)
    wl_resource_add_destroy_listener(res, addr destroy_listener)
    let id = wl_resource_get_id(res)
    let link = wl_resource_get_link(res)
    check link != nil
    wl_resource_destroy(res)
    check destroyed
    check notify_called
    ##  check if signal was emitted
    check wl_client_get_object(client, id) == nil
    check destroy_listener.link.prev == nil
    check destroy_listener.link.next == nil
    res = wl_resource_create(client, addr wl_seat_interface, 2, 0)
    check res != nil
    destroyed = false
    notify_called = false
    wl_resource_set_destructor(res, res_destroy_func)
    wl_resource_set_user_data(res, addr destroyed)
    wl_resource_add_destroy_listener(res, addr destroy_listener)
    ##  client should destroy the resource upon its destruction
    wl_client_destroy(client)
    check destroyed
    check notify_called
    check destroy_listener.link.prev == nil
    check destroy_listener.link.next == nil
    wl_display_destroy(display)
    discard close s[1]

  test "create_resource_with_same_id":
    var s: array[2, cint]
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = wl_display_create()
    check display != nil
    let client = wl_client_create(display, s[0])
    check client != nil
    let res = wl_resource_create(client, addr wl_seat_interface, 2, 0)
    check res != nil
    let id = wl_resource_get_id(res)
    check wl_client_get_object(client, id) == res
    ##  this one should replace the old one
    let res2 = wl_resource_create(client, addr wl_seat_interface, 1, id)
    check res2 != nil
    check wl_client_get_object(client, id) == res2
    wl_resource_destroy(res2)
    wl_resource_destroy(res)
    wl_client_destroy(client)
    wl_display_destroy(display)
    discard close s[1]

  test "free_without_remove":
    let a = wl_listener(notify: display_destroy_notify)
    let b = wl_listener(notify: display_destroy_notify)
    let display = wl_display_create()
    wl_display_add_destroy_listener(display, addr a)
    wl_display_add_destroy_listener(display, addr b)
    wl_display_destroy(display)
    check a.link.next == a.link.prev and a.link.next == nil
    check b.link.next == b.link.prev and b.link.next == nil

  test "resource_destroy_iteration":
    var s: array[2, cint]
    let destroy_listener1 = wl_listener(notify: resource_destroy_notify)
    let destroy_listener2 = wl_listener(notify: resource_destroy_notify)
    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    let display = wl_display_create()
    check display != nil
    let client = wl_client_create(display, s[0])
    check client != nil
    let resource1 = wl_resource_create(client, addr wl_callback_interface, 1, 0)
    let resource2 = wl_resource_create(client, addr wl_callback_interface, 1, 0)
    check resource1 != nil
    check resource2 != nil
    wl_resource_add_destroy_listener(resource1, addr destroy_listener1)
    wl_resource_add_destroy_listener(resource2, addr destroy_listener2)
    wl_client_destroy(client)
    discard close s[0]
    discard close s[1]
    wl_display_destroy(display)
