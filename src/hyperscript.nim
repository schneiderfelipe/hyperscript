import
  macros,
  strutils,
  sugar


const AttributeNodes = {nnkExprEqExpr, nnkExprColonExpr}
const EventNodes = RoutineNodes + {nnkInfix}

when not defined(js):
  import xmltree
  export toXmlAttributes # TODO: maybe we could get rid of this?

  type HTMLNode* = xmltree.XmlNode
  type HTMLEvent* = void # Dummy type
else:
  import dom
  export document # TODO: maybe we could get rid of this?

  type HTMLNode* = dom.Element
  type HTMLEvent* = dom.Event


macro append*(target: untyped, children: varargs[untyped]): auto =
  ## Insert the specified `content` as the last child of `target` and
  ## **returns `target`**.


  template appendImpl[T, S: not openArray](t: T, child: S): auto =
    ## Helper that adds a single element.
    when not defined(js):
      xmltree.add(t, child)
    else:
      dom.appendChild(t, child)
  template appendImpl[T, S](t: T, children: openArray[S]): auto =
    ## Helper that adds an open array of elements. We unroll loops of up to
    ## eight elements here.
    when len(children) == 1:
      appendImpl(t, children[0])
    elif len(children) == 2:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
    elif len(children) == 3:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
    elif len(children) == 4:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
      appendImpl(t, children[3])
    elif len(children) == 5:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
      appendImpl(t, children[3])
      appendImpl(t, children[4])
    elif len(children) == 6:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
      appendImpl(t, children[3])
      appendImpl(t, children[4])
      appendImpl(t, children[5])
    elif len(children) == 7:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
      appendImpl(t, children[3])
      appendImpl(t, children[4])
      appendImpl(t, children[5])
      appendImpl(t, children[6])
    elif len(children) == 8:
      appendImpl(t, children[0])
      appendImpl(t, children[1])
      appendImpl(t, children[2])
      appendImpl(t, children[3])
      appendImpl(t, children[4])
      appendImpl(t, children[5])
      appendImpl(t, children[6])
      appendImpl(t, children[7])
    elif len(children) > 0:
      for child in children:
        appendImpl(t, child)


  result = newStmtList()
  if len(children) > 0:
    let t = genSym()
    result.add quote do:
      let `t` = `target` # Evaluate once.
    for child in children:
      result.add quote do:
        appendImpl(`t`, `child`)
    result.add quote do:
      `t`


macro attr*(target: untyped, attributes: varargs[untyped]): auto =
  ## Insert the specified `attributes` as attributes of `target` and **returns
  ## `target`**.


  template attrImpl[T, S: not openArray](t: T, attribute: S): auto =
    ## Helper that sets a single attribute.
    when not defined(js):
      # TODO: not the prettiest thing in the world
      xmltree.attrs(t, xmltree.attrs(t) & attribute)
    else:
      dom.setAttribute(t, attribute[0], attribute[1])
  template attrImpl[T, S](t: T, attributes: openArray[S]): auto =
    ## Helper that adds an open array of attributes. We unroll loops of up to
    ## eight elements here.
    when len(attributes) == 1:
      attrImpl(t, attributes[0])
    elif len(attributes) == 2:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
    elif len(attributes) == 3:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
    elif len(attributes) == 4:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
      attrImpl(t, attributes[3])
    elif len(attributes) == 5:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
      attrImpl(t, attributes[3])
      attrImpl(t, attributes[4])
    elif len(attributes) == 6:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
      attrImpl(t, attributes[3])
      attrImpl(t, attributes[4])
      attrImpl(t, attributes[5])
    elif len(attributes) == 7:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
      attrImpl(t, attributes[3])
      attrImpl(t, attributes[4])
      attrImpl(t, attributes[5])
      attrImpl(t, attributes[6])
    elif len(attributes) == 8:
      attrImpl(t, attributes[0])
      attrImpl(t, attributes[1])
      attrImpl(t, attributes[2])
      attrImpl(t, attributes[3])
      attrImpl(t, attributes[4])
      attrImpl(t, attributes[5])
      attrImpl(t, attributes[6])
      attrImpl(t, attributes[7])
    elif len(attributes) > 0:
      for attribute in attributes:
        attrImpl(t, attribute)


  result = newStmtList()
  if len(attributes) > 0:
    let t = genSym()
    result.add quote do:
      let `t` = `target` # Evaluate once.
    for attribute in attributes:
      result.add quote do:
        attrImpl(`t`, `attribute`)
    result.add quote do:
      `t`


template attr*[T](t: T, attribute: string): auto =
  ## Helper that gets a single attribute by name and returns `""` on failure.
  when not defined(js):
    xmltree.attr(t, attribute)
  else:
    if dom.hasAttribute(t, attribute):
      dom.getAttribute(t, attribute)
    else:
      ""

macro on*(target: untyped, events: varargs[untyped]): auto =
  ## Insert the specified `events` as events on `target` and **returns
  ## `target`**.


  template onImpl[T, S: not openArray](t: T, event: S): auto =
    ## Helper that sets a single event.
    when not defined(js):
      debugEcho "Event listeners are not supported outside JavaScript: ", event
    else:
      dom.addEventListener(t, event[0], event[1])
  template onImpl[T, S](t: T, events: openArray[S]): auto =
    ## Helper that adds an open array of events. We unroll loops of up to
    ## eight elements here.
    when len(events) == 1:
      onImpl(t, events[0])
    elif len(events) == 2:
      onImpl(t, events[0])
      onImpl(t, events[1])
    elif len(events) == 3:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
    elif len(events) == 4:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
      onImpl(t, events[3])
    elif len(events) == 5:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
      onImpl(t, events[3])
      onImpl(t, events[4])
    elif len(events) == 6:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
      onImpl(t, events[3])
      onImpl(t, events[4])
      onImpl(t, events[5])
    elif len(events) == 7:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
      onImpl(t, events[3])
      onImpl(t, events[4])
      onImpl(t, events[5])
      onImpl(t, events[6])
    elif len(events) == 8:
      onImpl(t, events[0])
      onImpl(t, events[1])
      onImpl(t, events[2])
      onImpl(t, events[3])
      onImpl(t, events[4])
      onImpl(t, events[5])
      onImpl(t, events[6])
      onImpl(t, events[7])
    elif len(events) > 0:
      for event in events:
        onImpl(t, event)


  result = newStmtList()
  if len(events) > 0:
    let t = genSym()
    result.add quote do:
      let `t` = `target` # Evaluate once.
    for event in events:
      result.add quote do:
        onImpl(`t`, `event`)
    result.add quote do:
      `t`


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
      debugEcho "Event listeners are not supported outside JavaScript: ", events
    xmltree.newXmlTree(tag, children, attributes.toXmlAttributes)
  else:
    dom.createElement(document, tag).attr(attributes).append(children).on(events)


template createTextNode(text: auto): auto =
  ## Construct a text node.
  when not defined(js):
    xmltree.newText(text)
  else:
    dom.createTextNode(document, text)


macro createElement(args: varargs[untyped]): untyped =
  ## Construct an element.
  args[0].expectKind nnkStrLit
  let selector = args[0].strVal


  var
    tag, style: string
    attributes, children, events = newNimNode(nnkBracket)


  func addTupleExpr(container, first, second: auto) {.compileTime.} =
    ## Helper for adding tuple expressions to expression collections.
    container.add quote do:
      (`first`, `second`)


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
        addAttribute "class", selector[1..^1]
      of '#':
        addAttribute "id", selector[1..^1]
      of '[':
        let fs = selector[1..^1].split('=', 1)
        addAttribute fs[0], fs[1].strip(chars = {'\'', '"'})
      else:
        debugEcho "unknown selector: " & selector


  # Process selector and update tag and attributes
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
          h("h1.classy", "h", {style: {"background-color": "#22f"}})),
        h("div#menu", {style: {"background-color": "#2f2"}},
          h("ul",
            h("li", "one"),
            h("li", "two"),
            h("li", "three"))),
          h("h2", "content title", {style: {"background-color": "#f22"}}),
          h("p",
            "so it's just like a templating engine,\n",
            "but easy to use inline with Nim\n"),
          h("p",
            "the intention is for this to be used to create\n",
            "reusable, interactive HTML widgets. "))

  debugEcho sizeof example[]
  debugEcho sizeof h("a")[]
