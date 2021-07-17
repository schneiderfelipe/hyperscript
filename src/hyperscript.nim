import macros
import sequtils
import strformat
import strtabs
import xmltree

func hxml(xs: varargs[NimNode]): XmlNode


func getAttrKey(key: NimNode): string =
  case key.kind:
  of nnkStrLit:
    result = key.strVal
  of {nnkIdent, nnkSym}:
    result = &"{{{key.strVal}}}"
  else:
    raise newException(ValueError, "unsupported attribute key kind: " & $key.kind)
  assert len(result) > 0

func getAttrValue(value: NimNode): string =
  case value.kind:
  of nnkStrLit:
    result = value.strVal
  of {nnkIdent, nnkSym}:
    result = &"{{{value.strVal}}}"
  else:
    raise newException(ValueError, "unsupported attribute value kind: " & $value.kind)
  assert len(result) > 0

func addAttr(el: XmlNode, attr: NimNode) =
  attr.expectKind {nnkExprEqExpr, nnkExprColonExpr}
  let
    key = getAttrKey(attr[0])
    value = getAttrValue(attr[1])
  if not isNil(el.attrs):
    el.attrs[key] = value
  else:
    el.attrs = {key: value}.toXmlAttributes()
  assert not isNil(el.attrs)

func addCallChild(el: XmlNode, child: NimNode) =
  child.expectKind nnkCall
  child[0].expectKind {nnkIdent, nnkSym}
  if child[0].strVal != "h":
    raise newException(ValueError, "unsupported call child: " & repr child)
  el.add hxml(child[1..^1].toSeq)

func addChild(el: XmlNode, child: NimNode) =
  case child.kind:
  of nnkCall:
    el.addCallChild(child)
  of nnkStrLit:
    el.add newText(child.strVal)
  of {nnkIdent, nnkSym}:
    el.add newText(&"{{{child.strVal}}}")
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
  let a0 = "a"
  h("a", href = a0, title = "a")
  h("a", href = a0, title = "a", "b", href = a0, title = "a", "c", href = a0, title = "a")
  h("a", href = a0, title = "a", "b", href = a0, title = "a", "c", href = a0, title = "a", "d", href = a0, title = "a")
  h("a", href = a0, title = "a", "b", href = a0, title = "a", "c", href = a0, title = "a", "d", href = a0, title = "a", "e", href = a0, title = "a")
  h("a", href = a0, title = "a", "b", href = a0, title = "a", "c", href = a0, title = "a", "d", href = a0, title = "a", "e", href = a0, title = "a", "f", href = a0, title = "a")

  let a1 = "a"
  h("a", href = a1, title = "a", "b", href = a1, title = "a", "c", href = a1, title = "a", "d", href = a1, title = "a", "e", href = a1, title = "a", "f", href = a1, title = "a")
