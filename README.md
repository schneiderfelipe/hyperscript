# hyperscript

A [hyperscript](https://github.com/hyperhype/hyperscript) Nim implementation with compile-time superpowers.

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

## Some references

- [hyperscript](https://github.com/hyperhype/hyperscript) (JavaScript)
- [HTML2HyperScript](http://html2hscript.herokuapp.com/): convert HTML snippets to hyperscript
