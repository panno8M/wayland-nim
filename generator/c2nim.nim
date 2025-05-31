import std/[os, pegs]
import shell

type C2NimArgs* = object
  `in`*: seq[string]
  `out`*: string
  preprocess*, postprocess*: proc(contents: string): string
  strict*: bool
  cpp*: bool
  dynlib*: string
  header*: string
  cdecl*: bool
  noconv*: bool
  stdcall*: bool
  importc*: bool
  importDefines*: bool
  importFuncDefines*: bool
  def*: seq[string]
  reorderComments*: bool
  `ref`*: bool
  prefix*: seq[string]
  suffix*: seq[string]
  mangle*: seq[tuple[pattern, frmt: string]]
  stdints*: bool
  paramPrefix*: string
  assumeDef*: seq[string]
  assumeNdef*: seq[string]
  skipInclude*: bool
  typePrefixes*: bool
  nep1*: bool
  skipComments*: bool
  ignoreRValueRefs*: bool
  keepBodies*: bool
  debug*: bool
  exportdll*: string

proc c2nim*(shell: ShellEnv; args: C2NimArgs): ShellEnv =
  var a = args.in
  if args.preprocess != nil:
    for i, ain in args.in:
      a[i] = "tmp"/ain
      createDir a[i].splitFile.dir
      a[i].writeFile args.preprocess(readFile(ain))

  createDir args.out.parentDir
  a.add "--out:" & args.out
  a.add "--concat"
  if args.strict:
    a.add "--strict"
  if args.cpp:
    a.add "--cpp"
  if args.dynlib.len != 0:
    a.add "--dynlib:\"" & args.dynlib & "\""
  if args.header.len != 0:
    a.add "--header:\"" & args.header & "\""
  if args.cdecl:
    a.add "--cdecl"
  if args.noconv:
    a.add "--noconv"
  if args.stdcall:
    a.add "--stdcall"
  if args.importc:
    a.add "--importc"
  if args.importDefines:
    a.add "--importdefines"
  if args.importFuncDefines:
    a.add "--importfuncdefines"
  for def in args.def:
    a.add "--def:" & def
  if args.reorderComments:
    a.add "--reordercomments"
  if args.ref:
    a.add "--ref"
  for prefix in args.prefix:
    a.add "--prefix:" & prefix
  for suffix in args.suffix:
    a.add "--suffix:" & suffix
  for mangle in args.mangle:
    a.add "--mangle:" & mangle.pattern & "=" & mangle.frmt
  if args.stdints:
    a.add "--stdints"
  if args.paramPrefix.len != 0:
    a.add "--paramprefix:" & args.paramPrefix
  for assumeDef in args.assumeDef:
    a.add "--assumedef:" & assumeDef
  for assumeNdef in args.assumeNdef:
    a.add "--assumendef:" & assumeNdef
  if args.skipInclude:
    a.add "--skipinclude"
  if args.typePrefixes:
    a.add "--typeprefixes"
  if args.nep1:
    a.add "--nep1"
  if args.skipComments:
    a.add "--skipcomments"
  if args.ignoreRValueRefs:
    a.add "--ignoreRValueRefs"
  if args.keepBodies:
    a.add "--keepBodies"
  if args.debug:
    a.add "--debug"
  if args.exportdll.len != 0:
    a.add "--exportdll:" & args.exportdll
  result = shell.exec("c2nim", a)
  args.out.writeFile args.postprocess(readFile(args.out))
  removeDir "tmp"
