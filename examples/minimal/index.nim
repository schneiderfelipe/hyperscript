import hyperscript, macros

expandMacros:
  let example = h("p#example",
    h("input.name[value=Name]",
      style: {"background": "yellow"},
    ),
  )
  # discard document.body.append example
