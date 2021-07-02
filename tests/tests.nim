import
  hyperscript,
  sugar,
  unittest


when defined(js):
  import
    dom,
    jsconsole


template `===`(x, y: auto): bool =
  ## Compare string representations.
  $x == $y


suite "Constructing simple HTML/SVG tags":
  test "can create empty tag":
    check h("div") is HTMLNode
    check h("div").tag == "div"

  test "can create tag with single attribute":
    check h("a", href="github.com") is HTMLNode
    check h("a", href="github.com").tag == "a"
    check h("a", href="github.com").href == "github.com"

  test "can create tag with two attributes":
    check h("img", src="kitten.png", alt: "a kitten") is HTMLNode
    check h("img", src="kitten.png", alt: "a kitten").tag == "img"
    check h("img", src="kitten.png", alt: "a kitten").src == "kitten.png"
    check h("img", src="kitten.png", alt: "a kitten").alt == "a kitten"

  test "can create tag with single text child":
    check h("div", "some text") is HTMLNode
    check h("div", "some text").tag == "div"
    check h("div", "some text").text == "some text"

  test "can create tag with two text children":
    check h("div", "some text", " some more") is HTMLNode
    check h("div", "some text", " some more").tag == "div"
    check h("div", "some text", " some more").text == "some text some more"

  test "can create tag with single attribute and single text child":
    check h("a", href="github.com", "some text") is HTMLNode
    check h("a", href="github.com", "some text").tag == "a"
    check h("a", href="github.com", "some text").href == "github.com"
    check h("a", href="github.com", "some text").text == "some text"


  test "can create tag with single tag child":
    check h("div", h("div")) is HTMLNode
    check h("div", h("div")).tag == "div"
    check h("div", h("div"))[0] === h("div")

  test "can create tag with two tag children":
    check h("div", h("div"), h("a")) is HTMLNode
    check h("div", h("div"), h("a")).tag == "div"
    check h("div", h("div"), h("a"))[0] === h("div")
    check h("div", h("div"), h("a"))[1] === h("a")

  test "can create tag with single text child and single tag child":
    check h("div", "some text", h("a")) is HTMLNode
    check h("div", "some text", h("a")).tag == "div"
    check h("div", "some text", h("a")).text == "some text"
    check h("div", "some text", h("a"))[1] === h("a")


  test "can use {} to set attributes":
    check h("a", {href: "https://npm.im/hyperscript"}, "hyperscript") is HTMLNode
    check h("a", {href: "https://npm.im/hyperscript"}, "hyperscript").tag == "a"
    check h("a", {href: "https://npm.im/hyperscript"}, "hyperscript").href == "https://npm.im/hyperscript"
    check h("a", {href: "https://npm.im/hyperscript"}, "hyperscript").text == "hyperscript"


suite "Special children":
  test "nil is ignored":
    check h("a", nil, "some text") is HTMLNode
    check h("a", nil, "some text").tag == "a"
    check h("a", nil, "some text").text == "some text"
    check h("a", nil, "some text")[0].text == "some text"


suite "Using id and class notations":
  test "can indicate an id":
    check h("div#header") is HTMLNode
    check h("div#header").tag == "div"
    check h("div#header").id == "header"

  test "two ids get concatenated":
    check h("div#header#main") is HTMLNode
    check h("div#header#main").tag == "div"
    check h("div#header#main").id == "headermain"

  test "can indicate a class":
    check h("div.header") is HTMLNode
    check h("div.header").tag == "div"
    check h("div.header").class == "header"

  test "two classes get joined":
    check h("div.header.note") is HTMLNode
    check h("div.header.note").tag == "div"
    check h("div.header.note").class == "header note"


  test "can mix ids and classes in any order":
    check h("div#header.note") is HTMLNode
    check h("div#header.note").tag == "div"
    check h("div#header.note").id == "header"
    check h("div#header.note").class == "note"

    check h("div.note#header") is HTMLNode
    check h("div.note#header").tag == "div"
    check h("div.note#header").id == "header"
    check h("div.note#header").class == "note"


  test "can mix notations":
    check h("div#header", id="main") is HTMLNode
    check h("div#header", id="main").tag == "div"
    check h("div#header", id="main").id == "headermain"

    check h("div.header", class="note") is HTMLNode
    check h("div.header", class="note").tag == "div"
    check h("div.header", class="note").class == "header note"


  test "can use XML namespaces":
    check h("ns:div#header") is HTMLNode
    check h("ns:div#header").tag == "ns:div"
    check h("ns:div#header").id == "header"


  test "missing tag is div":
    check h("#header") is HTMLNode
    check h("#header").tag == "div"
    check h("#header").id == "header"

    check h(".note") is HTMLNode
    check h(".note").tag == "div"
    check h(".note").class == "note"


suite "Using style notation":
  test "can use inline styles":
    check h("h1", { style: {"background-color": "blue"} }) is HTMLNode
    check h("h1", { style: {"background-color": "blue"} }).tag == "h1"
    when not defined(js):
      check h("h1", { style: {"background-color": "blue"} }).style == "background-color: blue;"
    else:
      check h("h1", { style: {"background-color": "blue"} }).style.backgroundColor == "blue"

  test "can mix notations":
    check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;") is HTMLNode
    check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").tag == "h1"
    when not defined(js):
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").style == "background-color: blue; text-align: center;"
    else:
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").style.backgroundColor == "blue"
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").style.textAlign == "center"

  test "trailing ; is always added":
    check h("h1", style="text-align: center") is HTMLNode
    check h("h1", style="text-align: center").tag == "h1"
    when not defined(js):
      check h("h1", style="text-align: center").style == "text-align: center;"
    else:
      check h("h1", style="text-align: center").style.textAlign == "center"


suite "Assigning events":
  test "can use common anonymous functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: proc(e: HTMLEvent) = debugEcho("you are 1,000,000th savory visitor!"),
    }, "click here to win a savory prize")
    check example is HTMLNode
    check example.tag == "a"
    check example.href == "#"
    when defined(js):
      # Go there and click on the button!
      console.log example
      document.body.appendChild example  # TODO: have a render function that
                                         # mounts in JS and prints in the
                                         # server. A mount point can be used as the starting reference Element.
    check example.text == "click here to win a savory prize"

  test "can use sugary functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: (e: HTMLEvent) => debugEcho("you are 1,000,000th sugary visitor!"),
    }, "click here to win a sugary prize")
    check example is HTMLNode
    check example.tag == "a"
    check example.href == "#"
    when defined(js):
      # Go there and click on the button!
      console.log example
      document.body.appendChild example
    check example.text == "click here to win a sugary prize"


suite "Constructing more complex use cases":
  test "can reproduce the example of <https://github.com/hyperhype/hyperscript#example>":
    # Single quotes became double quotes, the rest is the same as in the original.
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
    check example is HTMLNode
    check example.tag == "div"

# TODO: test escaping
