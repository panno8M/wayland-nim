import std/parseopt
import std/tables
import std/options
import std/[xmlparser, xmltree]
import std/logging
import std/strformat
import std/strutils
import std/sequtils
import std/os

import beyond/meta/[
  statements,
  statements/nimkit,
]

const LogDir {.strdefine.} = "log"
let AppName = getAppFileName().splitFile.name
let LogFileName = AppName & ".log"
let LogPath = LogDir/LogFileName

createDir LogDir

logging.addHandler newConsoleLogger()
logging.addHandler newFileLogger(LogPath, fmWrite, fmtstr= verboseFmtStr)

const type_protocol_to_nim = toTable {
  "new_id": "uint32",
    "uint": "uint32",
     "int": "int32",
  "string": "cstring",
   "array": "ptr WlArray",
  "object": "ptr WlResource",
}

type CmdOptionKind {.pure.} = enum
  coHelp
type CmdOption = object
  kind: CmdOptionKind
  short: string
  long: string
  desc: string
proc parse_help(opts: openArray[CmdOption]): ParagraphSt =
  result = ParagraphSt()
  var msgs = newSeq[string](opts.len)
  var longest_len = 0
  for i, opt in opts:
    var msg: string
    if opt.short != "":
      msg &= "-" & opt.short
      if opt.long != "":
        msg &= ",  "
    if opt.long != "":
      msg &= "--" & opt.long
    msgs[i] = msg
    longest_len = max(longest_len, msg.len)
  for i, msg in msgs.mpairs:
    msg &= " ".repeat(longest_len - msg.len)
    msg &= "  " & opts[i].desc
    discard result.add msg

const cmdopts = [
  CmdOption(kind: coHelp, short: "h", long: "help", desc: "display this help and exit.")
]

const sub_commands = [
  "server-header"
]
type SubCommands = enum
  Help
  ServerHeader = "server-header"

type Config = ref object
  subCommand: SubCommands
  inputFilePath: string
  outputFilePath: string

type Data = ref object
  cfg: Config

  inputFile: File
  inputXml: XmlNode

  outputFile: File

proc configure(): Config =
  result = new Config
  var argstage = 0
  var p = initOptParser()
  defer:
    discard "Nothing to do now"
  while true:
    p.next()
    case p.kind
    of cmdEnd: return
    of cmdShortOption:
      case argstage
      of 0:
        let opts = cmdopts.filterIt(p.key == it.short)
        if opts.len == 0: continue
        let opt = opts[0]
        case opt.kind
        of coHelp: return

      else: return
    of cmdArgument:
      case argstage
      of 0:
        for i, subs in sub_commands:
          if p.key != subs: continue
          result.subCommand = SubCommands(i+1)
          inc argstage
          break
      of 1:
        result.inputFilePath = p.key
        inc argstage
      of 2:
        result.outputFilePath = p.key
        inc argstage
      else: return
    else: return
proc init(cfg: Config): Data =
  result = new Data
  result.inputFile = open(cfg.inputFilePath)
  result.inputXml = loadXml(cfg.inputFilePath)
  result.outputFile = open(cfg.outputFilePath, fmWrite)

type ConfigEnum = object
  prefix: string
proc make_statement_from_enum(node: XmlNode, cfg: ConfigEnum): BlockSt =
  assert node.tag == "enum"
  result = BlockSt(head: fmt"""type {cfg.prefix}{node.attr("name")}* = enum""")
  for child in node:
    case child.tag
    of "description":
      result.children.add CommentSt.nimDoc(execute= true).add child.innertext
    of "entry":
      result.children.add fmt"""{child.attr("name")} = {child.attr("value")}"""
    else:
      error "Unexpected tag has found: \"", child.tag, "\""



proc make_statement_from_request(node: XmlNode): ParagraphSt =
  assert node.tag == "request"
  new result
  var args : seq[NimIdentDef] = @[idef("client", "ptr WlClient")]
  for child in node:
    case child.tag
    of "description":
      result.children.add CommentSt.nimDoc(execute= true).add child.innertext
    of "arg":
      args.add idef(child.attr("name"), type_protocol_to_nim[child.attr("type")])
    else:
      error "Unexpected tag has found: \"", child.tag, "\""
  let strargs = args.mapIt($it).join("; ")

  result.children.add fmt"""{node.attr("name")}*: proc({strargs})"""

type ConfigEvent = object
  prefix: string
  id: Natural
proc make_statement_from_event(node: XmlNode; cfg: ConfigEvent): NimProcSt =
  assert node.tag == "event"
  var args: seq[NimIdentDef] = @[idef("resource", "ptr WlResource")]
  var desc: Statement
  for child in node:
    case child.tag
    of "description":
      desc = CommentSt.nimDoc(execute= true).add child.innertext
    of "arg":
      args.add idef(child.attr("name"), type_protocol_to_nim[child.attr("type")])
    else:
      error "Unexpected tag has found: \"", child.tag, "\""
  let strpass = @["recource", $cfg.id].concat(args[1..^1].mapIt(it.name)).join(", ")

  result = NimProcSt(
    kind: npkProc,
    flags: {npfExport},
    name: some cfg.prefix&node.attr("name"),
    args: args)
  result.children.add desc
  result.children.add fmt"wayland.post_event({strpass})"

proc process_interface(node: XmlNode): Statement =
  assert node.tag == "interface"
  debug node.attr("name")&"..."

  var desc: Statement
  var objdef = ParagraphSt()
  var events = ParagraphSt()
  var enums = ParagraphSt()

  var eventid = 0

  for child in node:
    case child.kind
    of xnComment, xnText:
      discard
    else:
      case child.tag
      of "description":
        desc = text child.innertext
      of "enum":
        discard enums.add make_statement_from_enum(child, ConfigEnum(prefix: node.attr("name") & "_"))
      of "request":
        discard objdef.add make_statement_from_request(child)
      of "event":
        discard events.add make_statement_from_event(child, ConfigEvent(prefix: node.attr("name") & "_send_", id: eventid))
        inc eventid
      else:
        debug child.tag

  result = +$$..ParagraphSt():
    +$$..CommentSt.nim(execute= true):
      +$$..UnderlineSt(style: "-"):
        node.attr("name")
    +$$..CommentSt.nimDoc(execute= true):
      desc
    enums
    +$$..BlockSt(head: fmt"""type {node.attr("name")}_interface* = object"""):
      objdef
    events

  debug node.attr("name")&" [OK]"


proc process(data: Data): Statement =
  let interfaces = ParagraphSt()
  let copyright = ParagraphSt()
  for child in data.inputXml:
    case child.kind
    of xnComment, xnText:
      discard
    else:
      case child.tag
      of "interface":
        discard interfaces.addBody:
          ""
          process_interface(child)
      of "copyright":
        discard copyright.add child.innertext
      else:
        error "Unexpected tag has found: \"", child.tag, "\""
  +$$..ParagraphSt():
    +$$..CommentSt.nimDoc(execute= true):
      copyright
    "import wayland"
    interfaces

proc help : string =
  let name = getAppFileName().splitFile.name
  `$` do:
    +$$..ParagraphSt():
      fmt"""usage: {name} [OPTION] [{sub_commands.join("|")}] [input_file output_file]"""
      +$$..BlockSt(head: "options:", indentLevel: 4):
        cmdopts.parse_help()

when isMainModule:
  let cfg = configure()
  if cfg.subCommand == SubCommands.Help:
    echo help()
    quit()
  let data = init(cfg)

  data.outputFile.write data.process.render( RenderingConfig(
    ignoreComment: NimDocComment # + NimComment
  )).join("\n")