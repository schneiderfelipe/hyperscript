import
  macros,
  strformat,
  strutils,
  sugar


when not defined(js):
  from xmltree import toXmlAttributes, `attrs=`
  import strtabs
  export toXmlAttributes, `attrs=`

  type
    Element* = xmltree.XmlNode
    HEvent* = void # Dummy type
else:
  from dom import document

  type
    Element* = dom.Element
    HEvent* = dom.Event


macro append*(target: untyped, children: varargs[untyped]): auto =
  ## Insert the specified `content` as the last child of `target` and
  ## **return `target`**.


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


template attrSetImpl*(t, key, val: auto): auto =
  ## Helper that sets a single attribute in-place (nothing is returned).
  when not defined(js):
    if xmltree.attrs(t) != nil:
      xmltree.attrs(t)[key] = val
    else:
      t.attrs = {key: val}.toXmlAttributes
  else:
    dom.setAttribute(t, key, val)
template attr*[T](target: T, key, val: string): auto =
  ## Insert the specified `attribute` as an attribute of `target` and **return
  ## `target`**.
  let t = target # Evaluate once.
  t.attrSetImpl(key, val)
  t


macro attr*(target: untyped, attributes: varargs[untyped]): auto =
  ## Insert the specified `attributes` as attributes of `target` and **return
  ## `target`**.


  template attrImpl[T, S: not openArray](t: T, attribute: S): auto =
    ## Helper that sets a single attribute.
    t.attrSetImpl(attribute[0], attribute[1])
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


template onSetImpl*(t, key, f: auto): auto =
  ## Helper that sets a single event in-place (nothing is returned).
  when not defined(js):
    debugEcho "Event listeners are not supported outside JavaScript: got \"" &
        key & "\""
  else:
    dom.addEventListener(t, key, f)
template on*[T](target: T, key: string, f: auto): auto =
  ## Insert the specified `event` as an event of `target` and **return
  ## `target`**.
  let t = target # Evaluate once.
  t.onSetImpl(key, f)
  t


macro on*(target: untyped, events: varargs[untyped]): auto =
  ## Insert the specified `events` as events on `target` and **return
  ## `target`**.


  template onImpl[T, S: not openArray](t: T, event: S): auto =
    ## Helper that sets a single event.
    t.onSetImpl(event[0], event[1])
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


template style*(n: Element): auto =
  ## Get styles.
  when not defined(js):
    xmltree.attr(n, "style")
  else:
    n.style


template len*(n: Element): auto =
  ## Get the number of children.
  when not defined(js):
    xmltree.len(n)
  else:
    dom.len(n)


template `[]`*(n: Element, i: Natural): auto =
  ## Get the ith child.
  when not defined(js):
    xmltree.`[]`(n, i)
  else:
    dom.`[]`(n, i)


template `$`*(n: Element): auto =
  ## Represent a node as a string.
  when not defined(js):
    xmltree.`$`(n)
  else:
    n.outerHTML


template text*(n: Element): auto =
  ## Get inner text.
  ##
  ## **Note**: this is not meant to work with text nodes.
  when not defined(js):
    xmltree.innerText(n)
  else:
    assert n.nodeType != dom.TextNode
    n.innerText


template text*(n: var Element, s: string): auto =
  ## Set inner text. This substitutes all children.
  ##
  ## **Note**: this is not meant to work with text nodes.
  when not defined(js):
    xmltree.clear(n)
    xmltree.add(n, xmltree.newText s)
  else:
    assert n.nodeType != dom.TextNode
    n.innerText = s
  n


template tag*(n: Element): auto =
  ## Get tag name.
  when not defined(js):
    xmltree.tag(n)
  else:
    # The browser returns uppercase, see
    # <https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeName#example>.
    toLowerAscii $n.nodeName


template createTextNode(text: string): auto =
  ## Construct a text node.
  when not defined(js):
    xmltree.newText(text)
  else:
    dom.createTextNode(document, text)


func parseSelector(s: string): (string, seq[(string, string)]) {.compileTime.} =
  ## Process a CSS selector and return a tag and attributes. Empty tags
  ## default to `div`.

  template addSel(s: string) =
    if len(s) > 0:
      case s[0]:
      of '.':
        result[1].add ("class", s[1..^1])
      of '#':
        result[1].add ("id", s[1..^1])
      of '[':
        let fs = s[1..^1].split('=', 1)
        result[1].add (fs[0], fs[1].strip(chars = {'\'', '"'}))
      else:
        debugEcho &"could not parse CSS selector: \"{s}\""

  var j = s.find({'.', '#', '['})
  if j == -1:
    # Only a tag
    result[0] = s
  else:
    result[0] = s[0..<j]

    var i = j
    j += 1
    while j < len(s):
      case s[i]:
      of '.', '#':
        if s[j] in {'.', '#', '['}:
          addSel s[i..<j]
          i = j
      of '[':
        if s[j] == ']':
          addSel s[i..<j]
          i = j + 1
      else:
        discard
      j += 1

    # Last item
    addSel s[i..<j]

  if len(result[0]) == 0:
    result[0] = "div"


func addTupleExpr(xs, x, y: auto) {.compileTime.} =
  ## Helper for inserting tuples expressions to expressions.
  xs.add quote do:
    (`x`, `y`)


func parseSelector(s: NimNode): (NimNode, NimNode) {.compileTime.} =
  ## Process a *literal* CSS selector **at compile-time** and return **code**
  ## for a tag and attributes. Empty tags default to `div`.
  s.expectKind nnkStrLit
  let (tag, attrs) = parseSelector s.strVal
  result = (newLit tag, newNimNode(nnkBracket))
  for a in attrs:
    result[1].add newLit a


macro createElement(args: varargs[untyped]): untyped =
  ## Construct an element.

  func processArgs(args: auto, attrs = newNimNode(nnkBracket)): (NimNode,
      NimNode, NimNode) {.compileTime.} =
    ## Process arguments and return attributes, children and events.

    result = (attrs, newNimNode(nnkBracket), newNimNode(nnkBracket))


    const AttributeNodes = {nnkExprEqExpr, nnkExprColonExpr}
    const AttributeCollectionNodes = {nnkTableConstr}
    const TextNodes = {nnkStrLit}
    const ChildrenCollectionNodes = {nnkBracket}
    const EventNodes = RoutineNodes + {nnkInfix}
    const IgnoredNodes = {nnkNilLit}


    # TODO: this strategy is interesting for making things work both at
    # compile-time and at runtime.
    template isEvent(val: auto): bool =
      ## Check if a value is a valid event callback.
      false
    template isEvent(val: NimNode): bool =
      ## Check if a value is a valid event callback.
      val.kind in EventNodes


    template addEvent(key: var string, val: auto) =
      ## Helper that adds events.
      key.removePrefix("on")
      addTupleExpr(result[2], key, val)
    template addEvent(pair: NimNode) =
      ## Helper that adds events.
      var k = pair[0].strVal
      addEvent(k, pair[1])


    # TODO: the current way to handle styles is strongly coupled and won't
    # properly work at runtime.
    var style: string
    template addStyle(styles: auto) =
      ## Helper that adds styles.
      style.add styles
    template addStyle(styles: NimNode) =
      ## Helper that adds styles.
      case styles.kind:
      of AttributeCollectionNodes:
        for pair in styles:
          # TODO: ignore nil?
          addStyle pair[0].strVal & ": " & pair[1].strVal & "; "
      else:
        addStyle styles.strVal.strip
        if style[^1] != ';':
          addStyle ';'


    template addAttrOrEvent(key: var string, val: auto) =
      ## Helper that adds a new attribute.
      case key:
      of "style":
        addStyle val
      else:
        if isEvent(val):
          addEvent(key, val)
        else:
          addTupleExpr(result[0], key, val)
    template addAttrOrEvent(attr: NimNode) =
      ## Helper that adds a new attribute.
      if attr[1].kind notin IgnoredNodes and attr[1] != ident"false":
        if attr[1] == ident"true":
          addTupleExpr(result[0], attr[0].strVal, attr[0].strVal)
        else:
          var k = attr[0].strVal
          addAttrOrEvent(k, attr[1])


    template addTextOrChild(child: NimNode) =
      ## Helper that adds a new child. This is also used when a bracket is
      ## found in the arguments.
      case child.kind:
      of IgnoredNodes:
        discard
      of TextNodes:
        result[1].add quote do:
          createTextNode `child.strVal`
      else:
        result[1].add child


    for arg in args:
      case arg.kind:
      of AttributeCollectionNodes:
        for x in arg:
          addAttrOrEvent x
      of AttributeNodes:
        addAttrOrEvent arg
      of ChildrenCollectionNodes:
        for x in arg:
          addTextOrChild x
      of IgnoredNodes:
        discard
      of TextNodes:
        addTextOrChild arg
      else:
        # TODO: here we can't be sure that this is a child, we need to look
        # into its type. In fact, we can do better by providing bool
        # functions for checking if an argument is an event, child,
        # attribute, etc.
        addTextOrChild arg


    if len(style) > 0:
      addTupleExpr(result[0], "style", style.strip)

    if len(result[0]) == 0:
      result[0] = quote do:
        newSeq[(string, string)]()

    if len(result[1]) == 0:
      result[1] = quote do:
        newSeq[Element]()

    if len(result[2]) == 0:
      result[2] = quote do:
        newSeq[(string, (e: HEvent) -> void)]()


  let (tag, selattrs) = parseSelector args[0]
  let (attrs, children, events) = processArgs(args[1..^1], selattrs)


  result = quote do:
    when not defined(js):
      xmltree.newXmlTree(`tag`, `children`, toXmlAttributes(`attrs`)).on(`events`)
    else:
      dom.createElement(document, `tag`).attr(`attrs`).append(`children`).on(`events`)


template h*(args: varargs[untyped]): untyped =
  ## Alias for `createElement`.
  unpackVarargs(createElement, args)


when not defined(js):
  type
    Document = object
      body*: Element
  let document* = Document(body: h("body")) # Dummy document
else:
  export document


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
