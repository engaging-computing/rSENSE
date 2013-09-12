$ ->
  if namespace.controller is "tutorials" and namespace.action is "show"
    
    ($ '#feature_tutorial_dropdown').on 'change', (e) ->
      selected = ($ @).find('option:selected').val()
      if selected != 0
        $.ajax
          url: '/tutorials/switch'
          dataType: 'json'
          type: 'put'
          data:
            tutorial: ($ @).attr('tutorial_id')
            selected: selected
          success: (msg) =>
            location.reload()
          error: (msg) =>
            console.log msg
          