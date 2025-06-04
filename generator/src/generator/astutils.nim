import std/[pegs]
import "$nim"/compiler/[ast, idents, lineinfos]
export ast

proc ident*(name: string): PNode = newIdentNode(PIdent(s: name), TLineInfo())

proc margeSection*(ast: PNode; sectionKind: TNodeKind): PNode {.discardable.} =
  assert ast.kind == nkStmtList
  var section: PNode
  var willDelete: seq[int]
  for i, stmt in ast:
    if stmt.kind == sectionKind:
      if section == nil:
        section = stmt
      else:
        willDelete.add i
        section.sons.add stmt.sons
  for i in countdown(ast.sons.high, 0):
    if i in willDelete:
      ast.delSon(i)
  result = ast

type NodeIter = object
  root: PNode
  path: seq[int]
  route: seq[PNode]
  `end`: bool

proc next(iter: var NodeIter): PNode =
  if iter.end:
    result = nil
  elif iter.path.len == 0:
    result = iter.root
    if result.len != 0:
      iter.path.add 0
      iter.route.add iter.root[0]
  else:
    result = iter.route[^1]
    # Update path
    if not result.isAtom and result.len != 0:
      iter.path.add 0
      iter.route.add iter.route[^1][0]
    else:
      while true:
        case iter.path.len
        of 0:
          break
        of 1:
          if iter.path[0] >= iter.root.sons.high:
            discard pop iter.path
            discard pop iter.route
          else:
            break
        else:
          if iter.path[^1] >= iter.route[^2].sons.high:
            discard pop iter.path
            discard pop iter.route
          else:
            break
      case iter.path.len
      of 0:
        iter.end = true
      of 1:
        inc iter.path[0]
        iter.route[^1] = iter.root[iter.path[0]]
      else:
        inc iter.path[^1]
        iter.route[^1] = iter.route[^2][iter.path[^1]]

iterator walk*(ast: PNode): PNode =
  var iter = NodeIter(root: ast)
  while not iter.end:
    yield iter.next

iterator collect*(ast: PNode; kind: TNodeKind): PNode =
  for node in ast.walk:
    if node.kind == kind:
      yield node

proc map*(ast: PNode; pred: proc(ast: Pnode): Pnode; applySelf: bool = true): Pnode =
  if applySelf:
    result = pred(ast)
  else:
    result = ast
  if not result.isAtom:
    for node in result.sons.mitems:
      node = pred(node).map(pred, false)

proc filter*(ast: PNode; pred: proc(ast: Pnode): bool; applySelf: bool = true): Pnode =
  if applySelf and not pred(ast):
    result = nil
  else:
    result = ast
  if not result.isAtom:
    var i: int
    while i < result.sons.len:
      if pred(result[i]):
        result[i] = result[i].filter(pred, false)
        inc i
      else:
        result.delSon(i)

proc mangle*(ast: PNode; rules: seq[(Peg, string)]): PNode {.discardable.} =
  proc apply(ast: PNode): PNode =
    result = ast
    if ast.kind == nkIdent:
      for (pattern, frmt) in rules:
        if ast.ident.s.match(pattern):
          result = newIdentNode(PIdent(s: result.ident.s.replacef(pattern, frmt)), result.info)
  ast.map apply

proc removeProcs*(ast: PNode; procnames: seq[string], filter = {nkProcDef, nkFuncDef, nkTemplateDef, nkMacroDef, nkMethodDef, nkIteratorDef}): PNode {.discardable.} =
  ast
    .filter((proc (ast: PNode): bool =
      if ast.kind in filter:
        var ident = ast[0]
        case ident.kind
        of nkPostfix:
          ident = ident[1]
        else: discard
        ident.ident.s notin procnames
      else:
        true),
      false)