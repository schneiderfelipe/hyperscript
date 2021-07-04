# `hyperscript`

A functional [Nim](https://github.com/nim-lang/Nim) library for combining DOM pieces, with [compile-time superpowers](https://github.com/schneiderfelipe/hyperscript#how-does-it-work).
`hyperscript` creates composable HTML and SVG with Nim, both client- and server-side:

```nim
import hyperscript

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
```

(Currently, only literal arguments are supported, but this limitation will be removed in a future release, see [#8](https://github.com/schneiderfelipe/hyperscript/issues/8) and [#10](https://github.com/schneiderfelipe/hyperscript/issues/10).)

## Installation

`hyperscript` works with Nim 1.2.6+ and can be installed using [Nimble](https://github.com/nim-lang/nimble):

```bash
$ nimble install hyperscript
```

## How does it work?

The **basic design** consists of compiling down to efficient calls to the DOM (through the [`dom` standard library](https://nim-lang.org/docs/dom.html)). As such, the following,

```nim
let example = h("p#example",
  h("input.name[value=Name]",
    style: {"background": "yellow"},
  ),
)
```

compiles roughly to

```nim
let example =
  let node = document.createElement("p")
  for attr in items([("id", "example")]):
    node.setAttribute(attr[0], attr[1])
  for child in items([
    let node = document.createElement("input")
    for attr in items([("value", "Name"), ("class", "name"), ("style", "background: yellow;")]):
      node.setAttribute(attr[0], attr[1])
    node]):
    node.appendChild(child)
  node
```

(We intend to unroll all loops in the future, see [#6](https://github.com/schneiderfelipe/hyperscript/issues/6).)

When not compiling to JavaScript, `XmlNode` objects are generated using the [`xmltree` standard library](https://nim-lang.org/docs/xmltree.html). Using the C backend, for instance, the example above compiles to

```nim
let example =
  newXmlTree("p", [
      newXmlTree("input", @[],
        {"value": "Name", "class": "name", "style": "background: yellow;"}.toXmlAttributes,
      ),
    ], {"id": "example"}.toXmlAttributes,
  )
```

## Some references

- [hyperscript](https://github.com/hyperhype/hyperscript) (original library, JavaScript)
- [Hyperscript.jl](https://github.com/JuliaWeb/Hyperscript.jl) (Julia)

**Convert HTML snippets to `hyperscript`**:
- [Mithril HTML to hyperscript converter](https://arthurclemens.github.io/mithril-template-converter/)
- [HTML2HyperScript](http://html2hscript.herokuapp.com/)
