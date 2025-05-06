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
import wayland/native/[client, server]
import compositor

proc registry_handle_global*(data: pointer; registry: ptr wl_registry; id: uint32;
                            `interface`: cstring; version: uint32) =
  let pcounter = cast[ptr cint](data)
  inc pcounter[]
  assert pcounter[] == 1
  destroy registry

let registry_listener* = WlRegistryListener(global: registry_handle_global)

##  Test that destroying a proxy object doesn't result in any more
##  callback being invoked, even though were many queued.

proc client_test_proxy_destroy*() =
  var counter: cint = 0
  let display = wl_display_connect(nil)
  assert display != nil
  let registry = display.get_registry
  assert registry != nil
  discard registry.add_listener(addr registry_listener, addr counter)
  assert wl_display_roundtrip(display) != -1
  assert counter == 1
  ##  don't destroy the registry, we have already destroyed them
  ##  in the global handler
  wl_display_disconnect(display)

type
  multiple_queues_state* {.bycopy.} = object
    display*: ptr wl_display
    callback2*: ptr wl_callback
    done*: bool


proc sync_callback*(data: pointer; callback: ptr wl_callback; serial: uint32) =
  var state = cast[ptr multiple_queues_state](data)
  state.done = true
  destroy callback
  discard wl_display_dispatch_pending(state.display)
  destroy state.callback2

let sync_listener* = WlCallbackListener(done: sync_callback)

##  Test that when receiving the first of two synchronization
##  callback events, destroying the second one doesn't cause any
##  errors even if the delete_id event is handled out of order.

proc client_test_multiple_queues*() =
  var state: multiple_queues_state
  var ret: cint = 0
  state.display = wl_display_connect(nil)
  assert state.display != nil
  let queue = wl_display_create_queue(state.display)
  assert queue != nil
  state.done = false
  let callback1 = state.display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr(sync_listener), addr(state))
  wl_proxy_set_queue(cast[ptr wl_proxy](callback1), queue)
  state.callback2 = state.display.sync
  assert state.callback2 != nil
  discard state.callback2.add_listener(addr(sync_listener), nil)
  wl_proxy_set_queue(cast[ptr wl_proxy](state.callback2), queue)
  discard wl_display_flush(state.display)
  while not state.done and ret == 0:
    ret = wl_display_dispatch_queue(state.display, queue)
  wl_event_queue_destroy(queue)
  wl_display_disconnect(state.display)
  quit(if ret == -1: -1 else: 0)

proc sync_callback_roundtrip*(data: pointer; callback: ptr wl_callback; serial: uint32) =
  let done = cast[ptr bool](data)
  done[] = true

let sync_listener_roundtrip* = WlCallbackListener(done: sync_callback_roundtrip)

##  Test that doing a roundtrip on a queue only the events on that
##  queue get dispatched.

proc client_test_queue_roundtrip*() =
  var done1: bool = false
  var done2: bool = false
  let display = wl_display_connect(nil)
  assert display != nil
  let queue = wl_display_create_queue(display)
  assert queue != nil
  ##  arm a callback on the default queue
  var callback1 = display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr sync_listener_roundtrip, addr done1)
  ##  arm a callback on the other queue
  var callback2 = display.sync
  assert callback2 != nil
  discard callback2.add_listener(addr sync_listener_roundtrip, addr done2)
  wl_proxy_set_queue(cast[ptr wl_proxy](callback2), queue)
  ##  roundtrip on default queue must not dispatch the other queue.
  discard wl_display_roundtrip(display)
  assert done1 == true
  assert done2 == false
  ##  re-arm the sync callback on the default queue, so we see that
  ##  wl_display_roundtrip_queue() does not dispatch the default queue.
  destroy callback1
  done1 = false
  callback1 = display.sync
  assert callback1 != nil
  discard callback1.add_listener(addr sync_listener_roundtrip, addr done1)
  discard wl_display_roundtrip_queue(display, queue)
  assert done1 == false
  assert done2 == true
  destroy callback1
  destroy callback2
  wl_event_queue_destroy(queue)
  wl_display_disconnect(display)

proc client_test_queue_proxy_wrapper*() =
  var done: bool = false
  ##
  ##  For an illustration of what usage would normally fail without using
  ##  proxy wrappers, see the `client_test_queue_set_queue_race' test case.
  ##
  let display = wl_display_connect(nil)
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = wl_display_create_queue(display)
  assert queue != nil
  let display_wrapper = cast[ptr wl_display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  wl_proxy_set_queue(cast[ptr wl_proxy](display_wrapper), queue)
  let callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  ##  Pretend we are now another thread and dispatch the dispatch the main
  ##  queue while also knowing our callback is read and queued.
  discard wl_display_roundtrip(display)
  ##  Make sure that the pretend-to-be main thread didn't dispatch our
  ##  callback, behind our back.
  discard callback.add_listener(addr sync_listener_roundtrip, addr done)
  discard wl_display_flush(display)
  assert not done
  ##  Make sure that we eventually end up dispatching our callback.
  while not done:
    assert wl_display_dispatch_queue(display, queue) != -1
  destroy callback
  wl_event_queue_destroy(queue)
  wl_display_disconnect(display)

proc client_test_queue_set_queue_race*() =
  var done: bool = false
  ##
  ##  This test illustrates the multi threading scenario which would fail
  ##  without doing what is done in the `client_test_queue_proxy_wrapper'
  ##  test.
  ##
  let display = wl_display_connect(nil)
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = wl_display_create_queue(display)
  assert queue != nil
  let callback = display.sync
  assert callback != nil
  ##  Pretend we are now another thread and dispatch the dispatch the main
  ##  queue while also knowing our callback is read, queued on the wrong
  ##  queue, and dispatched.
  discard wl_display_roundtrip(display)
  ##  Pretend we are back in the separate thread, and continue with setting
  ##  up our callback.
  discard callback.add_listener(addr sync_listener_roundtrip, addr done)
  wl_proxy_set_queue(cast[ptr wl_proxy](callback), queue)
  ##  Roundtrip our separate thread queue to make sure any events are
  ##  dispatched.
  discard wl_display_roundtrip_queue(display, queue)
  ##  Verify that the callback has indeed been dropped.
  assert not done
  destroy callback
  wl_event_queue_destroy(queue)
  wl_display_disconnect(display)

proc client_test_queue_destroy_with_attached_proxies*() =
  let display = wl_display_connect(nil)
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = wl_display_create_queue(display)
  assert queue != nil
  ##  Create a sync dispatching events on the thread-local queue.
  let display_wrapper = cast[ptr wl_display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  wl_proxy_set_queue(cast[ptr wl_proxy](display_wrapper), queue)
  let callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  ##  Destroy the queue before the attached object.
  wl_event_queue_destroy(queue)
  ##  Check that the log contains some information about the attached
  ##  wl_callback proxy.
  var last_line: string
  client_log.setFilePos(0)
  while not client_log.endOfFile:
    last_line = client_log.readLine
  let callback_name = &"wl_callback#{wl_proxy_get_id(cast[ptr wl_proxy](callback))}"
  assert callback_name in last_line
  destroy callback
  wl_display_disconnect(display)

proc client_test_queue_proxy_event_to_destroyed_queue*() =
  var callback: ptr wl_callback
  let display = wl_display_connect(nil)
  assert display != nil
  ##  Pretend we are in a separate thread where a thread-local queue is
  ##  used.
  let queue = wl_display_create_queue(display)
  assert queue != nil
  ##  Create a sync dispatching events on the thread-local queue.
  let display_wrapper = cast[ptr wl_display](wl_proxy_create_wrapper(display))
  assert display_wrapper != nil
  wl_proxy_set_queue(cast[ptr wl_proxy](display_wrapper), queue)
  callback = display_wrapper.sync
  wl_proxy_wrapper_destroy(display_wrapper)
  assert callback != nil
  discard wl_display_flush(display)
  ##  Destroy the queue before the attached object.
  wl_event_queue_destroy(queue)
  ##  During this roundtrip we should receive the done event on 'callback',
  ##  try to queue it to the destroyed queue, and abort.
  discard wl_display_roundtrip(display)
  destroy callback
  wl_display_disconnect(display)

proc client_test_queue_destroy_default_with_attached_proxies*() =
  let display = wl_display_connect(nil)
  assert display != nil
  ##  Create a sync dispatching events on the default queue.
  let callback = display.sync
  assert callback != nil
  ##  Destroy the default queue (by disconnecting) before the attached
  ##  object.
  wl_display_disconnect(display)
  ##  Check that the log does not contain any warning about the attached
  ##  wl_callback proxy.
  client_log.setFilePos(0)
  var log = client_log.readAll
  let callback_name = &"wl_callback#{wl_proxy_get_id(cast[ptr wl_proxy](callback))}"
  assert callback_name notin log
  # dealloc callback

proc check_queue_name*(proxy: ptr wl_proxy; name: cstring) =
  var queue: ptr wl_event_queue
  queue = wl_proxy_get_queue(proxy)
  let queue_name = wl_event_queue_get_name(queue)
  assert queue_name == name

proc roundtrip_named_queue_nonblock*(display: ptr wl_display;
                                    queue: ptr wl_event_queue; name: cstring): ptr wl_callback =
  var callback: ptr wl_callback
  var wrapped_display: ptr wl_display = nil
  if queue != nil:
    wrapped_display = cast[ptr wl_display](wl_proxy_create_wrapper(display))
    assert wrapped_display != nil
    wl_proxy_set_queue(cast[ptr wl_proxy](wrapped_display), queue)
    check_queue_name(cast[ptr wl_proxy](wrapped_display), name)
    callback = wrapped_display.sync
  else:
    callback = display.sync
  check_queue_name(cast[ptr wl_proxy](callback), name)
  if wrapped_display != nil:
    wl_proxy_wrapper_destroy(wrapped_display)
  assert callback != nil
  return callback

proc client_test_queue_names*() =
  let display = wl_display_connect(nil)
  assert display != nil
  let default_queue = wl_proxy_get_queue(cast[ptr wl_proxy](display))
  let default_queue_name = wl_event_queue_get_name(default_queue)
  assert default_queue_name == "Default Queue"
  ##  Create some event queues both with and without names.
  let queue1 = wl_display_create_queue_with_name(display, "First")
  assert queue1 != nil
  let queue2 = wl_display_create_queue_with_name(display, "Second")
  assert queue2 != nil
  let queue3 = wl_display_create_queue(display)
  assert queue3 != nil
  ##  Create some requests and ensure their queues have the expected
  ##  names.
  ##
  let callback1 = roundtrip_named_queue_nonblock(display, queue1, "First")
  let callback2 = roundtrip_named_queue_nonblock(display, queue2, "Second")
  let callback3 = roundtrip_named_queue_nonblock(display, queue3, nil)
  let callback4 = roundtrip_named_queue_nonblock(display, nil, "Default Queue")
  ##  Destroy one queue with proxies still attached so we can verify
  ##  that the queue name is in the log message.
  wl_event_queue_destroy(queue2)
  client_log.setFilePos(0)
  let log = client_log.readAll
  assert "Second" in log
  ##  There's no reason for the First queue name to be present.
  assert "First" notin log
  destroy callback1
  destroy callback2
  destroy callback3
  destroy callback4
  wl_event_queue_destroy(queue1)
  wl_event_queue_destroy(queue3)
  wl_display_disconnect(display)

proc dummy_bind*(client: ptr wl_client; data: pointer; version: uint32; id: uint32) =
  discard

suite "queue":
  test "queue_proxy_destroy":
    let dummy_interfaces = [
      addr wl_seat_interface,
      addr wl_pointer_interface,
      addr wl_keyboard_interface,
      addr wl_surface_interface]
    let d = display_create()
    for i, ifce in dummy_interfaces:
      discard wl_global_create(d.wl_display, ifce, ifce.version, nil, dummy_bind)
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_proxy_destroy)
    display_run(d)
    display_destroy(d)

  test "queue_multiple_queues":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_multiple_queues)
    display_run(d)
    display_destroy(d)

  test "queue_roundtrip":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_roundtrip)
    display_run(d)
    display_destroy(d)

  test "queue_set_queue_proxy_wrapper":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_proxy_wrapper)
    display_run(d)
    display_destroy(d)

  test "queue_set_queue_race":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_set_queue_race)
    display_run(d)
    display_destroy(d)

  test "queue_destroy_with_attached_proxies":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_destroy_with_attached_proxies)
    display_run(d)
    display_destroy(d)

  test "queue_proxy_event_to_destroyed_queue":
    let d = display_create()
    # test_set_timeout(2)
    let ci = client_create_noarg(d, client_test_queue_proxy_event_to_destroyed_queue)
    display_run(d)
    ##  Check that the final line in the log mentions the expected reason
    ##  for the abort.
    ci.log.setFilePos(0)
    var lastLine: string
    while not ci.log.endOfFile: lastLine = ci.log.readLine
    check lastLine == "Tried to add event to destroyed queue"
    ##  Check that the client aborted.
    display_destroy_expect_signal(d, SIGABRT)

  test "queue_destroy_default_with_attached_proxies":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_destroy_default_with_attached_proxies)
    display_run(d)
    display_destroy(d)

  test "queue_names":
    let d = display_create()
    # test_set_timeout(2)
    discard client_create_noarg(d, client_test_queue_names)
    display_run(d)
    display_destroy(d)
