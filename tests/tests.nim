import
  hyperscript,
  sugar,
  unittest


template `===`(x, y: auto): bool =
  ## Compare string representations.
  $x == $y


suite "Constructing simple HTML/SVG tags":
  test "can create empty tag":
    check h("div") is Element
    check h("div").tag == "div"

  test "can create empty tag with variable":
    let x = "a"
    check h(x) is HTMLNode
    check h(x).tag == "a"

  test "can create tag with single attribute":
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript") is Element
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript").tag == "a"
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript").attr(
        "href") == "https://github.com/schneiderfelipe/hyperscript"

  test "can create tag with two attributes":
    check h("img", src = "kitten.png", alt: "a kitten") is Element
    check h("img", src = "kitten.png", alt: "a kitten").tag == "img"
    check h("img", src = "kitten.png", alt: "a kitten").attr("src") == "kitten.png"
    check h("img", src = "kitten.png", alt: "a kitten").attr("alt") == "a kitten"

  test "can create tag with single text child":
    check h("div", "some text") is Element
    check h("div", "some text").tag == "div"
    check h("div", "some text").text == "some text"

  test "can create tag with two text children":
    check h("div", "some text", " some more") is Element
    check h("div", "some text", " some more").tag == "div"
    check h("div", "some text", " some more").text == "some text some more"

  test "can create tag with single attribute and single text child":
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript",
        "some text") is Element
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript",
        "some text").tag == "a"
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript",
        "some text").attr("href") == "https://github.com/schneiderfelipe/hyperscript"
    check h("a", href = "https://github.com/schneiderfelipe/hyperscript",
        "some text").text == "some text"


  test "can create tag with single tag child":
    check h("div", h("div")) is Element
    check h("div", h("div")).tag == "div"
    check h("div", h("div"))[0] === h("div")

  test "can create tag with two tag children":
    check h("div", h("div"), h("a")) is Element
    check h("div", h("div"), h("a")).tag == "div"
    check h("div", h("div"), h("a"))[0] === h("div")
    check h("div", h("div"), h("a"))[1] === h("a")

  test "can create tag with single text child and single tag child":
    check h("div", "some text", h("a")) is Element
    check h("div", "some text", h("a")).tag == "div"
    check h("div", "some text", h("a")).text == "some text"
    check h("div", "some text", h("a"))[1] === h("a")


  test "HTML entities are escaped in text":
    check h("div", "escaped <, & and >") is Element
    check h("div", "escaped <, & and >").tag == "div"
    check h("div", "escaped <, & and >").text == "escaped <, & and >"
    check $h("div", "escaped <, & and >") == "<div>escaped &lt;, &amp; and &gt;</div>"

  test "HTML entities are escaped in attributes":
    check h("div", class = "escaped \" and possibly '", "content") is Element
    check h("div", class = "escaped \" and possibly '", "content").tag == "div"
    check h("div", class = "escaped \" and possibly '", "content").attr(
        "class") == "escaped \" and possibly '"
    check h("div", class = "escaped \" and possibly '", "content").text == "content"
    check $h("div", class = "escaped \" and possibly '", "content") == "<div class=\"escaped &quot; and possibly '\">content</div>"


suite "Special attributes and children":
  test "can use {} to set attributes":
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"},
        "hyperscript") is Element
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"},
        "hyperscript").tag == "a"
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"},
        "hyperscript").attr("href") == "https://github.com/schneiderfelipe/hyperscript"
    check h("a", {href: "https://github.com/schneiderfelipe/hyperscript"},
        "hyperscript").text == "hyperscript"

  test "nil attributes are ignored":
    # TODO: we should define some kind of precedence, i.e., *remove attribute*
    # if the last value received is nil.
    check h("a", {href: nil}, "hyperscript") is Element
    check h("a", {href: nil}, "hyperscript").len == 1
    check h("a", {href: nil}, "hyperscript").tag == "a"
    check h("a", {href: nil}, "hyperscript").attr("href") == ""
    check h("a", {href: nil}, "hyperscript").text == "hyperscript"


  test "can set boolean attributes":
    check h("input[value=text]", disabled = true) is Element
    check h("input[value=text]", disabled = true).len == 0
    check h("input[value=text]", disabled = true).tag == "input"
    check h("input[value=text]", disabled = true).attr("value") == "text"
    check h("input[value=text]", disabled = true).attr("disabled") == "disabled"

    check h("input[value=text]", disabled = false) is Element
    check h("input[value=text]", disabled = false).len == 0
    check h("input[value=text]", disabled = false).tag == "input"
    check h("input[value=text]", disabled = false).attr("value") == "text"
    # TODO: I find it strange that it returns an empty string. What do D3.js
    # or jQuery return in this case?
    check h("input[value=text]", disabled = false).attr("disabled") == ""


  test "can use [] to set children":
    check h("a", [nil, "some text", h("div")]) is Element
    check h("a", [nil, "some text", h("div")]).len == 2
    check h("a", [nil, "some text", h("div")]).tag == "a"
    check h("a", [nil, "some text", h("div")]).text == "some text"
    # check h("a", [nil, "some text", h("div")])[0].text == "some text"  # We currently don't support getting text of text nodes
    check h("a", [nil, "some text", h("div")])[1] === h("div")

  test "nil children are ignored":
    check h("a", nil, "some text") is Element
    check h("a", nil, "some text").len == 1
    check h("a", nil, "some text").tag == "a"
    check h("a", nil, "some text").text == "some text"
    # check h("a", nil, "some text")[0].text == "some text"  # We currently don't support getting text of text nodes


suite "Using selector notation":
  test "can indicate an id":
    check h("div#header") is Element
    check h("div#header").tag == "div"
    check h("div#header").attr("id") == "header"

  test "the last given id takes precedence":
    check h("div#header#main") is Element
    check h("div#header#main").tag == "div"
    check h("div#header#main").attr("id") == "main"

  test "can indicate a class":
    check h("div.header") is Element
    check h("div.header").tag == "div"
    check h("div.header").attr("class") == "header"

  test "the last given class takes precedence":
    check h("div.header.note") is Element
    check h("div.header.note").tag == "div"
    check h("div.header.note").attr("class") == "note"


  test "can indicate an attribute":
    check h("input[type=text]") is Element
    check h("input[type=text]").tag == "input"
    check h("input[type=text]").attr("type") == "text"

  test "can indicate two attributes":
    check h("input[type=text][placeholder=Name]") is Element
    check h("input[type=text][placeholder=Name]").tag == "input"
    check h("input[type=text][placeholder=Name]").attr("type") == "text"
    check h("input[type=text][placeholder=Name]").attr("placeholder") == "Name"


  test "can mix ids, classes and attributes":
    check h("div#header.note") is Element
    check h("div#header.note").tag == "div"
    check h("div#header.note").attr("id") == "header"
    check h("div#header.note").attr("class") == "note"

    check h("div.note#header") is Element
    check h("div.note#header").tag == "div"
    check h("div.note#header").attr("id") == "header"
    check h("div.note#header").attr("class") == "note"

    check h("a#exit.external[href='https://example.com']", "Leave") is Element
    check h("a#exit.external[href='https://example.com']", "Leave").tag == "a"
    check h("a#exit.external[href='https://example.com']", "Leave").attr(
        "id") == "exit"
    check h("a#exit.external[href='https://example.com']", "Leave").attr(
        "class") == "external"
    check h("a#exit.external[href='https://example.com']", "Leave").attr(
        "href") == "https://example.com"
    check h("a#exit.external[href='https://example.com']", "Leave").text == "Leave"


  test "can mix notations":
    check h("div#header", id = "main") is Element
    check h("div#header", id = "main").tag == "div"
    check h("div#header", id = "main").attr("id") == "main"

    check h("div.header", class = "note") is Element
    check h("div.header", class = "note").tag == "div"
    check h("div.header", class = "note").attr("class") == "note"

    check h("a.link[href=/]", {class: "selected"}, "Home") is Element
    check h("a.link[href=/]", {class: "selected"}, "Home").tag == "a"
    check h("a.link[href=/]", {class: "selected"}, "Home").attr("class") == "selected"
    check h("a.link[href=/]", {class: "selected"}, "Home").attr("href") == "/"
    check h("a.link[href=/]", {class: "selected"}, "Home").text == "Home"


  test "can use XML namespaces":
    check h("ns:div#header") is Element
    check h("ns:div#header").tag == "ns:div"
    check h("ns:div#header").attr("id") == "header"


  test "missing tag is div":
    check h("#header") is Element
    check h("#header").tag == "div"
    check h("#header").attr("id") == "header"

    check h(".note") is Element
    check h(".note").tag == "div"
    check h(".note").attr("class") == "note"


suite "Using style notation":
  test "can use inline styles":
    check h("h1", {style: {"background-color": "blue"}}) is Element
    check h("h1", {style: {"background-color": "blue"}}).tag == "h1"
    when not defined(js):
      check h("h1", {style: {"background-color": "blue"}}).style == "background-color: blue;"
    else:
      check h("h1", {style: {"background-color": "blue"}}).style.backgroundColor == "blue"

  test "can mix notations":
    check h("h1", {style: {"background-color": "blue"}},
        style = "text-align: center;") is Element
    check h("h1", {style: {"background-color": "blue"}},
        style = "text-align: center;").tag == "h1"
    when not defined(js):
      check h("h1", {style: {"background-color": "blue"}},
          style = "text-align: center;").style == "background-color: blue; text-align: center;"
    else:
      check h("h1", {style: {"background-color": "blue"}},
          style = "text-align: center;").style.backgroundColor == "blue"
      check h("h1", {style: {"background-color": "blue"}},
          style = "text-align: center;").style.textAlign == "center"

  test "trailing ; is always added":
    check h("h1", style = "text-align: center") is Element
    check h("h1", style = "text-align: center").tag == "h1"
    when not defined(js):
      check h("h1", style = "text-align: center").style == "text-align: center;"
    else:
      check h("h1", style = "text-align: center").style.textAlign == "center"


suite "Assigning events":
  test "can use common anonymous functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: proc(e: HEvent) = debugEcho(
          "you are 1,000,000th savory visitor!"),
    }, "click here to win a savory prize")
    check example is Element
    check example.tag == "a"
    check example.attr("href") == "#"
    check example.text == "click here to win a savory prize"
    when defined(js):
      # Go there and click on the button!
      debugEcho document.body.append example
    else:
      debugEcho h("main").append example

  test "can use sugary functions to assign events":
    let example = h("a", {
      href: "#",
      onclick: (e: HEvent) => debugEcho("you are 1,000,000th sugary visitor!"),
    }, "click here to win a sugary prize")
    check example is Element
    check example.tag == "a"
    check example.attr("href") == "#"
    check example.text == "click here to win a sugary prize"
    when defined(js):
      # Go there and click on the button!
      debugEcho document.body.append example
    else:
      debugEcho h("main").append example


suite "Constructing more complex use cases":
  test "can reproduce the example of <https://github.com/hyperhype/hyperscript#example>":
    # Single quotes became double quotes, the rest is the same as in the original.
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
    check example is Element
    check example.tag == "div"


suite "Modifying simple HTML/SVG tags":
  test "can add an attribute":
    check h("div") is Element
    check h("div").tag == "div"
    check h("div").attr("class") == ""
    check h("div").attr("class", "header").attr("class") == "header"

  test "can add a child":
    check h("div") is Element
    check h("div").tag == "div"
    check h("div").len == 0
    check h("div").append(h("p")).len == 1

  test "can add an event listener":
    check h("a", href: "#", "click me!") is Element
    check h("a", href: "#", "click me!").tag == "a"
    check h("a", href: "#", "click me!").attr("href") == "#"
    check h("a", href: "#", "click me!").text == "click me!"
    when defined(js):
      # Go there and click on the button!
      debugEcho document.body.append h("a", href: "#", "click me!").on("click",
        (e: HEvent) => debugEcho("you clicked!"))
    else:
      debugEcho h("main").append h("a", href: "#", "click me!").on("click",
        (e: HEvent) => debugEcho("you clicked!"))
