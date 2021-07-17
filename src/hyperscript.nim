import macros
import xmltree

func tag(name: NimNode): XmlNode =
  name.expectKind nnkStrLit
  result = newElement(name.strVal)
  debugEcho "Got tag: ", repr name

macro h(xs: varargs[untyped]): untyped =
  let el = tag(xs[0])
  # for x in xs[1..^1]:
    # el.addParam(x)
  debugEcho el

when isMainModule:
  h("foo")
