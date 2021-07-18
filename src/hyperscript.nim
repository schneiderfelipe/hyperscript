import macros
import sequtils
import strformat
import strtabs
import strutils
import xmltree

const RunnableNodes = {nnkIdent, nnkSym, nnkDotExpr} + CallNodes

func hxml(xs: varargs[NimNode]): XmlNode


func getTagElement(name: NimNode): XmlNode =
  case name.kind:
  of nnkStrLit:
    result = newElement(name.strVal)
  of RunnableNodes:
    result = newElement(&"{{{repr(name)}}}")
  else:
    raise newException(ValueError, "unsupported tag kind: " & $name.kind)

func getCommonChild(child: NimNode): XmlNode =
  case child.kind:
  of nnkStrLit:
    result = newText(child.strVal)
  of RunnableNodes:
    result = newText(&"{{{repr(child)}}}")
  else:
    raise newException(ValueError, "unsupported child kind: " & $child.kind)

func getAttrKey(key: NimNode): string =
  case key.kind:
  of nnkStrLit:
    result = key.strVal
  of RunnableNodes:
    result = &"{{{repr(key)}}}"
  else:
    raise newException(ValueError, "unsupported attribute key kind: " & $key.kind)
  assert len(result) > 0, "empty attribute key"

func getAttrValue(value: NimNode): string =
  case value.kind:
  of nnkStrLit:
    result = value.strVal
  of RunnableNodes:
    result = &"{{{repr(value)}}}"
  else:
    raise newException(ValueError, "unsupported attribute value kind: " & $value.kind)
  assert len(result) > 0, "empty attribute value"

func addAttr(el: XmlNode, attr: NimNode) =
  attr.expectKind {nnkExprEqExpr, nnkExprColonExpr}
  let
    key = getAttrKey(attr[0])
    value = getAttrValue(attr[1])
  if not isNil(el.attrs):
    el.attrs[key] = value
  else:
    el.attrs = {key: value}.toXmlAttributes()
  assert not isNil(el.attrs), "attributes not initialized"

func isHyperscriptCall(node: NimNode): bool =
  node.kind == nnkCall and
  node[0].kind in {nnkIdent, nnkSym} and
  node[0].strVal == "h"

func addHyperscriptChild(el: XmlNode, child: NimNode) =
  assert isHyperscriptCall(child), "expected hyperscript call"
  el.add hxml(child[1..^1].toSeq)

func addChild(el: XmlNode, child: NimNode) =
  if isHyperscriptCall(child):
    el.addHyperscriptChild(child)
  else:
    el.add getCommonChild(child)

func addChildren(el: XmlNode, chilren: NimNode) =
  chilren.expectKind {nnkBracket, nnkPar}
  for child in chilren:
    el.addChild(child)

func addAttrs(el: XmlNode, attrs: NimNode) =
  attrs.expectKind {nnkCurly, nnkTableConstr}
  for attr in attrs:
    el.addAttr(attr)

func addGeneric(el: XmlNode, param: NimNode) =
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

func hxml(xs: varargs[NimNode]): XmlNode =
  result = getTagElement(xs[0])
  for x in xs[1..^1]:
    result.addGeneric(x)

func transform(node: XmlNode): NimNode =
  case node.kind:
  of xnText:
    # TODO: here we should check if the text is in fact a Nim expression. The generated code should check the type of the expression using `when`.
    result = newCall(
      ident"newText",
      newTree(
        nnkCallStrLit,
        ident"&",
        newLit(node.text),
      ),
    )
  of xnElement:
    let children = newTree(nnkBracket)
    for child in node:
      children.add transform(child)
    let attrs = if not isNil(node.attrs):
      let a = newTree(nnkTableConstr)
      for k, v in node.attrs:
        if k.startsWith("on"):
          debugEcho("event handlers are ignored when not compiling to JavaScript: " & k)
        else:
          a.add newTree(
            nnkExprColonExpr,
            newTree(
              nnkCallStrLit,
              ident"&",
              newLit(k),
            ),
            newTree(
              nnkCallStrLit,
              ident"&",
              newLit(v),
            ),
          )
      newCall(
        ident"toXmlAttributes",
        a,
      )
    else:
      newNilLit()
    result = newCall(
      ident"newXmlTree",
      newTree(
        nnkCallStrLit,
        ident"&",
        newLit(node.tag),
      ),
      children,
      attrs,
    )
  else:
    raise newException(ValueError, "unsupported node kind: " & $node.kind)

macro h(xs: varargs[untyped]): untyped =
  result = transform hxml(xs.toSeq)
  debugEcho repr result


when isMainModule:
  let version = 3
  var count = 0
  func increment(e: auto) =
    count += 1
  func decrement(e: auto) =
    count -= 1

  echo h("div", "id": "app", "class": "app", "data-version": version,
    h("button", "+", "onclick": increment),
    h("div", [count]),
    h("button", "-", "onclick": decrement),
  )
