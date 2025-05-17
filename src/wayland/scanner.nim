import std/[strformat, xmlparser, xmltree, strutils, sequtils, parseutils, streams, deques, parseopt, algorithm, os]
import macros

import native/gen/[version]

const builtintypes = staticRead("native/common.nim")
  .splitLines
  .filterIt(it.startsWith("  ") and '*' in it and '=' in it)
  .mapIt(it.split('*')[0][2..^1])
const
  PROGRAM_NAME = "wayland-nim-scanner"

const bindingver = staticRead(getProjectPath()/"../../wayland.nimble")
  .splitLines
  .filterIt(it.startsWith "version")[0]
  .split("\"")[1]

type Opts = object
  input: File
  input_filename: string
  output_dir: string = "."
  core_headers: bool
  strict: bool
  imports: seq[string]
  exports: seq[string]

type
  Side = enum
    CLIENT, SERVER
  Integration = enum
    importc, exportc

proc usage(ret: int) =
  stderr.writeLine fmt"""
usage: {PROGRAM_NAME} [OPTION] [input_file] [OPTION]"

Converts XML protocol descriptions supplied on stdin or input file to client
headers, server headers, or protocol marshalling code.

options:
    -h,  --help                 display this help and exit.
    -v,  --version              print the wayland library version that
                                the scanner was built against.
    -c,  --include-core-only    include the core version of the headers,
                                that is e.g. wayland-client-core.h instead
                                of wayland-client.h.
    -s,  --strict               exit immediately with an error if DTD
                                verification fails.
    -o,  --outdir:DIR           specify output directory (default: $(pwd))"""
  quit(ret)

proc scanner_version(ret: int) =
  stderr.writeLine fmt"{PROGRAM_NAME} {bindingver} (libwayland {WAYLAND_VERSION})"
  quit(ret)

proc is_dtd_valid(input: File; filename: string): bool = true

type
  ParseNode = ref object of RootObj
    xml: XmlNode
    owner: ParseNode
    since: int
    deprecated_since: int = int.high
    since_overridden: bool
    deprecated_since_overridden: bool

  Description = ref object of ParseNode
    summary: string
    text: string

  Protocol = ref object of ParseNode
    name: string
    interfaces: seq[Interface]
    type_index: int
    null_run_length: int
    copyright: string
    description: Description
    core_headers: bool

  Interface = ref object of ParseNode
    name: string
    version: int
    requests: seq[Message]
    events: seq[Message]
    enumerations: seq[Enumeration]
    description: Description

  Message = ref object of ParseNode
    name: string
    args: seq[Arg]
    new_id_count: int
    type_index: int
    all_null: bool
    destructor: bool
    description: Description

  ArgType = enum
    NEW_ID, INT, UNSIGNED, FIXED, STRING, OBJECT, ARRAY, FD


  Arg = ref object of ParseNode
    name: string
    `type`: ArgType
    nullable: bool
    interface_name: string
    summary: string
    enumeration_name: string

  Enumeration = ref object of ParseNode
    name: string
    entries: seq[Entry]
    description: Description
    bitfield: bool

  Entry = ref object of ParseNode
    name: string
    value: string
    summary: string
    description: Description

  IdentifierRole = enum
    STANDALONE_IDENT, TRAILING_IDENT

  RPragma = distinct string
  RVarName = distinct string
  RTypeName = distinct string
  RType = object
    name: RTypeName
    isPtr: bool
  RFuncName = distinct string
  RArg = object
    name: RVarName
    `type`: RType
    default: string
  RFunction = ref object
    name: RFuncName
    args: seq[RArg]
    result: RType
    pragmas: seq[RPragma]
    body: string
    description: Description

proc fail(msg: varargs[string, `$`]) =
  stderr.writeLine @[": error: "] & @msg
  quit QuitFailure

proc warn(msg: varargs[string, `$`]) =
  stderr.writeLine @[": warning: "] & @msg

proc `or`(a, b: string): string =
  if a.len == 0:
    b
  else:
    a

proc `and`(a, b: string): string =
  if a.len == 0:
    a
  else:
    b

template `.?`[T](a: ptr T | ref T; b: untyped): untyped =
  if a.isNil:
    default(typeof(a.b))
  else:
    a.b

iterator pairwise[T](arr: openArray[T]): tuple[prev, next: T] =
  for i, v in arr:
    if i == 0: continue
    yield (arr[i.pred], v)

proc h1(s: string): string =
  s & "\n" & "#".repeat(s.len)

proc erase(str: string; target: string): string {.inline.} = str.replace(target, "")
proc quoted(w: string): string = "`" & w.erase("`") & "`"

const keywords = [
  "addr", "and", "as", "asm", "bind", "block", "break", "case", "cast", "concept",
  "const", "continue", "converter", "defer", "discard", "distinct", "div", "do",
  "elif", "else", "end", "enum", "except", "export", "finally", "for", "from",
  "func", "if", "import", "in", "include", "interface", "is", "isnot", "iterator",
  "let", "macro", "method", "mixin", "mod", "nil", "not", "notin", "object", "of",
  "or", "out", "proc", "ptr", "raise", "ref", "return", "shl", "shr", "static",
  "template", "try", "tuple", "type", "using", "var", "when", "while", "xor", "yield",
]
proc escapeVariable(w: string): string =
  if w in keywords:
    result = quoted w
  else:
    result = w
    for c in w:
      if c notin {'a'..'z', 'A'..'Z', '0'..'9', '_'}:
        result = quoted w
        break

proc unquote(w: string): string = w.replace("`", "")

proc identify(w: string): string =
  result = newStringOfCap(w.len)

  var needsLarge: bool
  for c in w.replace("wl_", "").parseIdent:
    case c
    of '_':
      needsLarge = true
    else:
      if needsLarge:
        result.add c.toUpperAscii
        needsLarge = false
      else:
        result.add c

  result = escapeVariable result

proc typify(w: string): string =
  if w in ["int", "uint32", "int32", "cstring", "pointer"]:
    w
  else:
    w.identify.unquote.capitalizeAscii

proc doccomment(str: string): string =
  str.unindent.splitLines.mapIt("## " & it).join("\n")

proc `$`(desc: Description): string =
  if desc.summary.len != 0:
    result.add desc.summary
  if desc.text.len != 0:
    if desc.summary.len != 0:
      result.add "\n\n"
    result.add unindent desc.text

proc `$`(self: RFuncName): string = string(self).identify
proc `$`(self: RVarName): string = string(self).identify
proc `$`(self: RTypeName): string = string(self).typify
proc `$`(self: RType): string =
  if self.isPtr: result.add "ptr "
  result.add $self.name
proc `$`(self: RArg): string =
  let (name, `type`, default) = ($self.name, $self.type, self.default)
  if `type`.len == 0 and default.len == 0:
    raise newException(CatchableError, "failed to render RArg; both type and default is empty")
  case name
  of "": result.add "_"
  else: result.add name
  case `type`
  of "": discard
  else:
    result.add ": "
    result.add `type`
  case default
  of "": discard
  else:
    result.add " = "
    result.add default
proc `$`(self: seq[RArg]): string =
  for i, a in self:
    if i != 0: result.add "; "
    result.add $a
proc `$`(self: RPragma): string = string(self)
proc `$`(self: seq[RPragma]): string =
  if self.len == 0: return
  result.add "{."
  for i, p in self:
    if i != 0: result.add ", "
    result.add $p
  result.add ".}"
proc `$`(self: RFunction): string =
  let (ret,) = ($self.result,)
  result.add "proc "
  result.add $self.name
  result.add "*"
  if self.args.len != 0:
    result.add "("
    result.add $self.args
    result.add ")"
  if ret.len != 0:
    result.add ": "
    result.add ret
  if self.pragmas.len != 0:
    result.add " "
    result.add $self.pragmas
  if self.body.len != 0:
    result.add " =\n"
  if self.description != nil:
    result.add indent(doccomment $self.description, 2)

  if self.body.len != 0:
    if self.description != nil:
      result.add "\n"
    result.add indent(self.body, 2)
    # result.add "\n"

proc call(name: string; args: varargs[string]): string =
  result.add name
  result.add "("
  for i, a in args:
    if i != 0: result.add ", "
    result.add a
  result.add ")"
proc call(name: RFuncName; args: openArray[RArg]): string =
  call($name, args.mapIt($it.name))

proc `type`(name: string): RType = RType(name: RTypeName name)
proc `ptr`(typ: RType): RType =
  result = typ
  result.isPtr = true
proc `ptr`(name: string): RType = RType(name: RTypeName name, isPtr: true)

proc arg(name: string; `type`: RType): RArg =
  RArg(name: RVarName name, `type`: `type`)
proc arg(name, `type`: string): RArg =
  arg(name, type(`type`))
proc arg(a: Arg): RArg =
  arg(a.name, case a.`type`
    of INT, FD:
      "int32".type
    of NEW_ID, UNSIGNED:
      "uint32".type
    of FIXED:
      "Fixed".type
    of STRING:
      "cstring".type
    of OBJECT:
      a.interface_name.ptr
    of ARRAY:
      "Array".ptr)

proc function(name: RFuncName; args: openArray[Rarg]; ret: string; pragmas: openArray[string]; body: string): RFunction =
  RFunction(
    name: name,
    args: @args,
    result: type ret,
    pragmas: @pragmas.mapIt(RPragma it),
    body: body,
  )
proc function(name: string; args: openArray[Rarg]; ret: string; pragmas: openArray[string]; body: string): RFunction =
  function(RFuncName name, args, ret, pragmas, body)
proc function(ifce: Interface; name: string; args: openArray[Rarg]; ret: string; pragmas: openArray[string]; body: string): RFunction =
  function(RFuncName name,
  @[arg(ifce.name, ifce.name.ptr)] & @args, ret,
  pragmas, body)

proc expectKind(node: XmlNode; kind: XmlNodeKind) =
  if node.kind != kind:
    raise newException(CatchableError, fmt"""
unexpected kind; {kind} is expected, but got {node.kind}
{node}
""")

proc expectTag(node: XmlNode; tag: string) =
  if node.tag != tag:
    raise newException(CatchableError, fmt"""
unexpected tag; {tag} is expected, but got {node.tag}
{node}
""")

proc expectAttrs(node: XmlNode; attrs: varargs[string]) =
  var missing: seq[string]
  for attr in attrs:
    if node.attr(attr) == "":
      missing.add attr
  if missing.len != 0:
    raise newException(CatchableError, fmt"""
unexpected attrs; {attrs} is expected, but lacks {missing}
{node}
""")

proc validate_identifier(str: string; role: IdentifierRole) =
  case role
  of STANDALONE_IDENT:
    if parseIdent(str) == "":
      fail &"'{str}' is not a valid standalone identifier"
  of TRAILING_IDENT:
    if parseIdent("dummy" & str) == "dummy":
      fail &"'{str}' is not a valid trailing identifier part"

proc name(node: XmlNode): string = node.attr"name"
proc version(node: XmlNode): int =
  let ver = node.attr"version"
  try:
    result = parseInt(ver)
  except ValueError:
    fail &"wrong version ({ver})"
proc `type`(node: XmlNode): ArgType =
  let typ = node.attr"type"
  case typ
  of "int":
    INT
  of "uint":
    UNSIGNED
  of "fixed":
    FIXED
  of "string":
    STRING
  of "array":
    ARRAY
  of "fd":
    FD
  of "new_id":
    NEW_ID
  of "object":
    OBJECT
  else:
    fail fmt"unknown type ({typ})"
    result
proc value(node: XmlNode): string = node.attr"value"
proc `interface`(node: XmlNode): string = node.attr"interface"
proc summary(node: XmlNode): string = node.attr"summary"
proc since(node: XmlNode; value: var int): bool =
  let attr = node.attr"since"
  if attr.len == 0:
    return false
  try:
    value = parseInt(attr)
    return true
  except ValueError:
    fail &"invalid integer ({value})"
proc setSince(node: ParseNode): int {.discardable.} =
  if node.since == 0:
    if node of Protocol:
      node.since = 1
    elif node.xml.since node.since:
      node.since_overridden = true
    else:
      node.since = node.owner.setSince
  node.since
proc deprecatedSince(node: XmlNode; value: var int): bool =
  let attr = node.attr"deprecated-since"
  if attr.len == 0:
    return false
  try:
    value = parseInt(attr)
    return true
  except ValueError:
    fail &"invalid integer ({value})"
proc setDeprecatedSince(node: ParseNode): int {.discardable.} =
  if node.deprecatedSince == int.high:
    if node of Protocol:
      node.deprecatedSince = 0
    elif node.xml.deprecatedSince node.deprecatedSince:
      node.deprecatedSince_overridden = true
    else:
      node.deprecatedSince = node.owner.setDeprecatedSince
  node.deprecatedSince
proc allowNull(node: XmlNode): bool =
  parseBool(node.attr"allow-null" or "false")
proc `enum`(node: XmlNode): string = node.attr"enum"
proc bitfield(node: XmlNode): bool = parseBool(node.attr"bitfield" or "false")

proc find(node: XmlNode; kind: XmlNodeKind): XmlNode =
  for child in node:
    if child.kind == kind:
      return child
proc find(node: XmlNode; tag: string): XmlNode =
  for child in node:
    if child.tag == tag:
      return child

proc isNullable(arg: Arg): bool = arg.type in {STRING, OBJECT}

proc find_enumeration(protocol: Protocol; ifce: Interface;
                      enum_attribute: string): Enumeration =
  let dot = enum_attribute.rfind('.')
  let enum_name =
    if dot == -1: enum_attribute
    else: enum_attribute[dot.succ..^1]
  let ifce_name =
    if dot == -1: ""
    else: enum_attribute[0..<dot]

  if dot != -1:
    for ifce in protocol.interfaces:
      if ifce.name == ifce_name:
        for enu in ifce.enumerations:
          if enu.name == enum_name:
            return enu
  else:
    for enu in ifce.enumerations:
      if enu.name == enum_name:
        return enu

proc verify_arguments(protocol: Protocol; ifce: Interface;
                      messages: seq[Message]; enumerations: seq[Enumeration]) =
  for message in messages:
    for arg in message.args:
      if arg.enumeration_name.len == 0:
        continue
      let enu = protocol.find_enumeration(ifce, arg.enumeration_name)
      case arg.type
      of INT:
        if enu != nil and enu.bitfield:
          fail "bitfield-style enum must only be referenced by uint"
      of UNSIGNED:
        discard
      else:
        fail "enumeration-style argument has wrong type"

proc parseArg(node: XmlNode; owner: ParseNode): Arg =
  const `type` = "type"
  node.expectAttrs "name"
  result = Arg(
    xml: node,
    owner: owner,
    name: node.name,
    summary: node.summary,
    nullable: node.allowNull,
    enumeration_name: node.enum,
    interface_name: node.interface,
    `type`: node.type,
  )
  if result.interface_name.len != 0:
    validateIdentifier(result.interface_name, STANDALONE_IDENT)
    if result.type notin {NEW_ID, OBJECT}:
      fail &"interface attribute not allowed for type {result.type}"
  if result.nullable and not result.isNullable:
    fail "allow-null is only valid for objects, strings, and arrays"

proc parseCopyright(node: XmlNode; owner: ParseNode): string =
  if node == nil: return
  node.expectKind xnElement
  node.expectTag "copyright"
  node.find(xnText).?text

proc parseDescription(node: XmlNode; owner: ParseNode): Description =
  if node == nil: return
  node.expectKind xnElement
  node.expectTag "description"
  Description(
    xml: node,
    owner: owner,
    summary: node.summary,
    text: node.find(xnText).?text,
  )

proc parseEntry(node: XmlNode; owner: ParseNode): Entry =
  if node == nil: return
  node.expectAttrs "name"
  result = Entry(
    xml: node,
    owner: owner,
    name: node.name,
    summary: node.summary,
    value: node.value,
  )
  validateIdentifier(result.name, TRAILING_IDENT)
  result.setSince
  result.setDeprecatedSince
  result.description = node.find"description".parseDescription(result)

proc parseEnumeration(node: XmlNode; owner: ParseNode): Enumeration =
  if node == nil: return
  node.expectAttrs "name"
  result = Enumeration(
    xml: node,
    owner: owner,
    name: node.name,
    bitfield: node.bitfield,
  )
  validateIdentifier(result.name, TRAILING_IDENT)
  result.description = node.find"description".parseDescription(result)
  for entrynode in node.findAll("entry"):
    let entry = entrynode.parseEntry(result)
    result.entries.add entry
  if result.entries.len == 0:
    fail &"enumeration {result.name} was empty"

proc parseMessage(node: XmlNode; owner: ParseNode): Message =
  if node == nil: return
  node.expectAttrs "name"
  result = Message(
    xml: node,
    owner: owner,
    name: node.name,
    destructor: node.attr"type" == "destructor",
    all_null: true,
  )
  validateIdentifier(result.name, STANDALONE_IDENT)
  result.setSince
  result.setDeprecatedSince
  result.description = node.find"description".parseDescription(result)
  for argnode in node.findAll("arg"):
    let arg = argnode.parseArg(result)
    result.args.add arg
    if arg.type == NEW_ID:
      inc result.new_id_count
    if arg.type in {NEW_ID, OBJECT} and arg.interface_name.len != 0:
      result.all_null = false
  if result.name == "destroy" and not result.destructor:
    fail "destroy request should be destructor type"

proc parseInterface(node: XmlNode; owner: ParseNode): Interface =
  if node == nil: return
  node.expectAttrs "name", "version"
  result = Interface(
    xml: node,
    owner: owner,
    name: node.name,
    version: node.version,
  )
  validateIdentifier(result.name, STANDALONE_IDENT)
  result.description = node.find"description".parseDescription(result)
  for requestnode in node.findAll("request"):
    let request = requestnode.parseMessage(result)
    result.requests.add request
  for eventnode in node.findAll("event"):
    let event = eventnode.parseMessage(result)
    result.events.add event
  for enumerationnode in node.findAll("enum"):
    let enumeration = enumerationnode.parseEnumeration(result)
    result.enumerations.add enumeration

proc parseProtocol(node: XmlNode): Protocol =
  if node == nil: return
  node.expectTag "protocol"
  node.expectAttrs "name"
  result = Protocol(
    xml: node,
    name: node.name,
  )
  validateIdentifier(result.name, STANDALONE_IDENT)
  result.description = node.find"description".parseDescription(result)
  result.copyright = node.find"copyright".parseCopyright(result)
  for ifcenode in node.findAll("interface"):
    let ifce = ifcenode.parseInterface(result)
    verify_arguments(result, ifce, ifce.requests, ifce.enumerations)
    verify_arguments(result, ifce, ifce.events, ifce.enumerations)
    result.interfaces.add ifce
    for request in ifce.requests:
      if request.all_null and result.null_run_length < request.args.len:
        result.null_run_length = request.args.len
    for event in ifce.events:
      if event.all_null and result.null_run_length < event.args.len:
        result.null_run_length = event.args.len

proc opcode(ifce: Interface; message: Message; suffix: string): string =
  let enumname = typify &"{ifce.name}_{suffix}"
  &"{enumname}_{message.name}"

proc write_opcodes(messages: seq[Message]; ifce: Interface; suffix: string) =
  if messages.len == 0: return
  let enumname = typify &"{ifce.name}_{suffix}"
  echo fmt"""
type {enumname}* {{.size: sizeof(uint32).}} = enum"""
  for message in messages:
    echo "  ", opcode(ifce, message, suffix)

  var f = function("since", [arg("e", enumname)], "int", [],
    "case e")
  for message in messages:
    f.body.add &"\nof {enumname}_{message.name}: {message.since}"
  echo f, "\n"

proc write_type(a: Arg) =
  case a.`type`
  of INT, FD:
    stdout.write("int32")
  of NEW_ID, UNSIGNED:
    stdout.write("uint32")
  of FIXED:
    stdout.write("Fixed")
  of STRING:
    stdout.write("cstring")
  of OBJECT:
    stdout.write(fmt"ptr {a.interface_name.typify}")
  of ARRAY:
    stdout.write("ptr Array")

proc write_stubs(messages: seq[Message]; ifce: Interface) =
  var
    ret: Arg
  var
    has_destructor: bool
    has_destroy: bool

  echo ifce.function("set_user_data",
    [arg("user_data", "pointer")], "", ["inline"],
    &"cast[ptr Proxy]({ifce.name.identify}).set_user_data(user_data)")

  echo ifce.function("get_user_data",
    [], "pointer", ["inline"],
    &"cast[ptr Proxy]({ifce.name.identify}).get_user_data()")

  echo ifce.function("get_version",
    [], "uint32", ["inline"],
    &"cast[ptr Proxy]({ifce.name.identify}).get_version()")

  for m in messages:
    if m.destructor:
      has_destructor = true
    if m.name == "destroy":
      has_destroy = true
  if not has_destructor and has_destroy:
    fail fmt"interface '{ifce.name}' has method named destroy but no destructor"
    quit(QuitFailure)
  if not has_destroy and ifce.name != "wl_display":
    echo ifce.function("destroy", [], "", ["inline"],
      &"destroy cast[ptr Proxy]({ifce.name.identify})")

  for m in messages:
    if m.new_id_count > 1:
      warn fmt"request '{ifce.name}::{m.name}' has more than one new_id arg, not writeting stub"
      continue
    ret = nil
    for a in m.args:
      if a.`type` == NEW_ID:
        ret = a
    var f = ifce.function(m.name, [], "", ["inline"], "")
    f.description= m.description
    for a in m.args:
      if a.`type` == NEW_ID and a.interface_name.len == 0:
        f.args.add [arg("interface", "Interface".ptr),
                    arg("version", "uint32")]
      elif a.`type` == NEW_ID: discard
      else: f.args.add arg(a)
    f.result = 
      if ret != nil and ret.interface_name.len == 0:
        "pointer".type
      elif ret != nil:
        ret.interface_name.ptr
      else:
        "".type

    var callargs: seq[string]
    callargs.add fmt"""{opcode(ifce, m, "request")}.ord"""
    if ret == nil:
      callargs.add "nil"
    else:
      if ret.interface_name.len == 0:
        callargs.add "`interface`"
      else:
        callargs.add &"addr {ret.interface_name}_interface"

    if ret != nil and ret.interface_name.len == 0:
      callargs.add "version"
    else:
      callargs.add &"cast[ptr Proxy]({ifce.name.identify}).get_version()"
    callargs.add if m.destructor: "WL_MARSHAL_FLAG_DESTROY" else: "0"
    for a in m.args:
      if a.`type` == NEW_ID:
        if a.interface_name.len == 0:
          callargs.add ["`interface`.name", "version"]
        callargs.add "nil"
      else:
        callargs.add a.name.identify
    if ret != nil and ret.interface_name.len != 0:
      f.body.add &"cast[ptr {ret.interface_name.typify}]("
    f.body.add fmt"cast[ptr Proxy]({ifce.name.identify}).marshal_flags".call(callargs)
    if ret != nil and ret.interface_name.len != 0:
      f.body.add ")"
    echo f

proc write_event_wrappers(messages: seq[Message]; ifce: Interface; integration: Integration) =
  ##  We provide hand written functions for the display object
  proc toarg(a: Arg): RArg =
    case a.`type`
    of NEW_ID, OBJECT:
      arg(a.name, "Resource".ptr)
    else:
      arg(a)
  if ifce.name == "Display": return
  for m in messages:
    var f = function(&"{ifce.name}_send_{m.name}",
      @[arg("resource", "Resource".ptr)] & m.args.map(toArg), "",
      ["inline", &"{integration}: \"{ifce.name}_send_{m.name}\""], "")
    f.description = Description(
      summary: &"Sends an {m.name} event to the client owning the resource.",
      text: """
  **params**:
  * *resource*: The client's resource""")
    for a in m.args:
      if a.summary.len != 0:
        f.description.text.add fmt"""

  * *{a.name}*: {a.summary}"""
    case integration
    of exportc:
      f.body = "resource.post_event".call(@[&"""{opcode ifce, m, "event"}.ord"""] & m.args.mapIt(it.name.identify))
    else:
      discard
    echo f, "\n"

proc write_enum_validator(typename: string) =
  echo fmt"""
proc isValid*(e: {typename}; version: int): bool =
  version >= e.since"""

proc write_enumerations(ifce: Interface) =
  for enu in ifce.enumerations:
    let typename = typify fmt"{ifce.name}_{enu.name}"
    echo fmt"""
type {typename}* {{.size: sizeof(uint32).}} = enum"""

    for entry in enu.entries:
      echo fmt"""
  {enu.name}_{entry.name} = {entry.value}"""
    echo fmt"""
func since*(e: {typename}): int =
  case e"""
    for entry in enu.entries:
      echo fmt"""
  of {enu.name}_{entry.name}: {entry.since}"""

    write_enum_validator(typename)
    echo ""

proc listenerNative(str: string; side: Side): string =
  str.`&` case side
    of SERVER: "_interface"
    of CLIENT: "_listener"
proc listener(str: string; side: Side): string =
  listenerNative(str, side).typify

proc write_structs(messages: seq[Message]; ifce: Interface; side: Side; integration: Integration) =
  if messages.len == 0: return
  case integration
  of importc:
    echo fmt"""
type {ifce.name.listener(side)}* {{.importc: "struct {ifce.name.listenerNative(side)}".}} = object"""
  of exportc:
    echo fmt"""
type {ifce.name.listener(side)}* = object"""

  for m in messages:
    echo fmt"""
  {m.name.identify}*: proc("""
    if side == SERVER:
      echo fmt"""
    client: ptr Client;
    resource: ptr Resource;"""
    else:
      echo fmt"""
    data: pointer;
    {ifce.name.identify}: ptr {ifce.name.typify};"""

    for a in m.args:
      if side == SERVER and a.`type` == NEW_ID and a.interface_name.len == 0:
        echo """
    ifce: cstring;
    version: uint32;"""
      stdout.write fmt"""
    {a.name.identify}: """
      if side == SERVER and a.`type` == OBJECT:
        stdout.write("ptr Resource")
      elif side == SERVER and a.`type` == NEW_ID and a.interface_name.len == 0:
        stdout.write("uint32")
      elif side == CLIENT and a.`type` == OBJECT and a.interface_name.len == 0:
        stdout.write("pointer")
      elif side == CLIENT and a.`type` == NEW_ID:
        stdout.write(&"ptr {a.interface_name.typify}")
      else:
        write_type(a)
      echo(";")

    echo "  ) {.nimcall.}"

  if side == CLIENT:
    echo ifce.function("add_listener",
      [arg("listener", ifce.name.listener(side).ptr), arg("data", "pointer")], "int",
      ["inline"],
      &"cast[ptr Proxy]({ifce.name.identify}).add_listener(listener, data)")
  echo ""

proc get_import_name(core: bool; side: Side): string =
  case side
  of SERVER:
    if core: "wayland/native/server_core"
    else: "wayland/native/server"
  of CLIENT:
    if core: "wayland/native/client_core"
    else: "wayland/native/client"

proc write_mainpage_blurb(protocol: Protocol; side: Side) =
  let title = fmt"The {protocol.name} {side} protocol"
  echo doccomment fmt"""
{h1 title}

Interfaces
==========
"""
  for ifce in protocol.interfaces:
    echo doccomment fmt"""
* {ifce.name}"""
  if protocol.copyright.len != 0:
    echo doccomment fmt"""

Copyright
=========

{unindent protocol.copyright}"""

proc cmp(a, b: Interface): int = cmp(a.name, b.name)
proc types(protocol: Protocol; messages: seq[Message]): string =
  for m in messages:
    if m.all_null:
      continue
    m.type_index = protocol.null_run_length + protocol.type_index
    protocol.type_index += m.args.len
    for a in m.args:
      case a.`type`
      of NEW_ID, OBJECT:
        if a.interface_name.len != 0:
          result.add &"  addr {a.interface_name}_interface,\n"
        else:
          result.add "  nil,\n"
      else:
        result.add "  nil,\n"

proc write_messages(name: string; messages: seq[Message];
                   ifce: Interface; suffix: string) =
  if messages.len == 0: return
  echo &"  {ifce.name}_{suffix} {{.exportc.}} = ["
  for m in messages:
    let types = &"addr {name}_types[{m.type_index}]"
    var signature: string
    if m.since > 1:
      signature.add $m.since
    for a in m.args:
      if a.isNullable and a.nullable:
        signature.add "?"
      case a.`type`
      of NEW_ID:
        if a.interface_name.len == 0:
          signature.add "su"
        signature.add "n"
      of INT:
        signature.add "i"
      of UNSIGNED:
        signature.add "u"
      of FIXED:
        signature.add "f"
      of STRING:
        signature.add "s"
      of OBJECT:
        signature.add "o"
      of ARRAY:
        signature.add "a"
      of FD:
        signature.add "h"
    echo &"    Message(name: \"{m.name}\", signature: \"{signature}\", types: {types}),"
  echo "  ]\n"

proc write_header(protocol: Protocol; side: Side; integration: Integration; opts: Opts) =
  echo &"# Generated by {PROGRAM_NAME} {WAYLAND_VERSION}"
  echo &"""
import {get_import_name(protocol.core_headers, side)}
import wayland/native/common"""
  for ipt in opts.imports:
    echo "import ", ipt
  for ept in opts.exports:
    echo "export ", ept
  echo ""

  write_mainpage_blurb(protocol, side)

  echo("")

  for ifce in protocol.interfaces:
    case side
    of SERVER:
      write_structs(ifce.requests, ifce, side, integration)
      write_event_wrappers(ifce.events, ifce, integration)
    of CLIENT:
      write_structs(ifce.events, ifce, side, integration)
      write_stubs(ifce.requests, ifce)

proc write_code(protocol: Protocol; integration: Integration; opts: Opts) =
  var typescount = protocol.null_run_length
  var types: string
  for i in protocol.interfaces:
    for m in i.requests:
      if not m.all_null:
        typescount += m.args.len
    for m in i.events:
      if not m.all_null:
        typescount += m.args.len
  types.add &"{protocol.name.identify}_types = [\n"
  for i in 0..<protocol.null_run_length:
    types.add "  nil,\n"

  for i in protocol.interfaces:
    types.add types(protocol, i.requests)
    types.add types(protocol, i.events)
  types.add "]\n\n"

  echo &"# Generated by {PROGRAM_NAME} {WAYLAND_VERSION}"
  echo "import wayland/native/common"
  for ipt in opts.imports:
    echo "import ", ipt
  for ept in opts.exports:
    echo "export ", ept
  echo ""

  echo &"var {protocol.name.identify}_types: array[{typescount}, ptr Interface]"

  let new_interfaces = protocol.interfaces.filterIt(it.name.typify notin builtintypes)
  for ifce in new_interfaces.sorted(cmp):
    echo fmt"type {ifce.name.typify}* = object"

  if new_interfaces.len != 0:
    echo ""

  echo "let"
  for i in protocol.interfaces:
    write_messages(protocol.name, i.requests, i, "requests")
    write_messages(protocol.name, i.events, i, "events")

    echo &"  {i.name}_interface* {{.exportc.}} = Interface("
    echo &"    name: \"{i.name}\","
    echo &"    version: {i.version},"
    if i.requests.len != 0:
      echo &"    method_count: {i.requests.len},"
      echo &"    methods: addr {i.name}_requests[0],"
    if i.events.len != 0:
      echo &"    event_count: {i.events.len},"
      echo &"    events: addr {i.name}_events[0],"
    echo "  )\n"

  if protocol.interfaces.len != 0:
    echo ""

  for ifce in protocol.interfaces:
    write_enumerations(ifce)

  for ifce in protocol.interfaces:
    write_opcodes(ifce.events, ifce, "event")
    write_opcodes(ifce.requests, ifce, "request")

  echo types

proc parseOptions(optparser: var OptParser; result: var Opts) =
  while true:
    case optparser.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case optparser.key.nimIdentNormalize
      of "h", "help":
        usage(QuitSuccess)
      of "v", "version":
        scanner_version(QuitSuccess)
      of "c", "include-core-only":
        result.core_headers = true
        next optparser
      of "s", "strict":
        result.strict = true
        next optparser
      of "o", "outdir":
        result.output_dir = optparser.val
        next optparser
      else:
        usage(QuitFailure)
    of cmdArgument:
      break

proc parse(optparser: var OptParser): Opts =
  result.input = stdin

  next optparser

  case optparser.kind
  of cmdEnd:
    usage(QuitFailure)
  else:
    discard

  optparser.parseOptions(result)

  case optparser.kind # Input file
  of cmdArgument:
    result.input_filename = optparser.key
    result.input = open(result.input_filename, fmRead)
    next optparser
  else:
    discard

  optparser.parseOptions(result)

proc reopen(file: File; filename: string): File {.discardable.} =
  if not file.reopen(filename, fmWrite):
    raise newException(IOError, "Could not open output file: " & filename)
  result = file

proc main() =
  var parser = initOptParser()
  var opts = parser.parse

  if not opts.input.is_dtd_valid(opts.input_filename):
    stderr.writeLine """
*******************************************************
*                                                     *
* WARNING: XML failed validation against built-in DTD *
*                                                     *
*******************************************************"""
    if opts.strict:
      quit QuitFailure

  let xml = opts.input.newFileStream.parseXml()

  let protocol = xml.parseProtocol
  protocol.core_headers = opts.core_headers

  createDir opts.output_dir
  stdout.reopen opts.output_dir/"code.nim"
  write_code(protocol, exportc, opts)
  opts.imports.add "code"
  opts.exports.add "code"
  stdout.reopen opts.output_dir/"client.nim"
  write_header(protocol, CLIENT, exportc, opts)
  stdout.reopen opts.output_dir/"server.nim"
  write_header(protocol, SERVER, exportc, opts)

when isMainModule:
  main()