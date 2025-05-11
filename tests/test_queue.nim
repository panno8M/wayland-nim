##
##  Copyright © 2012 Jonas Ådahl
##
##  Permission is hereby granted, free of charge, to any person obtaining
##  a copy of this software and associated documentation files (the
##  "Software"), to deal in the Software without restriction, including
##  without limitation the rights to use, copy, modify, merge, publish,
##  distribute, sublicense, and/or sell copies of the Software, and to
##  permit persons to whom the Software is furnished to do so, subject to
##  the following conditions:
##
##  The above copyright notice and this permission notice (including the
##  next paragraph) shall be included in all copies or substantial
##  portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
##  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
##  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
##  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
##  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
##  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
##  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##  SOFTWARE.
##

import std/[unittest, posix, strutils, strformat]
import wayland/native as wl
import compositor

proc registry_handle_global*(data: pointer; registry: ptr wl.Registry; id: uint32;
                            `interface`: cstring; version: uint32) =
  let pcounter = cast[ptr cint](data)
  inc pcounter[]
  assert pcounter[] == 1
  destroy registry

let registry_listener* = wl.RegistryListener(global: registry_handle_global)

##  Test that destroying a proxy object doesn't result in any more
##  callback being invoked, even though were many queued.

proc client_test_proxy_destroy*() =
  var counter: cint = 0
  let display = nil.connect_display
  assert display != nil
  let registry = display.get_registry
  assert registry != nil
  discard registry.add_listener(addr registry_listener, addr counter)
  assert roundtrip(display) != -1
  assert counter == 1
  ##  don't destroy the registry, we have already destroyed them
  ##  in the global handler
  disconnect display

type
  multiple_queues_state* {.bycopy.} = object
    display*: ptr wl.Display
    callback2*: ptr wl.Callback
    done*: bool


proc sync_callback*(data: pointer; callback: ptr wl.Callback; serial: uint32) =
  var state = cast[ptr multiple_queues_state](data)
  state.done = true
  destroy callback
  discard dispatch_pending state.display
  destroy state.callback2

let sync_listener* = wl.CallbackListener(done: sync_callback)

##  Test that when receiving the first of two synchronization
##  callback events, destroying the second one doesn't cause any
##  errors even if the delete_id event is handled out of order.

proc client_test_multiple_queues*() =
  var state: multiple_queues_state
  var ret: cint = 0
  state.display = nil.connect_display
  assert state.display != nil
  let queue = state.display.create_queue
  assert queue != nil
  state.done = false
  let callback1 = state.display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr(sync_listener), addr(state))
  cast[ptr wl.Proxy](callback1).set_queue queue
  state.callback2 = state.display.sync
  assert state.callback2 != nil
  discard state.callback2.add_listener(addr(sync_listener), nil)
  cast[ptr wl.Proxy](state.callback2).set_queue queue
  discard flush state.display
  while not state.done and ret == 0:
    ret = state.display.dispatch_queue(queue)
  destroy queue
  disconnect state.display
  quit(if ret == -1: -1 else: 0)

proc sync_callback_roundtrip*(data: pointer; callback: ptr wl.Callback; serial: uint32) =
  let done = cast[ptr bool](data)
  done[] = true

let sync_listener_roundtrip* = wl.CallbackListener(done: sync_callback_roundtrip)

##  Test that doing a roundtrip on a queue only the events on that
##  queue get dispatched.

proc client_test_queue_roundtrip*() =
  var done1: bool = false
  var done2: bool = false
  let display = nil.connect_display
  assert display != nil
  let queue = display.create_queue
  assert queue != nil
  ##  arm a callback on the default queue
  var callback1 = display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr sync_listener_roundtrip, addr done1)
  ##  arm a callback on the other queue
  var callback2 = display.sync
  assert callback2 != nil
  discard callback2.add_listener(addr sync_listener_roundtrip, addr done2)
  cast[ptr wl.Proxy](callback2).set_queue queue
  ##  roundtrip on default queue must not dispatch the other queue.
  discard roundtrip display
  assert done1 == true
  assert done2 == false
  ##  re-arm the sync callback on the default queue, so we see that
  ##  wl_display_roundtrip_queue() does not dispatch the default queue.
  destroy callback1
  done1 = false
  callback1 = display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr sync_listener_roundtrip, addr done1)
  discard display.roundtrip_queue queue
  assert done1 == false
  assert done2 == true
  destroy callback1
  destroy callback2
  destroy queue
  disconnect display

proc client_test_queue_proxy_wrapper*() =
  var done: bool = false
  ##
  ##  For an illustration of what usage would normally fail without using
  ##  proxy wrappers, see the `client_test_queue_set_queue_race' test case.
  ##
  let display = nil.connect_display
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = display.create_queue
  assert queue != nil
  let display_wrapper = cast[ptr wl.Display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  cast[ptr wl.Proxy](display_wrapper).set_queue queue
  let callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  ##  Pretend we are now another thread and dispatch the dispatch the main
  ##  queue while also knowing our callback is read and queued.
  discard roundtrip display
  ##  Make sure that the pretend-to-be main thread didn't dispatch our
  ##  callback, behind our back.
  discard callback.add_listener(addr sync_listener_roundtrip, addr done)
  discard flush display
  assert not done
  ##  Make sure that we eventually end up dispatching our callback.
  while not done:
    assert display.dispatch_queue(queue) != -1
  destroy callback
  destroy queue
  disconnect display

proc client_test_queue_set_queue_race*() =
  var done: bool = false
  ##
  ##  This test illustrates the multi threading scenario which would fail
  ##  without doing what is done in the `client_test_queue_proxy_wrapper'
  ##  test.
  ##
  let display = nil.connect_display
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = display.create_queue
  assert queue != nil
  let callback = display.sync
  assert callback != nil
  ##  Pretend we are now another thread and dispatch the dispatch the main
  ##  queue while also knowing our callback is read, queued on the wrong
  ##  queue, and dispatched.
  discard roundtrip display
  ##  Pretend we are back in the separate thread, and continue with setting
  ##  up our callback.
  discard callback.add_listener(addr sync_listener_roundtrip, addr done)
  cast[ptr wl.Proxy](callback).set_queue queue
  ##  Roundtrip our separate thread queue to make sure any events are
  ##  dispatched.
  discard display.roundtrip_queue queue
  ##  Verify that the callback has indeed been dropped.
  assert not done
  destroy callback
  destroy queue
  disconnect display

proc client_test_queue_destroy_with_attached_proxies*() =
  let display = nil.connect_display
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = display.create_queue
  assert queue != nil
  ##  Create a sync dispatching events on the thread-local queue.
  let display_wrapper = cast[ptr wl.Display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  cast[ptr wl.Proxy](display_wrapper).set_queue queue
  let callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  ##  Destroy the queue before the attached object.
  destroy queue
  ##  Check that the log contains some information about the attached
  ##  wl_callback proxy.
  var last_line: string
  client_log.setFilePos(0)
  while not client_log.endOfFile:
    last_line = client_log.readLine
  let callback_name = &"wl_callback#{cast[ptr wl.Proxy](callback).get_id}"
  assert callback_name in last_line
  destroy callback
  disconnect display

proc client_test_queue_proxy_event_to_destroyed_queue*() =
  let display = nil.connect_display
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = display.create_queue
  assert queue != nil
  ##  Create a sync dispatching events on the thread-local queue.
  let display_wrapper = cast[ptr wl.Display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  cast[ptr wl.Proxy](display_wrapper).set_queue queue
  let callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  discard flush display
  ##  Destroy the queue before the attached object.
  destroy queue
  ##  During this roundtrip we should receive the done event on 'callback',
  ##  try to queue it to the destroyed queue, and abort.
  discard roundtrip display
  destroy callback
  disconnect display

proc client_test_queue_destroy_default_with_attached_proxies*() =
  let display = nil.connect_display
  assert display != nil
  ##  Create a sync dispatching events on the default queue.
  let callback = display.sync
  assert callback != nil
  ##  Destroy the default queue (by disconnecting) before the attached
  ##  object.
  disconnect display
  ##  Check that the log does not contain any warning about the attached
  ##  wl_callback proxy.
  client_log.setFilePos(0)
  let log = client_log.readAll
  let callback_name = &"wl_callback#{cast[ptr wl.Proxy](callback).get_id}"
  assert callback_name notin log
  # dealloc callback

proc check_queue_name*(proxy: ptr wl.Proxy; name: cstring) =
  let queue = proxy.get_queue
  let queue_name = queue.get_name
  assert queue_name == name

proc roundtrip_named_queue_nonblock*(display: ptr wl.Display;
                                    queue: ptr wl.EventQueue; name: cstring): ptr wl.Callback =
  var callback: ptr wl.Callback
  var wrapped_display: ptr wl.Display = nil
  if queue != nil:
    wrapped_display = cast[ptr wl.Display](wl_proxy_create_wrapper(display))
    assert wrapped_display != nil
    cast[ptr wl.Proxy](wrapped_display).set_queue queue
    check_queue_name(cast[ptr wl.Proxy](wrapped_display), name)
    callback = wrapped_display.sync
  else:
    callback = display.sync
  check_queue_name(cast[ptr wl.Proxy](callback), name)
  if wrapped_display != nil:
    wl_proxy_wrapper_destroy(wrapped_display)
  assert callback != nil
  return callback

proc client_test_queue_names*() =
  let display = nil.connect_display
  assert display != nil
  let default_queue = cast[ptr wl.Proxy](display).get_queue
  let default_queue_name = default_queue.get_name
  assert default_queue_name == "Default Queue"
  ##  Create some event queues both with and without names.
  let queue1 = display.create_queue_with_name("First")
  assert queue1 != nil
  let queue2 = display.create_queue_with_name("Second")
  assert queue2 != nil
  let queue3 = display.create_queue
  assert queue3 != nil
  ##  Create some requests and ensure their queues have the expected
  ##  names.
  ##
  let callback1 = display.roundtrip_named_queue_nonblock(queue1, "First")
  let callback2 = display.roundtrip_named_queue_nonblock(queue2, "Second")
  let callback3 = display.roundtrip_named_queue_nonblock(queue3, nil)
  let callback4 = display.roundtrip_named_queue_nonblock(nil, "Default Queue")
  ##  Destroy one queue with proxies still attached so we can verify
  ##  that the queue name is in the log message.
  destroy queue2
  client_log.setFilePos(0)
  let log = client_log.readAll
  assert "Second" in log
  ##  There's no reason for the First queue name to be present.
  assert "First" notin log
  destroy callback1
  destroy callback2
  destroy callback3
  destroy callback4
  destroy queue1
  destroy queue3
  disconnect display

proc dummy_bind*(client: ptr wl.Client; data: pointer; version: uint32; id: uint32) =
  discard

suite "queue":
  test "queue_proxy_destroy":
    let dummy_interfaces = [
      addr wl_seat_interface,
      addr wl_pointer_interface,
      addr wl_keyboard_interface,
      addr wl_surface_interface]
    let d = compositor.create_display()
    for i, ifce in dummy_interfaces:
      discard d.wl_display.create_global(ifce, ifce.version, nil, dummy_bind)
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_proxy_destroy)
    run d
    destroy d

  test "queue_multiple_queues":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_multiple_queues)
    run d
    destroy d

  test "queue_roundtrip":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_roundtrip)
    run d
    destroy d

  test "queue_set_queue_proxy_wrapper":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_proxy_wrapper)
    run d
    destroy d

  test "queue_set_queue_race":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_set_queue_race)
    run d
    destroy d

  test "queue_destroy_with_attached_proxies":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_destroy_with_attached_proxies)
    run d
    destroy d

  test "queue_proxy_event_to_destroyed_queue":
    let d = compositor.create_display()
    # test_set_timeout(2)
    let ci = create_client_noarg(d, client_test_queue_proxy_event_to_destroyed_queue)
    run d
    ##  Check that the final line in the log mentions the expected reason
    ##  for the abort.
    ci.log.setFilePos(0)
    var lastLine: string
    while not ci.log.endOfFile: lastLine = ci.log.readLine
    check lastLine == "Tried to add event to destroyed queue"
    ##  Check that the client aborted.
    destroy_expect_signal d, SIGABRT

  test "queue_destroy_default_with_attached_proxies":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_destroy_default_with_attached_proxies)
    run d
    destroy d

  test "queue_names":
    let d = compositor.create_display()
    # test_set_timeout(2)
    discard create_client_noarg(d, client_test_queue_names)
    run d
    destroy d
