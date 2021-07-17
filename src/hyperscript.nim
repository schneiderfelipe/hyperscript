import macros
import sequtils
import strformat
import xmltree

func addStringChild(el: XmlNode, child: NimNode) =
  child.expectKind nnkStrLit
  debugEcho "Got child: ", repr child

func addAttr(el: XmlNode, attr: NimNode) =
  attr.expectKind {nnkExprEqExpr, nnkExprColonExpr}
  debugEcho "Got attribute: ", repr attr

func addCallChild(el: XmlNode, child: NimNode) =
  child.expectKind nnkCall
  child[0].expectKind {nnkIdent, nnkSym}
  if child[0].strVal != "h":
    raise newException(ValueError, "unsupported call child: " & repr child)
  debugEcho "Got child: ", repr child

func addChild(el: XmlNode, child: NimNode) =
  case child.kind:
  of nnkCall:
    el.addCallChild(child)
  of nnkStrLit:
    el.addStringChild(child)
  else:
    raise newException(ValueError, "unsupported child kind: " & $child.kind)

func addChildren(el: XmlNode, chilren: NimNode) =
  chilren.expectKind {nnkBracket, nnkPar}
  for child in chilren:
    el.addChild(child)

func addAttrs(el: XmlNode, attrs: NimNode) =
  attrs.expectKind {nnkCurly, nnkTableConstr}
  for attr in attrs:
    el.addAttr(attr)

func addParam(el: XmlNode, param: NimNode) =
  case param.kind:
  of nnkBracket, nnkPar:
    el.addChildren(param)
  of nnkCall, nnkStrLit:
    el.addChild(param)
  of nnkCurly, nnkTableConstr:
    el.addAttrs(param)
  of nnkExprEqExpr, nnkExprColonExpr:
    el.addAttr(param)
  else:
    raise newException(ValueError, "unsupported parameter kind: " & $param.kind)

func tag(name: NimNode): XmlNode =
  case name.kind:
  of nnkStrLit:
    result = newElement(name.strVal)
  of {nnkIdent, nnkSym}:
    result = newElement(&"{{{name.strVal}}}")
  else:
    raise newException(ValueError, "unsupported tag kind: " & $name.kind)

func hxml(xs: varargs[NimNode]): XmlNode =
  result = tag(xs[0])
  for x in xs[1..^1]:
    result.addParam(x)

macro h(xs: varargs[untyped]): untyped =
  let el = hxml(xs.toSeq)
  debugEcho el

when isMainModule:
  h("div", "Hello", "World")

  let name0 = "div"
  h(name0, "Hello", "World")
