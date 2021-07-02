import hyperscript, dom

when isMainModule:
  let example = h("#main", class="note",
    h("p", style: {"background": "yellow"}, "Minimal example"),
  )

  document.body.appendChild(example)
