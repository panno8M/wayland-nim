import std/[os, strutils, sequtils, pegs, tables]
        
import shellsophia/[shell, commands/c2nim]

import generator/astutils

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


let mangleRules = @{
  parsePeg"^va_list$": "varargs[pointer]",
  parsePeg"wl_event_loop_create$": "create_event_loop",
  parsePeg"wl_event_loop_": "",
  parsePeg"wl_event_source_": "",
  parsePeg"wl_display_create$": "create_display",
  parsePeg"wl_display_connect{.*}": "connect_display$1",
  parsePeg"wl_display_": "",
  parsePeg"wl_global_create$": "create_global",
  parsePeg"wl_global_": "",
  parsePeg"wl_client_create$": "create_client",
  parsePeg"wl_client_from_link$": "client_from_link",
  parsePeg"wl_client_": "",
  parsePeg"wl_signal_": "",
  parsePeg"wl_resource_create$": "create_resource",
  parsePeg"wl_resource_from_link$": "resource_from_link",
  parsePeg"wl_resource_": "",
  parsePeg"wl_shm_buffer_get$": "get_shm_buffer",
  parsePeg"wl_shm_buffer_create$": "create_shm_buffer",
  parsePeg"wl_shm_buffer_": "",
  parsePeg"wl_shm_pool_": "",
  parsePeg"wl_protocol_logger_!(type)!(message)": "",
  parsePeg"wl_log_!(func_t)": "",
  parsePeg"wl_event_queue_": "",
  parsePeg"wl_proxy_!(create_wrapper)!(wrapper_destroy)": "",
  parsePeg"wl_cursor_theme_load": "load_cursor_theme",
  parsePeg"wl_cursor_theme_": "",
  parsePeg"wl_cursor_image_": "",
  parsePeg"wl_cursor_!(theme)!(image)": "",
  parsePeg"wl_egl_window_create": "create_egl_window",
  parsePeg"wl_egl_window_": "",

  parsePeg"wl_buffer$": "Buffer",
  parsePeg"wl_callback$": "Callback",
  parsePeg"wl_client$": "Client",
  parsePeg"wl_compositor$": "Compositor",
  parsePeg"wl_connection$": "Connection",
  parsePeg"wl_data_device$": "DataDevice",
  parsePeg"wl_data_device_manager$": "DataDeviceManager",
  parsePeg"wl_data_offer$": "DataOffer",
  parsePeg"wl_data_source$": "DataSource",
  parsePeg"wl_display$": "Display",
  parsePeg"wl_event_loop$": "EventLoop",
  parsePeg"wl_event_queue$": "EventQueue",
  parsePeg"wl_event_source$": "EventSource",
  parsePeg"wl_fixes$": "Fixes",
  parsePeg"wl_global$": "Global",
  parsePeg"wl_keyboard$": "Keyboard",
  parsePeg"wl_output$": "Output",
  parsePeg"wl_pointer$": "Pointer",
  parsePeg"wl_protocol_logger$": "ProtocolLogger",
  parsePeg"wl_proxy$": "Proxy",
  parsePeg"wl_region$": "Region",
  parsePeg"wl_registry$": "Registry",
  parsePeg"wl_seat$": "Seat",
  parsePeg"wl_shell$": "Shell",
  parsePeg"wl_shell_surface$": "ShellSurface",
  parsePeg"wl_shm$": "Shm",
  parsePeg"wl_shm_buffer$": "ShmBuffer",
  parsePeg"wl_shm_pool$": "ShmPool",
  parsePeg"wl_subcompositor$": "Subcompositor",
  parsePeg"wl_subsourface$": "Subsurface",
  parsePeg"wl_surface$": "Surface",
  parsePeg"wl_touch$": "Touch",

  parsePeg"wl_message$": "Message",
  parsePeg"wl_interface$": "Interface",
  parsePeg"wl_list$": "List",
  parsePeg"wl_array$": "Array",
  parsePeg"wl_fixed_t$": "Fixed",
  parsePeg"wl_argument$": "Argument",
  parsePeg"wl_object$": "Object",
  parsePeg"wl_resource$": "Resource",
  parsePeg"wl_signal$": "Signal",
  parsePeg"wl_listener$": "Listener",
  parsePeg"wl_protocol_logger_type$": "ProtocolLoggerType",
  parsePeg"wl_protocol_logger_message$": "ProtocolLoggerMessage",

  parsePeg"wl_egl_window$": "EglWindow",
  parsePeg"wl_cursor_theme$": "CursorTheme",
  parsePeg"wl_cursor_image$": "CursorImage",
  parsePeg"wl_cursor$": "Cursor",
}


proc postprocess(ast: PNode): PNode =
  result = ast
    .margeSection(nkTypeSection)
    .margeSection(nkConstSection)
    .removeProcs(@["wl_signal_init", "wl_signal_add", "wl_signal_get", "wl_signal_emit"])
    .mangle(mangleRules)
    .map(proc(ast: PNode): PNode =
      case ast.kind
      of nkIdentDefs:
        if ast[0].kind == nkIdent and ast[0].ident.s == "implementation":
          ast[1] = ident"pointer"
      of nkPtrTy:
        if ast[0].kind == nkPtrTy:
          ast[0] = nkBracketExpr.newTree(ident"UncheckedArray", ast[0])
      else:
        discard
      ast
    )
  for typesec in result:
    if typesec.kind != nkTypeSection: continue
    for procty in typesec.collect(nkProcTy):
      procty[1] = nkPragma.newTree(ident"nimcall")

const
  defs = "src/generator/defs.c2nim"
  deps_server = "src/generator/deps-server.c"
  deps_client = "src/generator/deps-client.c"
  outDir = "../src/wayland/native"
  `outDir/gen` = outDir & "/gen"
  `outDir/gen/includes` = `outDir/gen` & "/includes"

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
  protocolsOut = "../src/wayland/protocols"

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
    postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true,
  )
  server_core = C2NimArgs(
    `in`: @[defs, deps_server, serverSourceDir/"wayland-server-core.h"],
    `out`: `outDir/gen/includes`/"server_core.nim",
    dynlib: "libwayland-server.so",
    postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true,
  )
  version = C2NimArgs(
    `in`: @[defs, versionSourceDir/"wayland-version.h"],
    `out`: `outDir/gen`/"version.nim",
    postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true,
    )
  cursor = C2NimArgs(
    `in`: @[defs, cursorSourceDir/"wayland-cursor.h"],
    `out`: `outDir/gen/includes`/"cursor.nim",
    dynlib: "libwayland-cursor.so",
    postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true,
  )
  egl = C2NimArgs(
    `in`: @[defs, eglSourceDir/"wayland-egl-core.h"],
    `out`: `outDir/gen/includes`/"egl.nim",
    dynlib: "libwayland-egl.so",
    postprocess: postprocess,
    skipcomments: true, skipinclude: true, stdints: true, importc: true,
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
  shell.exec("../bin/wayland-nim-scanner", args.flags.toSeq.mapIt($it) & @[args.`in`, "--outdir:" & args.`out`] & args.requires.mapIt("--require:" & it))

removeDir "../src/wayland/native/gen"
removeDir "../src/wayland/protocols"

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