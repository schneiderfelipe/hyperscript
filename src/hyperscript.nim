import
  macros,
  strutils,
  sugar


# TODO: can we support spread attributes (and do we need to)?
# TODO: can we support components through tag names? (maybe a function instead of a string? not sure how that would work)
# TODO: what about boolean attributes, do they work?


const AttributeNodes = {nnkExprEqExpr, nnkExprColonExpr}
const EventNodes = RoutineNodes + {nnkInfix}

when not defined(js):
  import xmltree
  export toXmlAttributes  # TODO: maybe we could get rid of this?

  type HTMLNode* = xmltree.XmlNode
  type HTMLEvent* = void  # Dummy type
else:
  import dom

  type HTMLNode* = dom.Element
  type HTMLEvent* = dom.Event


template `.`*(n: HTMLNode, name: untyped): auto =
  ## Get an attribute by name.
  when not defined(js):
    xmltree.attr(n, astToStr(name))
  else:
    dom.getAttribute(n, astToStr(name))


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
    n.innerText


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
      # TODO: maybe it is faster if we use cloneNode if a similar node has been already created?
      dom.createElement(document, tag)
    else:
      let node = dom.createElement(document, tag)
      # TODO: I would like to unroll those loops in the future.
      when len(attributes) > 0:
        for attr in attributes:
          dom.setAttribute(node, attr[0], attr[1])
      when len(children) > 0:
        for child in children:
          dom.appendChild(node, child)
      when len(events) > 0:
        for event in events:
          # TODO: can use options in the future
          debugEcho "Event listener added!"
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
  let description = args[0].strVal


  # TODO: tags, ids, styles and classes work with literals, but what about
  # variables? This should be addressed together with mutability templates.
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


  func addStyle(styles: NimNode) {.compileTime.} =
    ## Helper that adds styles.
    case styles.kind
    of nnkTableConstr:
      for pair in styles:
        style.add pair[0].strVal & ": " & pair[1].strVal & "; "
    else:
      style.add styles.strVal.strip
      if style[^1] != ';':
        style.add ';'


  func addEvent(pair: NimNode) {.compileTime.} =
    ## Helper that adds events.
    var name = pair[0].strVal
    name.removePrefix("on")
    addTupleExpr(events, name, pair[1])


  func addAttribute(attr: NimNode) {.compileTime.} =
    ## Helper that adds a new attribute.
    # TODO: what about boolean attributes?

    attr.expectKind AttributeNodes

    let name = attr[0].strVal
    case name
    of "class":
      addClass attr[1]
    of "id":
      addId attr[1]
    of "style":
      addStyle attr[1]
    else:
      case attr[1].kind
      of EventNodes:
        # Events
        addEvent attr
      else:
        # debugEcho treeRepr attr[1]
        addTupleExpr(attributes, name, attr[1])


  func addChild(child: NimNode) {.compileTime.} =
    ## Helper that adds a new child.
    case child.kind:
    of nnkStrLit:
      children.add quote do:
        createTextNode `child`
    else:
      children.add child


  # Update tag, id and classes
  var j = description.find({'.', '#'})
  if j > -1:
    tag = description[0..<j]
    var
      slice: string
      i = j
    while j > -1:
      j = description.find({'.', '#'}, start = i + 1)
      if j > -1:
        slice = description[i..<j]
      else:
        slice = description[i..^1]

      if slice[0] == '.':
        addClass slice[1..^1]
      else:
        addId slice[1..^1]
      i = j
  else:
    tag = description


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
