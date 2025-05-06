import std/unittest
import std/posix

import
  wayland/native/server

type
  client_destroy_listener* {.bycopy.} = object
    listener*: wl_listener
    done*: bool
    late_listener*: wl_listener
    late_done*: bool
    resource_listener*: wl_listener
    resource_done*: bool


proc client_destroy_notify*(l: ptr wl_listener; data: pointer) =
  var listener: ptr client_destroy_listener
  listener = wl_container_of(l, listener, listener)
  listener.done = true
  assert(not listener.resource_done)
  assert(not listener.late_done)

proc client_resource_destroy_notify*(l: ptr wl_listener; data: pointer) =
  var listener: ptr client_destroy_listener
  listener = wl_container_of(l, listener, resource_listener)
  assert(listener.done)
  listener.resource_done = true
  assert(not listener.late_done)

proc client_late_destroy_notify*(l: ptr wl_listener; data: pointer) =
  var listener: ptr client_destroy_listener
  listener = wl_container_of(l, listener, late_listener)
  assert(listener.done)
  assert(listener.resource_done)
  listener.late_done = true

proc client_user_data_destroy*(data: pointer) =
  var user_data_destroyed = cast[ptr bool](data)
  user_data_destroyed[] = true

proc client_destroy_remove_link_notify(l: ptr wl_listener; data: pointer) =
  let client = cast[ptr wl_client](data)
  var listener: ptr client_destroy_listener
  listener = wl_container_of(l, listener, listener)

  # The client destruction signal should not be emitted more than once.
  check not listener.done
  listener.done = true

  # The client should have been removed from the display's list.
  check wl_list_empty(wl_client_get_link(client))

suite "client":
  test "client_destroy_listener":
    var
      display: ptr wl_display
      client: ptr wl_client
      resource: ptr wl_resource
      a, b: client_destroy_listener
      user_data_destroyed: bool
      s: array[2, cint]

    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    display = wl_display_create()
    check display != nil
    client = wl_client_create(display, s[0])
    check client != nil

    wl_client_set_user_data(client, addr user_data_destroyed, client_user_data_destroy)
    check wl_client_get_user_data(client) == addr user_data_destroyed

    resource = wl_resource_create(client, addr wl_callback_interface, 1, 0)
    check resource != nil

    a.listener.notify = client_destroy_notify
    a.done = false
    a.resource_listener.notify = client_resource_destroy_notify
    a.resource_done = false
    a.late_listener.notify = client_late_destroy_notify
    a.late_done = false
    wl_client_add_destroy_listener(client, addr a.listener)
    wl_resource_add_destroy_listener(resource, addr a.resource_listener)
    wl_client_add_destroy_late_listener(client, addr a.late_listener)

    check wl_client_get_destroy_listener(client, client_destroy_notify) == addr a.listener
    check wl_resource_get_destroy_listener(resource, client_resource_destroy_notify) == addr a.resource_listener
    check wl_client_get_destroy_late_listener(client, client_late_destroy_notify) == addr a.late_listener

    b.listener.notify = client_destroy_notify
    b.done = false
    b.resource_listener.notify = client_resource_destroy_notify
    b.resource_done = false
    b.late_listener.notify = client_late_destroy_notify
    b.late_done = false
    wl_client_add_destroy_listener(client, addr b.listener)
    wl_resource_add_destroy_listener(resource, addr b.resource_listener)
    wl_client_add_destroy_late_listener(client, addr b.late_listener)

    wl_list_remove(addr a.listener.link)
    wl_list_remove(addr a.resource_listener.link)
    wl_list_remove(addr a.late_listener.link)

    check not user_data_destroyed

    wl_client_destroy(client)

    check not a.done
    check not a.resource_done
    check not a.late_done
    check b.done
    check b.resource_done
    check b.late_done
    check user_data_destroyed

    discard close(s[0])
    discard close(s[1])

    wl_display_destroy(display)

  test "client_destroy_removes_link":
    var display: ptr wl_display
    var client: ptr wl_client
    var destroy_listener: client_destroy_listener
    var s: array[2, cint]

    check socketpair(AF_UNIX, SOCK_STREAM or SOCK_CLOEXEC, 0, s) == 0
    display = wl_display_create()
    check display != nil
    client = wl_client_create(display, s[0])
    check client != nil

    destroy_listener.listener.notify = client_destroy_remove_link_notify
    destroy_listener.done = false
    wl_client_add_destroy_listener(client, addr destroy_listener.listener)

    check wl_client_get_destroy_listener(client, client_destroy_remove_link_notify) == addr destroy_listener.listener

    wl_client_destroy(client)
    check destroy_listener.done

    discard close(s[0])
    discard close(s[1])

    wl_display_destroy(display)
