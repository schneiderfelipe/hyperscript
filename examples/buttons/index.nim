import dom


var root = document.createElement("div")
proc view(state: var int, display: Element) =
  display.textContent = $state


var state = 0
let display = document.createElement("div")


let decButton = document.createElement("button")
decButton.textContent = "-"
decButton.addEventListener("click") do (ev: Event):
  state -= 1
  view(state, display)
root.appendChild(decButton)


root.appendChild(display)


let incButton = document.createElement("button")
incButton.textContent = "+"
incButton.addEventListener("click") do (ev: Event):
  state += 1
  view(state, display)
root.appendChild(incButton)


view(state, display)
document.body.appendChild(root)
