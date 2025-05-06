import std/[posix, atomics, times, strformat, os, tempfiles]
import wayland/native/server
import wayland/native/client

# info about a client on server side
type
  ClientInfo* {.bycopy.} = object
    display*: ptr Display
    wl_client*: ptr wl_client
    destroy_listener*: wl_listener
    name*: cstring
    ##  for debugging
    pipe*: cint
    pid*: pid_t
    exit_code*: cint
    kill_code*: cint
    data*: pointer
    ##  for arbitrary use
    log*: File

  Display* {.bycopy.} = object
    wl_display*: ptr wl_display
    test_global*: ptr wl_global
    clients*: seq[ptr ClientInfo]
    clients_terminated_no*: int
    ##  list of clients waiting for display_resumed event
    waiting_for_resume*: seq[ptr Wfr]

  Client* {.bycopy.} = object
    ##  This is a helper structure for clients.
    ##  Instead of calling wl_display_connect() and all the other stuff,
    ##  client can use client_connect and it will return this structure
    ##  filled.
    wl_display*: ptr wl_display
    tc*: ptr TestCompositor
    display_stopped*: Atomic[bool]

  TestCompositor* = object

  Wfr* {.bycopy.} = object
    ## Waiting For Resume
    resource*: ptr wl_resource

proc client_connect*(): ptr Client
proc client_disconnect*(c: ptr Client)
proc stop_display*(c: ptr Client; num: cint): cint
proc noop_request*(c: ptr Client)

## Usual workflow:
## 
## ```nim
## d = display_create()
##
## wl_global_create(d.wl_display, ...)
## ... other setups ...
##
## client_create(d, client_main, data)
## client_create(d, client_main2, data)
##
## display_run(d)
## display_destroy(d)
## ```

proc display_create*(): ptr Display
proc display_destroy*(d: ptr Display)
proc display_destroy_expect_signal*(d: ptr Display; signum: cint)
proc display_run*(d: ptr Display)

proc display_post_resume_events*(d: ptr Display)
  ##  This function posts the display_resumed event to all waiting clients,
  ##  so that after flushing events the clients will stop waiting and continue.
  ##
  ##  (Calling `display_run` after this function will resume the display loop.)
  ##

proc display_resume*(d: ptr Display)
  ##  After n clients called stop_display(..., n), the display
  ##  is stopped and can process the code after display_run().
  ##
  ##  This function posts the display_resumed event to the waiting
  ##  clients, so that the clients will stop waiting and continue;
  ##  it then reruns the display.

var client_log*: File
  ##  The file descriptor containing the client log. This is only valid in the
  ##  test client processes.

proc client_create_with_name*(d: ptr Display; client_main: proc (data: pointer) {.nimcall.};
                             data: pointer; name: cstring): ptr ClientInfo
template client_create*(d, c, data: untyped): untyped =
  client_create_with_name((d), (c), data, (astToStr(c)))

proc noarg_cb*(data: pointer) =
  let cb = cast[proc() {.nimcall.}](data)
  cb()

proc client_create_with_name_noarg*(d: ptr Display; client_main: proc () {.nimcall.}; name: cstring): ptr Client_info {.
    inline.} =
  return client_create_with_name(d, noarg_cb, client_main, name)

template client_create_noarg*(d, c: untyped): untyped =
  client_create_with_name_noarg((d), (c), (astToStr(c)))

# --- Protocol ---

let
  tc_requests = [
    # this request serves as a barrier for synchronizing
    wl_message(name: "stop_display", signature: "u", types: nil),
    wl_message(name: "noop", signature: "", types: nil),
  ]
  tc_events = [
    wl_message(name: "display_resumed", signature: "", types: nil),
  ]
  test_compositor_interface = wl_interface(
    name: "test", version: 1,
    method_count: 2, methods: addr tc_requests[0],
    event_count: 1, events: addr tc_events[0],
  )

type
  TestCompositorInterface* {.bycopy.} = object
    stop_display*: proc (client: ptr wl_client; resource: ptr wl_resource; num: uint32)
    noop*: proc (client: ptr wl_client; resource: ptr wl_resource)

  TestCompositorListener* {.bycopy.} = object
    display_resumed*: proc (data: pointer; tc: ptr TestCompositor)

const
  STOP_DISPLAY = 0
  TEST_NOOP = 1
  DISPLAY_RESUMED = 0

proc get_socket_name*(): string =
  ## Since tests can run parallelly, we need unique socket names
  ## for each test, otherwise the test can fail on wl_display_add_socket.
  &"wayland-test-{getpid()}-{now()}"

proc handle_client_destroy*(data: pointer) =
  let ci = cast[ptr ClientInfo](data)
  let d = ci.display
  var status: cint
  assert(waitpid(ci.pid, status, 0) != -1)
  if WIFSIGNALED(status):
    stderr.writeLine &"Client \'{ci.name}\' was killed by signal {WTERMSIG(status)}"
    ci.kill_code = WTERMSIG(status)
  elif WIFEXITED(status):
    if WEXITSTATUS(status) != QuitSuccess:
      stderr.writeLine &"Client \'{ci.name}\' exited with code {WEXITSTATUS(status)}"
    ci.exit_code = WEXITSTATUS(status)
  inc d.clients_terminated_no
  if d.clients.len == d.clients_terminated_no:
    wl_display_terminate(d.wl_display)
  # the clients are not removed from the list, because
  # at the end of the test we check the exit codes of all
  # clients. In the case that the test would go through
  # the clients list manually, zero out the wl_client as a sign
  # that the client is not running anymore

# Check client's state and terminate display when all clients exited

proc client_destroyed*(listener: ptr wl_listener; data: pointer) =
  var ci: ptr ClientInfo
  ##  Wait for client in an idle handler to avoid blocking the actual
  ##  client destruction (fd close etc.
  ci = wl_container_of(listener, ci, destroy_listener)
  let d = ci.display
  let loop = wl_display_get_event_loop(d.wl_display)
  discard wl_event_loop_add_idle(loop, handle_client_destroy, ci)
  ci.wl_client = nil

proc client_log_handler*(fmt {.exportc.}: cstring; arg {.exportc.}: va_list) =
  let client_log_fd {.exportc.} = client_log.getFileHandle
  {.emit: """
  va_list arg_copy;

	va_copy(arg_copy, arg);
	vdprintf(client_log_fd, fmt, arg_copy);
	va_end(arg_copy);

	vfprintf(stderr, fmt, arg);
  """ .}

proc run_client*(client_main: proc (data: pointer) {.nimcall.}; data: pointer; wayland_sock: cint;
                client_pipe: cint; log: File) =
  var can_continue: cint = 0
  ##  Wait until display signals that client can continue
  assert read(client_pipe, addr(can_continue), sizeof((int))) == sizeof((int))
  if can_continue == 0:
    quit 1
  if not existsEnv("WAYLAND_SOCKET"):
    putEnv("WAYLAND_SOCKET", $wayland_sock)
  ##  Capture the log to the specified file descriptor.
  client_log = log
  wl_log_set_handler_client(client_log_handler)
  # var cur_fds = count_open_fds()
  client_main(data)
  ##  Clients using wl_display_connect() will end up closing the socket
  ##  passed in through the WAYLAND_SOCKET environment variable. When
  ##  doing this, it clears the environment variable, so if it's been
  ##  unset, then we assume the client consumed the file descriptor and
  ##  do not count it towards leak checking.
  # if not existsEnv("WAYLAND_SOCKET"):
  #   dec(cur_fds)
  # check_fd_leaks(cur_fds)

proc create_log*(): File =
  result = createTempFile("wayland-tests-log", "").cfile

proc display_create_client*(d: ptr Display; client_main: proc (data: pointer) {.nimcall.};
                           data: pointer; name: cstring): ptr ClientInfo =
  var pipe_cli: array[2, cint]
  var sock_wayl: array[2, cint]
  var pid: pid_t
  var can_continue: cint = 0
  assert pipe(pipe_cli) == 0 # Failed creating pipe
  assert socketpair(AF_UNIX, SOCK_STREAM, 0, sock_wayl) == 0 # Failed creating socket pair
  let log = create_log()
  assert log != nil # Failed to create log fd
  pid = fork()
  assert pid != -1 # Fork failed
  if pid == 0:
    discard close sock_wayl[1]
    discard close pipe_cli[1]
    run_client(client_main, data, sock_wayl[0], pipe_cli[0], log)
    discard close sock_wayl[0]
    discard close pipe_cli[0]
    close log
    quit 0
  discard close sock_wayl[0]
  discard close pipe_cli[0]
  result = cast[ptr ClientInfo](alloc sizeof ClientInfo)
  zeromem result, sizeof ClientInfo
  assert result != nil # Out of memory
  d.clients.add result
  result.display = d
  result.name = name
  result.pid = pid
  result.pipe = pipe_cli[1]
  result.log = log
  result.destroy_listener.notify = client_destroyed
  result.wl_client = wl_client_create(d.wl_display, sock_wayl[1])
  if result.wl_client == nil:
    ##  abort the client
    let ret = write(result.pipe, addr can_continue, sizeof int)
    assert ret == sizeof(int) # aborting the client failed
    assert false # Couldnt create wayland client
  wl_client_add_destroy_listener(result.wl_client, addr result.destroy_listener)

proc client_create_with_name*(d: ptr Display; client_main: proc (data: pointer) {.nimcall.};
                             data: pointer; name: cstring): ptr ClientInfo =
  var can_continue: cint = 1
  result = display_create_client(d, client_main, data, name)
  ##  let the show begin!
  assert write(result.pipe, addr can_continue, sizeof int) == sizeof int

proc handle_stop_display*(client: ptr wl_client; resource: ptr wl_resource;
                         num: uint32) =
  var d = cast[ptr Display](wl_resource_get_user_data(resource))
  var wfr: ptr Wfr
  assert d.waiting_for_resume.len < int num # test error: Too many clients sent stop_display request
  wfr = cast[ptr Wfr](alloc sizeof Wfr)
  if wfr == nil:
    wl_client_post_no_memory(client)
    assert false # Out of memory
  wfr.resource = resource
  d.waiting_for_resume.add wfr
  if d.waiting_for_resume.len == int num:
    wl_display_terminate(d.wl_display)

proc handle_noop*(client: ptr wl_client; resource: ptr wl_resource) =
  discard

let tc_implementation* = TestCompositorInterface(
    stop_display: handle_stop_display, noop: handle_noop)

proc tc_bind*(client: ptr wl_client; data: pointer; ver: uint32; id: uint32) =
  let res = wl_resource_create(client, addr test_compositor_interface, cint ver, id)
  if res == nil:
    wl_client_post_no_memory(client)
    assert false # Out of memory
  wl_resource_set_implementation(res, addr tc_implementation, data, nil)

proc display_create*(): ptr Display =
  var stat: cint = 0
  result = cast[ptr Display](alloc sizeof Display)
  zeroMem result, sizeof Display
  assert result != nil # Out of memory
  result.wl_display = wl_display_create()
  assert result.wl_display != nil # Creating display failed
  ##  hope the path won't be longer than 108 ...
  var socket_name = get_socket_name()
  stat = wl_display_add_socket(result.wl_display, cstring socket_name)
  assert stat == 0 # Failed adding socket
  result.clients_terminated_no = 0
  result.test_global = wl_global_create(result.wl_display, addr test_compositor_interface, 1,
                                 result, tc_bind)
  assert result.test_global != nil # Creating test global failed

proc display_run*(d: ptr Display) =
  assert d.waiting_for_resume.len == 0 # test error: Have waiting clients. Use display_resume.
  wl_display_run(d.wl_display)

proc display_post_resume_events*(d: ptr Display) =
  assert d.waiting_for_resume.len > 0 # test error: No clients waiting.
  for i in countdown(d.waiting_for_resume.high, 0):
    let wfr = d.waiting_for_resume[i]
    wl_resource_post_event(wfr.resource, DISPLAY_RESUMED)
    d.waiting_for_resume.del i
    dealloc wfr

  assert d.waiting_for_resume.len == 0

proc display_resume*(d: ptr Display) =
  display_post_resume_events(d)
  wl_display_run(d.wl_display)


proc display_destroy_expect_signal*(d: ptr Display; signum: cint) =
  ## If signum is 0, expect a successful client exit, otherwise
  ## expect the client to have been killed by that signal.
  var failed: cint = 0
  assert d.waiting_for_resume.len == 0 # test error: Didn't you forget to call display_resume?
  for cl in d.clients:
    assert cl.wl_client == nil

    if signum != 0 and cl.kill_code != signum:
      inc failed
      stderr.writeLine &"Client '{cl.name}' failed, expecting signal {signum}, got {cl.kill_code}"
    elif signum == 0 and (cl.kill_code != 0 or cl.exit_code != 0):
      inc failed
      stderr.writeLine &"Client '{cl.name}' failed"

    discard close cl.pipe
    close cl.log
    dealloc cl

  wl_global_destroy(d.test_global)
  wl_display_destroy(d.wl_display)
  dealloc d
  if failed != 0:
    quit &"{failed} child(ren) failed"

proc display_destroy*(d: ptr Display) =
  display_destroy_expect_signal(d, 0)

# --- Client helper functions ---

proc handle_display_resumed*(data: pointer; tc: ptr TestCompositor) =
  let c = cast[ptr Client](data)
  c.display_stopped.store false

let tc_listener* = TestCompositorListener(
    display_resumed: handle_display_resumed)

proc registry_handle_globals*(data: pointer; registry: ptr wl_registry; id: uint32;
                             intf: cstring; ver: uint32) =
  let c = cast[ptr Client](data)
  if intf == "test":
    return
  c.tc = cast[ptr TestCompositor](registry.bind(id, addr test_compositor_interface, ver))
  assert c.tc != nil # Failed binding to registry
  discard wl_proxy_add_listener(cast[ptr wl_proxy](c.tc), cast[pointer](addr(tc_listener)), c)

let registry_listener* = WlRegistryListener(
  global: registry_handle_globals,
  global_remove: nil)

proc client_connect*(): ptr Client =
  var reg: ptr wl_registry
  result = cast[ptr Client](alloc sizeof Client)
  zeroMem result, sizeof Client
  assert result != nil # Out of memory
  result.wl_display = wl_display_connect(nil)
  assert result.wl_display != nil # Failed connecting to display
  ##  create test_compositor proxy. Do it with temporary
  ##  registry so that client can define it's own listener later
  reg = result.wl_display.getRegistry
  assert reg != nil
  discard reg.addListener(addr registry_listener, result)
  discard wl_display_roundtrip(result.wl_display)
  assert result.tc != nil
  destroy reg

proc check_error*(display: ptr wl_display) =
  var
    ec: uint32
    id: uint32
  var intf: ptr wl_interface
  var err: cint
  err = wl_display_get_error(display)
  ##  write out message about protocol error
  if err == EPROTO:
    ec = wl_display_get_protocol_error(display, addr intf, addr id)
    stderr.writeLine &"Client: Got protocol error {ec} on interface {intf.name} (object {id})"
  if err != 0:
    quit &"Client error: {strerror(err)}"

proc client_disconnect*(c: ptr Client) =
  ##  check for errors
  check_error(c.wl_display)
  wl_proxy_destroy(cast[ptr wl_proxy](c.tc))
  wl_display_disconnect(c.wl_display)
  dealloc c

proc stop_display*(c: ptr Client; num: cint): cint =
  ## num is number of clients that requests to stop display.
  ## Display is stopped after it receives num STOP_DISPLAY requests
  c.display_stopped.store true
  wl_proxy_marshal(cast[ptr wl_proxy](c.tc), STOP_DISPLAY, num)
  while c.display_stopped.load and result >= 0:
    result = wl_display_dispatch(c.wl_display)

proc noop_request*(c: ptr Client) =
  wl_proxy_marshal(cast[ptr wl_proxy](c.tc), TEST_NOOP)
