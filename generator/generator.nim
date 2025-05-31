import std/[os, strutils, sequtils, strformat, pegs, tables]

import shell, c2nim

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

proc preprocess(contents: string): string =
  result = contents
  result.remove("#if ".."#endif\n", "/*".."*/\n")
  result = result.replace("const ", "")
  result = result.replace("void (**implementation)(void)", "void *implementation")
  result = result.replace("void (**)(void)", "void *")

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

proc postprocess(contents: string): string =
  var lines = contents.splitLines
  for line in lines.mitems:
    line = line.parallelReplace(
      (peg"cdecl", "nimcall"),
      (peg"ptr\ ptr\ {\ident}", "ptr UncheckedArray[ptr $1]"),
    )
  lines.margeBlock(peg"type")
  lines.margeBlock(peg"const")

  result = lines.join("\n")

proc postprocess_server(contents: string): string =
  var lines = contents.splitLines
  for line in lines.mitems:
    line = line.parallelReplace(
      (peg"cdecl", "nimcall"),
      (peg"ptr\ ptr\ {\ident}", "ptr UncheckedArray[ptr $1]"),
    )
  lines.margeBlock(peg"type")
  lines.margeBlock(peg"const")

  lines.removeBlock(peg"proc\ init\*\(signal.*")
  lines.removeBlock(peg"proc\ add\*\(signal.*")
  lines.removeBlock(peg"proc\ get\*\(signal.*")
  lines.removeBlock(peg"proc\ emit\*\(signal.*")

  result = lines.join("\n")

const
  defs = "generator/defs.c2nim"
  deps_server = "generator/deps-server.c"
  deps_client = "generator/deps-client.c"
  outDir = "src/wayland/native"
  `outDir/gen` = outDir & "/gen"
  `outDir/gen/includes` = `outDir/gen` & "/includes"

let mangle = @{
  "^va_list$": "varargs[pointer]",
  "wl_event_loop_create$": "create_event_loop",
  "wl_event_loop_": "",
  "wl_event_source_": "",
  "wl_display_create$": "create_display",
  "wl_display_connect{.*}": "connect_display$1",
  "wl_display_": "",
  "wl_global_create$": "create_global",
  "wl_global_": "",
  "wl_client_create$": "create_client",
  "wl_client_from_link$": "client_from_link",
  "wl_client_": "",
  "wl_signal_": "",
  "wl_resource_create$": "create_resource",
  "wl_resource_from_link$": "resource_from_link",
  "wl_resource_": "",
  "wl_shm_buffer_get$": "get_shm_buffer",
  "wl_shm_buffer_create$": "create_shm_buffer",
  "wl_shm_buffer_": "",
  "wl_shm_pool_": "",
  "wl_protocol_logger_!(type)!(message)": "",
  "wl_log_!(func_t)": "",
  "wl_event_queue_": "",
  "wl_proxy_!(create_wrapper)!(wrapper_destroy)": "",
  "wl_cursor_theme_load": "load_cursor_theme",
  "wl_cursor_theme_": "",
  "wl_cursor_image_": "",
  "wl_cursor_!(theme)!(image)": "",
  "wl_egl_window_create": "create_egl_window",
  "wl_egl_window_": "",

  "wl_buffer$": "Buffer",
  "wl_callback$": "Callback",
  "wl_client$": "Client",
  "wl_compositor$": "Compositor",
  "wl_connection$": "Connection",
  "wl_data_device$": "DataDevice",
  "wl_data_device_manager$": "DataDeviceManager",
  "wl_data_offer$": "DataOffer",
  "wl_data_source$": "DataSource",
  "wl_display$": "Display",
  "wl_event_loop$": "EventLoop",
  "wl_event_queue$": "EventQueue",
  "wl_event_source$": "EventSource",
  "wl_fixes$": "Fixes",
  "wl_global$": "Global",
  "wl_keyboard$": "Keyboard",
  "wl_output$": "Output",
  "wl_pointer$": "Pointer",
  "wl_protocol_logger$": "ProtocolLogger",
  "wl_proxy$": "Proxy",
  "wl_region$": "Region",
  "wl_registry$": "Registry",
  "wl_seat$": "Seat",
  "wl_shell$": "Shell",
  "wl_shell_surface$": "ShellSurface",
  "wl_shm$": "Shm",
  "wl_shm_buffer$": "ShmBuffer",
  "wl_shm_pool$": "ShmPool",
  "wl_subcompositor$": "Subcompositor",
  "wl_subsourface$": "Subsurface",
  "wl_surface$": "Surface",
  "wl_touch$": "Touch",

  "wl_message$": "Message",
  "wl_interface$": "Interface",
  "wl_list$": "List",
  "wl_array$": "Array",
  "wl_fixed_t$": "Fixed",
  "wl_argument$": "Argument",
  "wl_object$": "Object",
  "wl_resource$": "Resource",
  "wl_signal$": "Signal",
  "wl_listener$": "Listener",
  "wl_protocol_logger_type$": "ProtocolLoggerType",
  "wl_protocol_logger_message$": "ProtocolLoggerMessage",

  "wl_egl_window$": "EglWindow",
  "wl_cursor_theme$": "CursorTheme",
  "wl_cursor_image$": "CursorImage",
  "wl_cursor$": "Cursor",
}

type
  ScannerFlag = enum
    include_core_only = "--include-core-only"
  ScannerArgs = object
    flags: set[ScannerFlag]
    `in`: string
    `out`: string
    requires: seq[string]
  ProtocolInfo = object
    protocolName: string
    version: string
    status: string
    filepath: string

const
  protocolsIn = "/usr/share/wayland-protocols"
  protocolsOut = "src/wayland/protocols"

  requires = toTable {
    "cursor-shape": @[
      "wayland/protocols/stable/tablet/v2"],
    "ext-image-capture-source": @[
      "wayland/protocols/staging/extForeignToplevelList/v1"],
    "ext-image-copy-capture": @[
      "wayland/protocols/staging/extImageCaptureSource/v1"],
    "xdg-dialog": @[
      "wayland/protocols/stable/xdgShell"],
    "xdg-toplevel-drag": @[
      "wayland/protocols/stable/xdgShell"],
    "xdg-toplevel-icon": @[
      "wayland/protocols/stable/xdgShell"],
    "xdg-toplevel-tag": @[
      "wayland/protocols/stable/xdgShell"],
    "xdg-decoration-unstable": @[
      "wayland/protocols/stable/xdgShell"],
  }

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
    mangle: mangle,
    preprocess: preprocess, postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true, cdecl: true,
  )
  server_core = C2NimArgs(
    `in`: @[defs, deps_server, serverSourceDir/"wayland-server-core.h"],
    `out`: `outDir/gen/includes`/"server_core.nim",
    dynlib: "libwayland-server.so",
    mangle: mangle,
    preprocess: preprocess, postprocess: postprocess_server,
    skipcomments: true, skipinclude: true, stdints: true, importc: true, cdecl: true,
  )
  version = C2NimArgs(
    `in`: @[defs, versionSourceDir/"wayland-version.h"],
    `out`: `outDir/gen`/"version.nim",
    mangle: mangle,
    preprocess: preprocess, postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true, cdecl: true,
    )
  cursor = C2NimArgs(
    `in`: @[defs, cursorSourceDir/"wayland-cursor.h"],
    `out`: `outDir/gen/includes`/"cursor.nim",
    dynlib: "libwayland-cursor.so",
    mangle: mangle,
    preprocess: preprocess, postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true, cdecl: true,
  )
  egl = C2NimArgs(
    `in`: @[defs, eglSourceDir/"wayland-egl-core.h"],
    `out`: `outDir/gen/includes`/"egl.nim",
    dynlib: "libwayland-egl.so",
    mangle: mangle,
    preprocess: preprocess, postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true, cdecl: true,
  )

iterator collectProtocols(root: string): ProtocolInfo =
  for path in root.walkDirRec():
    let (dir, nameWithVer, ext) = path.splitFile
    if ext != ".xml": continue
    let delimAt = nameWithVer.rfind("-")
    let (name, ver) =
      if delimAt != -1 and nameWithVer[delimAt.succ..^1] =~ peg"v[0-9]+":
        (nameWithVer[0..delimAt.pred], nameWithVer[delimAt.succ..^1])
      else:
        (nameWithVer, "")
    var stat: string
    for parent in dir.parentDirs:
      stat = parent.splitFile.name
      if stat in ["stable", "staging", "unstable"]:
        break

    yield ProtocolInfo(
      protocolName: name,
      version: ver,
      status: stat,
      filepath: path,
    )

proc toScannerArgs(info: ProtocolInfo): ScannerArgs =
  result = ScannerArgs(
    `in`: info.filepath,
    `out`: protocolsOut/info.status/nimIdentNormalize(info.protocolName.replace("-", "_"))/info.version
  )
  result.requires = requires.getOrDefault(info.protocolName, @[])

const
  wayland = ScannerArgs(
    flags: {include_core_only},
    `in`: "/usr/share/wayland/wayland.xml",
    `out`: protocolsOut/"wayland",
  )

proc `bin/wayland-nim-scanner`(shell: ShellEnv; args: ScannerArgs): ShellEnv =
  shell.exec("bin/wayland-nim-scanner", args.flags.toSeq.mapIt($it) & @[args.`in`, "--outdir:" & args.`out`] & args.requires.mapIt("--require:" & it))

removeDir "src/wayland/native/gen"
removeDir "src/wayland/protocols"

discard cd"."
  .c2nim(version)
  .c2nim(client_core)
  .c2nim(server_core)
  .c2nim(cursor)
  .c2nim(egl)

  .nimble("build")
  .`bin/wayland-nim-scanner`(wayland)

for protocol in protocolsIn.collectProtocols:
  discard cd".".`bin/wayland-nim-scanner`(protocol.toScannerArgs)