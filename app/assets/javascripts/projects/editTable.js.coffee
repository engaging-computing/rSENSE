$ ->
  if namespace.controller is "data_sets" and namespace.action is "editTable"
    ($ '#editTable').children().eq(1).children().each ->
      ($ this).children().each ->
        ($ this).click ->
          ($ this).addClass "input"