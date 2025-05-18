import std/[os, strutils, sequtils, strformat, pegs]

import shell

proc remove(content: var string; ranges: varargs[HSlice[string, string]]) =
  for range in ranges:
    while true:
      var s, e: int
      s = content.find(range.a)
      if s >= 0:
        e = content.find(range.b, s.succ)
        if e >= 0:
          content = content[0..<s] & content[e+range.b.len..^1]
      else:
        break

proc preprocess(infile: string): #[outfile:]# string =
  result = "tmp"/infile
  createDir result.parentDir
  var content = readFile(infile)
  content.remove("#if ".."#endif\n", "/*".."*/\n")
  content = content.replace("const ", "")
  content = content.replace("void (**implementation)(void)", "void *implementation")
  content = content.replace("void (**)(void)", "void *")

  writeFile(result, content)

proc margeBlock(content: var seq[string]; header: Peg) =
  var i: int
  var tail: int
  while i < content.len:
    if content[i] =~ header:
      if tail == 0:
        var j = i + 1
        while j < content.len and (content[j].indentation >= 2 or content[j] == ""):
          if content[j].len == 0:
            content.delete(j)
          else:
            tail = j + 1
            inc j
      else:
        content.delete(i)
        var j = i
        while j < content.len and (content[j].indentation >= 2 or content[j] == ""):
          if content[j].len == 0:
            content.delete(j)
          else:
            content.insert(content[j], tail)
            content.delete(j + 1)
            inc j
            inc tail

    inc i

proc removeBlock(contents: var seq[string]; header: Peg) =
  var i: int
  var inbody: bool
  var indent: int
  while i < contents.len:
    if inbody and contents[i] != "" and contents[i].indentation <= indent:
      inbody = false
    if contents[i] =~ header:
      inbody = true
      indent = contents[i].indentation
    if inbody:
      contents.delete i
      dec i
    inc i

proc postprocess(contents: seq[string]): seq[string] =
  result = contents
  for line in result.mitems:
    line = line.parallelReplace(
      (peg"cdecl", "nimcall"),
      (peg"ptr\ ptr\ {\ident}", "ptr UncheckedArray[ptr $1]"),
    )
  result.margeBlock(peg"type")
  result.margeBlock(peg"const")

proc postprocess_server(contents: seq[string]): seq[string] =
  result = postprocess contents

  result.removeBlock(peg"proc\ init\*\(signal.*")
  result.removeBlock(peg"proc\ add\*\(signal.*")
  result.removeBlock(peg"proc\ get\*\(signal.*")
  result.removeBlock(peg"proc\ emit\*\(signal.*")

const
  defs = "generator/defs.c2nim"
  deps_server = "generator/deps-server.c"
  deps_client = "generator/deps-client.c"
  outDir = "src/wayland/native"
  `outDir/gen` = outDir & "/gen"
  `outDir/gen/includes` = `outDir/gen` & "/includes"

type C2NimArgs = object
  `in`: seq[string]
  `out`: string
  dynlib: string

var
  clientSourceDir = exec("pkg-config", ["--variable=includedir", "wayland-client"]).out.splitLines[0]
  serverSourceDir = exec("pkg-config", ["--variable=includedir", "wayland-server"]).out.splitLines[0]
  cursorSourceDir = exec("pkg-config", ["--variable=includedir", "wayland-cursor"]).out.splitLines[0]
  eglSourceDir = exec("pkg-config", ["--variable=includedir", "wayland-egl"]).out.splitLines[0]
  versionSourceDir = clientSourceDir

  client_core = C2NimArgs(
    `in`: @[defs, deps_client, clientSourceDir/"wayland-client-core.h"],
    `out`: `outDir/gen/includes`/"client_core.nim",
    dynlib: "libwayland-client.so",
  )
  server_core = C2NimArgs(
    `in`: @[defs, deps_server, serverSourceDir/"wayland-server-core.h"],
    `out`: `outDir/gen/includes`/"server_core.nim",
    dynlib: "libwayland-server.so",
  )
  version = C2NimArgs(
    `in`: @[defs, versionSourceDir/"wayland-version.h"],
    `out`: `outDir/gen`/"version.nim",
    )
  cursor = C2NimArgs(
    `in`: @[defs, cursorSourceDir/"wayland-cursor.h"],
    `out`: `outDir/gen/includes`/"cursor.nim",
    dynlib: "libwayland-cursor.so",
  )
  egl = C2NimArgs(
    `in`: @[defs, eglSourceDir/"wayland-egl-core.h"],
    `out`: `outDir/gen/includes`/"egl.nim",
    dynlib: "libwayland-egl.so",
  )

proc c2nim(shell: ShellEnv; args: C2NimArgs; postprocess: proc(contents: seq[string]): seq[string] = postprocess): ShellEnv =
  var a = args.in.map(preprocess)
  createDir args.out.parentDir
  a.add "--out:" & args.out
  if args.dynlib.len != 0:
    a.add &"--dynlib:\"{args.dynlib}\""
  a.add [
    "--concat", "--skipcomments", "--skipinclude", "--stdints", "--importc", "--cdecl",
    r"--mangle:'^va_list$=varargs[pointer]'",
    r"--mangle:'wayland\-client=client_core'",
    r"--mangle:'wayland\-server=server_core'",
    r"--mangle:wayland\-util=util",
    r"--mangle:wayland\-version=version",
    r"--mangle:wl_event_loop_create$=create_event_loop",
    r"--mangle:wl_event_loop_=",
    r"--mangle:wl_event_source_=",
    r"--mangle:wl_display_create$=create_display",
    r"--mangle:wl_display_connect{.*}=connect_display$1",
    r"--mangle:wl_display_=",
    r"--mangle:wl_global_create$=create_global",
    r"--mangle:wl_global_=",
    r"--mangle:wl_client_create$=create_client",
    r"--mangle:wl_client_from_link$=client_from_link",
    r"--mangle:wl_client_=",
    r"--mangle:wl_signal_=",
    r"--mangle:wl_resource_create$=create_resource",
    r"--mangle:wl_resource_from_link$=resource_from_link",
    r"--mangle:wl_resource_=",
    r"--mangle:wl_shm_buffer_get$=get_shm_buffer",
    r"--mangle:wl_shm_buffer_create$=create_shm_buffer",
    r"--mangle:wl_shm_buffer_=",
    r"--mangle:wl_shm_pool_=",
    r"--mangle:wl_protocol_logger_!(type)!(message)=",
    r"--mangle:wl_log_!(func_t)=",
    r"--mangle:wl_event_queue_=",
    r"--mangle:wl_proxy_!(create_wrapper)!(wrapper_destroy)=",
    r"--mangle:wl_cursor_theme_load=load_cursor_theme",
    r"--mangle:wl_cursor_theme_=",
    r"--mangle:wl_cursor_image_=",
    r"--mangle:wl_cursor_!(theme)!(image)=",
    r"--mangle:wl_egl_window_create=create_egl_window",
    r"--mangle:wl_egl_window_=",

    r"--mangle:wl_buffer$=Buffer",
    r"--mangle:wl_callback$=Callback",
    r"--mangle:wl_client$=Client",
    r"--mangle:wl_compositor$=Compositor",
    r"--mangle:wl_connection$=Connection",
    r"--mangle:wl_data_device$=DataDevice",
    r"--mangle:wl_data_device_manager$=DataDeviceManager",
    r"--mangle:wl_data_offer$=DataOffer",
    r"--mangle:wl_data_source$=DataSource",
    r"--mangle:wl_display$=Display",
    r"--mangle:wl_event_loop$=EventLoop",
    r"--mangle:wl_event_queue$=EventQueue",
    r"--mangle:wl_event_source$=EventSource",
    r"--mangle:wl_fixes$=Fixes",
    r"--mangle:wl_global$=Global",
    r"--mangle:wl_keyboard$=Keyboard",
    r"--mangle:wl_output$=Output",
    r"--mangle:wl_pointer$=Pointer",
    r"--mangle:wl_protocol_logger$=ProtocolLogger",
    r"--mangle:wl_proxy$=Proxy",
    r"--mangle:wl_region$=Region",
    r"--mangle:wl_registry$=Registry",
    r"--mangle:wl_seat$=Seat",
    r"--mangle:wl_shell$=Shell",
    r"--mangle:wl_shell_surface$=ShellSurface",
    r"--mangle:wl_shm$=Shm",
    r"--mangle:wl_shm_buffer$=ShmBuffer",
    r"--mangle:wl_shm_pool$=ShmPool",
    r"--mangle:wl_subcompositor$=Subcompositor",
    r"--mangle:wl_subsourface$=Subsurface",
    r"--mangle:wl_surface$=Surface",
    r"--mangle:wl_touch$=Touch",

    r"--mangle:wl_message$=Message",
    r"--mangle:wl_interface$=Interface",
    r"--mangle:wl_list$=List",
    r"--mangle:wl_array$=Array",
    r"--mangle:wl_fixed_t$=Fixed",
    r"--mangle:wl_argument$=Argument",
    r"--mangle:wl_object$=Object",
    r"--mangle:wl_resource$=Resource",
    r"--mangle:wl_signal$=Signal",
    r"--mangle:wl_listener$=Listener",
    r"--mangle:wl_protocol_logger_type$=ProtocolLoggerType",
    r"--mangle:wl_protocol_logger_message$=ProtocolLoggerMessage",

    r"--mangle:wl_egl_window$=EglWindow",
    r"--mangle:wl_cursor_theme$=CursorTheme",
    r"--mangle:wl_cursor_image$=CursorImage",
    r"--mangle:wl_cursor$=Cursor",
  ]
  result = shell.exec("c2nim", a)
  args.out.writeFile postprocess(args.out.readFile.splitLines).join("\n")

type
  ScannerFlag = enum
    include_core_only = "--include-core-only"
  ScannerArgs = object
    flags: set[ScannerFlag]
    `in`: string
    `out`: string

const
  protocolsIn = "/usr/share/wayland-protocols"
  protocolsOut = "src/wayland/protocols"

proc initScannerArgs(status, name: string; ver: string = ""; flags: set[ScannerFlag] = {}): ScannerArgs =
  ScannerArgs(
    flags: flags,
    `in`: protocolsIn/status/name/name & (if ver == "": ".xml" else: &"-{ver}.xml"),
    `out`: protocolsOut/status/nimIdentNormalize(name.replace("-", "_")) & (if status == "stable": "" else: ver)
  )

const
  wayland = ScannerArgs(
    flags: {include_core_only},
    `in`: "/usr/share/wayland/wayland.xml",
    `out`: protocolsOut/"wayland",
  )

  stable = "stable"
  linux_dmabuf = initScannerArgs(stable, "linux-dmabuf", "v1")
  presentation_time = initScannerArgs(stable, "presentation-time")
  tablet = initScannerArgs(stable, "tablet", "v2")
  viewporter = initScannerArgs(stable, "viewporter")
  xdg_shell = initScannerArgs(stable, "xdg-shell")

proc `bin/wayland-nim-scanner`(shell: ShellEnv; args: ScannerArgs): ShellEnv =
  shell.exec("bin/wayland-nim-scanner", args.flags.toSeq.mapIt($it) & @[args.`in`, "--outdir:" & args.`out`])

discard cd"."
  .c2nim(version)
  .c2nim(client_core)
  .c2nim(server_core, postprocess_server)
  .c2nim(cursor)
  .c2nim(egl)

  .nimble("build")
  .`bin/wayland-nim-scanner`(wayland)
  .`bin/wayland-nim-scanner`(linux_dmabuf)
  .`bin/wayland-nim-scanner`(presentation_time)
  .`bin/wayland-nim-scanner`(tablet)
  .`bin/wayland-nim-scanner`(viewporter)
  .`bin/wayland-nim-scanner`(xdg_shell)
