{.experimental: "dotOperators".}
import std/[os, osproc, strtabs, terminal]

type ShellEnv* = object
  pwd*: string = "."
  result*: int
  `out`*: string

proc exec*(shell: ShellEnv; command: string;
          args: openArray[string] = []; env: StringTableRef = nil;
          options: set[ProcessOption] = {poStdErrToStdOut, poUsePath}): ShellEnv =
  result = shell
  if result.result != 0: return
  if stdout.getFileHandle == 1: # console
    stdout.styledWrite fgBlue, expandFilename(shell.pwd), fgDefault, "$ "
  else:
    stdout.write expandFilename(shell.pwd), "$ "
  let process = startProcess(command, result.pwd, args, env, options + {poEchoCmd})
  for line in process.lines:
    result.out.add line
    result.out.add "\n"
    echo line
  result.result = process.peekExitCode

proc exec*(command: string;
          args: openArray[string] = []; env: StringTableRef = nil;
          options: set[ProcessOption] = {poStdErrToStdOut, poUsePath}): ShellEnv {.discardable.} =
  ShellEnv().exec(command, args, env, options)

template `.`*(shell: ShellEnv; command: untyped; args: varargs[string]): ShellEnv =
  shell.exec(astToStr command, args)

proc cd*(path: string): ShellEnv = ShellEnv(pwd: path)
proc cd*(shell: ShellEnv; path: string): ShellEnv =
  result = shell
  if path.isAbsolute:
    result.pwd = path
  else:
    result.pwd = result.pwd/path
