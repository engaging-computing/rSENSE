$ ->
  if namespace.controller is "tutorials" and namespace.action is "show"

    ($ '#publish_tutorial').click ->
      $.ajax
        url: ''
        type: 'PUT'
        dataType: 'json'
        data:
          tutorial:
            hidden: !($ @).prop("checked")
        error: (msg) ->
          console.log msg
      
          