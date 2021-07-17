import macros
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
    raise newException(ValueError, "unsupported parameter: " & repr child)
  debugEcho "Got child: ", repr child

func addChild(el: XmlNode, child: NimNode) =
  case child.kind:
  of nnkCall:
    el.addCallChild(child)
  of nnkStrLit:
    el.addStringChild(child)
  else:
    raise newException(ValueError, "unsupported parameter: " & repr child)

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
  name.expectKind nnkStrLit
  result = newElement(name.strVal)
  debugEcho "Got tag: ", repr name

macro h(xs: varargs[untyped]): untyped =
  let el = tag(xs[0])
  for x in xs[1..^1]:
    el.addParam(x)
  debugEcho el

when isMainModule:
  h("a")
  h("a", "b")
  h("a", "b", "c")
  h("a", "b", "c", "d")
  h("a", "b", "c", "d", "e")
  h("a", "b", "c", "d", "e", "f")

  h("a", href = "b")
  h("a", href = "b", title = "c")
  h("a", href = "b", title = "c", target = "d")
  h("a", href = "b", title = "c", target = "d", rel = "e")
  h("a", href = "b", title = "c", target = "d", rel = "e", hreflang = "f")
  h("a", href = "b", title = "c", target = "d", rel = "e", hreflang = "f", type = "g")

  h("a", href: "b")
  h("a", href: "b", title: "c")
  h("a", href: "b", title: "c", target: "d")
  h("a", href: "b", title: "c", target: "d", rel: "e")
  h("a", href: "b", title: "c", target: "d", rel: "e", hreflang: "f")
  h("a", href: "b", title: "c", target: "d", rel: "e", hreflang: "f", type: "g")

  h("a", {href = "b"})
  h("a", {href = "b", title = "c"})
  h("a", {href = "b", title = "c", target = "d"})
  h("a", {href = "b", title = "c", target = "d", rel = "e"})
  h("a", {href = "b", title = "c", target = "d", rel = "e", hreflang = "f"})
  h("a", {href = "b", title = "c", target = "d", rel = "e", hreflang = "f", type = "g"})

  h("a", {href: "b"})
  h("a", {href: "b", title: "c"})
  h("a", {href: "b", title: "c", target: "d"})
  h("a", {href: "b", title: "c", target: "d", rel: "e"})
  h("a", {href: "b", title: "c", target: "d", rel: "e", hreflang: "f"})
  h("a", {href: "b", title: "c", target: "d", rel: "e", hreflang: "f", type: "g"})

  h("a", h("div"))
  h("a", h("div"), h("span"))
  h("a", h("div"), h("span"), h("b"))
  h("a", h("div"), h("span"), h("b"), h("i"))

  h("a", h("div"), href = "b")
  h("a", h("div"), href = "b", title = "c")
  h("a", h("div"), href = "b", title = "c", target = "d")
  h("a", h("div"), href = "b", title = "c", target = "d", rel = "e")

  h("a", h("div"), {href = "b"})
  h("a", h("div"), {href = "b", title = "c"})
  h("a", h("div"), {href = "b", title = "c", target = "d"})
  h("a", h("div"), {href = "b", title = "c", target = "d", rel = "e"})

  h("a", h("div"), h("span"), {href = "b"})
  h("a", h("div"), h("span"), {href = "b", title = "c"})
  h("a", h("div"), h("span"), {href = "b", title = "c", target = "d"})
  h("a", h("div"), h("span"), {href = "b", title = "c", target = "d", rel = "e"})
