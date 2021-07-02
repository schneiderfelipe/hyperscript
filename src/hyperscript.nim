import
  macros,
  strutils,
  sugar




const AttributeNodes = {nnkExprEqExpr, nnkExprColonExpr}
const EventNodes = RoutineNodes + {nnkInfix}

when not defined(js):
  import xmltree
  export toXmlAttributes  # TODO: maybe we could get rid of this?

  type HTMLNode* = xmltree.XmlNode
  type HTMLEvent* = void  # Dummy type
else:
  import dom
  export document  # TODO: maybe we could get rid of this?

  type HTMLNode* = dom.Element
  type HTMLEvent* = dom.Event


macro append*(target: untyped, children: varargs[untyped]): auto =
  ## Insert the specified `content` as the last child of `target` and
  ## **returns `target`**.


  template appendImpl[T,S: not openArray](t: T, child: S): auto =
    ## Helper that adds a single element.
    when not defined(js):
      xmltree.add(t, child)
    else:
      dom.appendChild(t, child)
  template appendImpl[T,S](t: T, children: openArray[S]): auto =
    ## Helper that adds an open array of elements. We do some loop unrolling
    ## here.
    when len(children) == 1:
      appendImpl(t, children[0])
    elif len(children) > 0:
      for child in children:
        appendImpl(t, child)


  result = newStmtList()
  if len(children) > 0:
    let t = genSym()
    result.add quote do:
      let `t` = `target`  # Evaluate once.
    for child in children:
      result.add quote do:
        appendImpl(`t`, `child`)
    result.add quote do:
      `t`


template attr*(n: HTMLNode, key: untyped): auto =
  ## Get an attribute by name. Return `""` on failure.
  when not defined(js):
    xmltree.attr(n, key)
  else:
    if dom.hasAttribute(n, key):
      dom.getAttribute(n, key)
    else:
      ""


template style*(n: HTMLNode): auto =
  ## Get styles.
  when not defined(js):
    xmltree.attr(n, "style")
  else:
    n.style


template len*(n: HTMLNode): auto =
  ## Get the number of children.
  when not defined(js):
    xmltree.len(n)
  else:
    dom.len(n)


template `[]`*(n: HTMLNode, i: Natural): auto =
  ## Get the ith child.
  when not defined(js):
    xmltree.`[]`(n, i)
  else:
    dom.`[]`(n, i)


template `$`*(n: HTMLNode): auto =
  ## Represent a node as a string.
  when not defined(js):
    xmltree.`$`(n)
  else:
    n.outerHTML


template text*(n: HTMLNode): auto =
  ## Get inner text.
  when not defined(js):
    xmltree.innerText(n)
  else:
    if n.nodeType != dom.TextNode:
      n.innerText
    else:
      n.data


template tag*(n: HTMLNode): auto =
  ## Get tag name.
  when not defined(js):
    xmltree.tag(n)
  else:
    # The browser returns uppercase, see
    # <https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeName#example>.
    toLowerAscii $n.nodeName


template createElementImpl(tag, attributes, children, events: auto): auto =
  ## Construct an element.
  when not defined(js):
    when len(events) > 0:
      debugEcho "Some event listeners had to be discarded: ", events
    xmltree.newXmlTree(tag, children, attributes.toXmlAttributes)
  else:
    when len(attributes) == 0 and len(children) == 0 and len(events) == 0:
      dom.createElement(document, tag)
    else:
      let node = dom.createElement(document, tag)
      when len(attributes) > 0:
        for attr in attributes:
          dom.setAttribute(node, attr[0], attr[1])
      discard unpackVarargs(append, node, children)  # TODO: remove discard in the future
      when len(events) > 0:
        for event in events:
          dom.addEventListener(node, event[0], event[1])
      node


template createTextNode(text: auto): auto =
  ## Construct a text node.
  when not defined(js):
    xmltree.newText(text)
  else:
    dom.createTextNode(document, text)


macro createElement(args: varargs[untyped]): untyped =
  ## Construct an element with style.
  args[0].expectKind nnkStrLit
  let selector = args[0].strVal


  var
    tag, id, style: string
    classes: seq[string]
    attributes, children, events = newNimNode(nnkBracket)


  func addTupleExpr(container, first, second: auto) {.compileTime.} =
    ## Helper for adding tuple expressions to expression collections.
    container.add quote do:
      (`first`, `second`)


  func addClass(class: string) {.compileTime.} =
    ## Helper that adds a new class.
    classes.add class
  func addClass(class: NimNode) {.compileTime.} =
    ## Helper that adds a new class.
    addClass class.strVal


  func addId(x: string) {.compileTime.} =
    ## Helper that adds a new class.
    id.add x
  func addId(x: NimNode) {.compileTime.} =
    ## Helper that adds a new class.
    addId x.strVal


  func addStyle(styles: auto) {.compileTime.} =
    ## Helper that adds styles.
    style.add styles
  func addStyle(styles: NimNode) {.compileTime.} =
    ## Helper that adds styles.
    case styles.kind:
    of nnkTableConstr:
      for pair in styles:
        # TODO: ignore nil?
        addStyle pair[0].strVal & ": " & pair[1].strVal & "; "
    else:
      addStyle styles.strVal.strip
      if style[^1] != ';':
        addStyle ';'


  func isEvent(val: auto): bool {.compileTime.} =
    ## Check if a value is a valid event callback.
    false
  func isEvent(val: NimNode): bool {.compileTime.} =
    ## Check if a value is a valid event callback.
    val.kind in EventNodes

  func addEvent(key: sink string, val: auto) {.compileTime.} =
    ## Helper that adds events.
    key.removePrefix("on")
    addTupleExpr(events, key, val)
  func addEvent(pair: NimNode) {.compileTime.} =
    ## Helper that adds events.
    addEvent(pair[0].strVal, pair[1])


  func addAttribute(key, val: auto) {.compileTime.} =
    ## Helper that adds a new attribute.
    case key:
    of "class":
      addClass val
    of "id":
      addId val
    of "style":
      addStyle val
    else:
      if isEvent(val):
        addEvent(key, val)
      else:
        addTupleExpr(attributes, key, val)
  func addAttribute(attr: NimNode) {.compileTime.} =
    ## Helper that adds a new attribute.
    attr.expectKind AttributeNodes
    if attr[1].kind != nnkNilLit and attr[1] != ident"false":
      if attr[1] == ident"true":
        addTupleExpr(attributes, attr[0].strVal, attr[0].strVal)
      else:
        addAttribute(attr[0].strVal, attr[1])


  func addChild(child: NimNode) {.compileTime.} =
    ## Helper that adds a new child.
    case child.kind:
    of nnkStrLit:
      children.add quote do:
        createTextNode `child`
    of nnkNilLit:
      discard
    else:
      children.add child


  func addSelector(selector: string) {.compileTime.} =
    if len(selector) > 0:
      case selector[0]:
      of '.':
        addClass selector[1..^1]
      of '#':
        addId selector[1..^1]
      of '[':
        let fs = selector[1..^1].split('=', 1)
        addAttribute fs[0], fs[1].strip(chars = {'\'', '"'})
      else:
        debugEcho "unknown selector: " & selector


  # Process selector and update tag, id, classes and attributes
  var j = selector.find({'.', '#', '['})
  if j == -1:
    # Only a tag
    tag = selector
  else:
    tag = selector[0..<j]

    var i = j
    j += 1
    while j < len(selector):
      case selector[i]:
      of '.', '#':
        if selector[j] in {'.', '#', '['}:
          addSelector selector[i..<j]
          i = j
      of '[':
        if selector[j] == ']':
          addSelector selector[i..<j]
          i = j + 1
      else:
        discard
      j += 1

    # Last item
    addSelector selector[i..<j]


  for arg in args[1..^1]:
    case arg.kind:
    of AttributeNodes:
      addAttribute arg
    of nnkTableConstr:
      for pair in arg:
        addAttribute pair
    of nnkBracket:
      for child in arg:
        addChild child
    else:
      addChild arg


  if len(classes) > 0:
    addTupleExpr(attributes, "class", join(classes, " "))

  if len(id) > 0:
    addTupleExpr(attributes, "id", id)

  if len(style) > 0:
    addTupleExpr(attributes, "style", style.strip)


  if len(tag) == 0:
    tag = "div"

  if len(attributes) == 0:
    attributes = quote do:
      newSeq[(string, string)]()

  if len(children) == 0:
    children = quote do:
      newSeq[HTMLNode]()

  if len(events) == 0:
    events = quote do:
      newSeq[(string, (e: HTMLEvent) -> void)]()


  result = quote do:
    createElementImpl(`tag`, `attributes`, `children`, `events`)


template h*(args: varargs[untyped]): untyped =
  ## Alias for `createElement`.
  unpackVarargs(createElement, args)


when isMainModule:
  expandMacros:
    let example =
      h("div#page",
        h("div#header",
          h("h1.classy", "h", { style: {"background-color": "#22f"} })),
        h("div#menu", { style: {"background-color": "#2f2"} },
          h("ul",
            h("li", "one"),
            h("li", "two"),
            h("li", "three"))),
          h("h2", "content title",  { style: {"background-color": "#f22"} }),
          h("p",
            "so it's just like a templating engine,\n",
            "but easy to use inline with Nim\n"),
          h("p",
            "the intention is for this to be used to create\n",
            "reusable, interactive HTML widgets. "))

  debugEcho sizeof example[]
  debugEcho sizeof h("a")[]
