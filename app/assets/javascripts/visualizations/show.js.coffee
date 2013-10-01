$ ->
  if namespace.controller is "visualizations" and namespace.action is "show"
    quickfix = ->
      $(window).resize()
    setTimeout(quickfix, 100)
    false