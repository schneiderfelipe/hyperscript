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
    check h("a", href="https://github.com/schneiderfelipe/hyperscript") is HTMLNode
    check h("a", href="https://github.com/schneiderfelipe/hyperscript").tag == "a"
    check h("a", href="https://github.com/schneiderfelipe/hyperscript").attr("href") == "https://github.com/schneiderfelipe/hyperscript"

  test "can create tag with two attributes":
    check h("img", src="kitten.png", alt: "a kitten") is HTMLNode
    check h("img", src="kitten.png", alt: "a kitten").tag == "img"
    check h("img", src="kitten.png", alt: "a kitten").attr("src") == "kitten.png"
    check h("img", src="kitten.png", alt: "a kitten").attr("alt") == "a kitten"

  test "can create tag with single text child":
    check h("div", "some text") is HTMLNode
    check h("div", "some text").tag == "div"
    check h("div", "some text").text == "some text"

  test "can create tag with two text children":
    check h("div", "some text", " some more") is HTMLNode
    check h("div", "some text", " some more").tag == "div"
    check h("div", "some text", " some more").text == "some text some more"

  test "can create tag with single attribute and single text child":
    check h("a", href="https://github.com/schneiderfelipe/hyperscript", "some text") is HTMLNode
    check h("a", href="https://github.com/schneiderfelipe/hyperscript", "some text").tag == "a"
    check h("a", href="https://github.com/schneiderfelipe/hyperscript", "some text").attr("href") == "https://github.com/schneiderfelipe/hyperscript"
    check h("a", href="https://github.com/schneiderfelipe/hyperscript", "some text").text == "some text"


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


suite "Special attributes and children":
  test "can use {} to set attributes":
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"}, "hyperscript") is HTMLNode
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"}, "hyperscript").tag == "a"
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"}, "hyperscript").attr("href") == "https://github.com/schneiderfelipe/hyperscript"
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"}, "hyperscript").text == "hyperscript"

  test "nil attributes are ignored":
    # TODO: we should define some kind of precedence, i.e., *remove attribute*
    # if the last value received is nil.
    check h("a", {href: nil}, "hyperscript") is HTMLNode
    check h("a", {href: nil}, "hyperscript").tag == "a"
    check h("a", {href: nil}, "hyperscript").attr("href") == ""
    check h("a", {href: nil}, "hyperscript").text == "hyperscript"


  test "can use [] to set children":
    check h("a", [nil, "some text", h("div")]) is HTMLNode
    check h("a", [nil, "some text", h("div")]).tag == "a"
    check h("a", [nil, "some text", h("div")]).text == "some text"
    check h("a", [nil, "some text", h("div")])[0].text == "some text"
    check h("a", [nil, "some text", h("div")])[1] === h("div")

  test "nil children are ignored":
    check h("a", nil, "some text") is HTMLNode
    check h("a", nil, "some text").tag == "a"
    check h("a", nil, "some text").text == "some text"
    check h("a", nil, "some text")[0].text == "some text"


suite "Using selector notation":
  test "can indicate an id":
    check h("div#header") is HTMLNode
    check h("div#header").tag == "div"
    check h("div#header").attr("id") == "header"

  test "two ids get concatenated":
    check h("div#header#main") is HTMLNode
    check h("div#header#main").tag == "div"
    check h("div#header#main").attr("id") == "headermain"

  test "can indicate a class":
    check h("div.header") is HTMLNode
    check h("div.header").tag == "div"
    check h("div.header").attr("class") == "header"

  test "two classes get joined":
    check h("div.header.note") is HTMLNode
    check h("div.header.note").tag == "div"
    check h("div.header.note").attr("class") == "header note"


  test "can indicate an attribute":
    check h("input[type=text]") is HTMLNode
    check h("input[type=text]").tag == "input"
    check h("input[type=text]").attr("type") == "text"

  test "can indicate two attributes":
    check h("input[type=text][placeholder=Name]") is HTMLNode
    check h("input[type=text][placeholder=Name]").tag == "input"
    check h("input[type=text][placeholder=Name]").attr("type") == "text"
    check h("input[type=text][placeholder=Name]").attr("placeholder") == "Name"


  test "can mix ids, classes and attributes":
    check h("div#header.note") is HTMLNode
    check h("div#header.note").tag == "div"
    check h("div#header.note").attr("id") == "header"
    check h("div#header.note").attr("class") == "note"

    check h("div.note#header") is HTMLNode
    check h("div.note#header").tag == "div"
    check h("div.note#header").attr("id") == "header"
    check h("div.note#header").attr("class") == "note"

    check h("a#exit.external[href='https://example.com']", "Leave") is HTMLNode
    check h("a#exit.external[href='https://example.com']", "Leave").tag == "a"
    check h("a#exit.external[href='https://example.com']", "Leave").attr("id") == "exit"
    check h("a#exit.external[href='https://example.com']", "Leave").attr("class") == "external"
    check h("a#exit.external[href='https://example.com']", "Leave").attr("href") == "https://example.com"
    check h("a#exit.external[href='https://example.com']", "Leave").text == "Leave"


  test "can mix notations":
    check h("div#header", id="main") is HTMLNode
    check h("div#header", id="main").tag == "div"
    check h("div#header", id="main").attr("id") == "headermain"

    check h("div.header", class="note") is HTMLNode
    check h("div.header", class="note").tag == "div"
    check h("div.header", class="note").attr("class") == "header note"

    check h("a.link[href=/]", {class: "selected"}, "Home") is HTMLNode
    check h("a.link[href=/]", {class: "selected"}, "Home").tag == "a"
    check h("a.link[href=/]", {class: "selected"}, "Home").attr("class") == "link selected"
    check h("a.link[href=/]", {class: "selected"}, "Home").attr("href") == "/"
    check h("a.link[href=/]", {class: "selected"}, "Home").text == "Home"


  test "can use XML namespaces":
    check h("ns:div#header") is HTMLNode
    check h("ns:div#header").tag == "ns:div"
    check h("ns:div#header").attr("id") == "header"


  test "missing tag is div":
    check h("#header") is HTMLNode
    check h("#header").tag == "div"
    check h("#header").attr("id") == "header"

    check h(".note") is HTMLNode
    check h(".note").tag == "div"
    check h(".note").attr("class") == "note"


suite "Using style notation":
  test "can use inline styles":
    check h("h1", { style: {"background-color": "blue"} }) is HTMLNode
    check h("h1", { style: {"background-color": "blue"} }).tag == "h1"
    when not defined(js):
      check h("h1", { style: {"background-color": "blue"} }).attr("style") == "background-color: blue;"
    else:
      check h("h1", { style: {"background-color": "blue"} }).attr("style").backgroundColor == "blue"

  test "can mix notations":
    check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;") is HTMLNode
    check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").tag == "h1"
    when not defined(js):
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").attr("style") == "background-color: blue; text-align: center;"
    else:
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").attr("style").backgroundColor == "blue"
      check h("h1", { style: {"background-color": "blue"} }, style="text-align: center;").attr("style").textAlign == "center"

  test "trailing ; is always added":
    check h("h1", style="text-align: center") is HTMLNode
    check h("h1", style="text-align: center").tag == "h1"
    when not defined(js):
      check h("h1", style="text-align: center").attr("style") == "text-align: center;"
    else:
      check h("h1", style="text-align: center").attr("style").textAlign == "center"


suite "Assigning events":
  test "can use common anonymous functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: proc(e: HTMLEvent) = debugEcho("you are 1,000,000th savory visitor!"),
    }, "click here to win a savory prize")
    check example is HTMLNode
    check example.tag == "a"
    check example.attr("href") == "#"
    when defined(js):
      # Go there and click on the button!
      console.log example
      document.body.appendChild example
    check example.text == "click here to win a savory prize"

  test "can use sugary functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: (e: HTMLEvent) => debugEcho("you are 1,000,000th sugary visitor!"),
    }, "click here to win a sugary prize")
    check example is HTMLNode
    check example.tag == "a"
    check example.attr("href") == "#"
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
