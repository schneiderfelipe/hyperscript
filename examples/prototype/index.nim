import macros, sugar, sets

import dom
import jsconsole


var domObjects {.compileTime.} = [
  # Stuff exported by dom
  "document",
  "createElement",
  "textContent",
  "appendChild",
].toHashSet



proc walkTree(parent: NimNode, f: (node: NimNode) -> bool) =
  if f(parent):
    for child in parent:
      walkTree(child, f)




macro once(procedure: untyped) =
  procedure.expectKind RoutineNodes

  let name = name procedure
  let params = params procedure
  let body = body procedure
  debugEcho treeRepr body

  # debugEcho treeRepr procedure

  var references: HashSet[string]

  walkTree(procedure) do (node: NimNode) -> bool:
    if node.kind in {nnkSym, nnkIdent}:
      #if node.strVal notin domObjects:
      #debugEcho repr getType node
      references.incl node.strVal

    true

  debugEcho references





when isMainModule:
  proc h {.once.} =
    let app = document.createElement("div")
    app.textContent = "Hello world"
    document.body.appendChild(app)

  h()
