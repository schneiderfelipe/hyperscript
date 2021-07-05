import hyperscript

# BUG: This is nice, but code is being repeated in the output!

var
  state = 0
  display = h("div")
discard document.body.append h("div",
  h("button", "-").on("click") do (ev: HEvent):
  state -= 1
  discard display.text $state
,
  display,
  h("button", "+").on("click") do (ev: HEvent):
  state += 1
  discard display.text $state
)

when not defined(js):
  debugEcho document
