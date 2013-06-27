$ ->
  if namespace.controller is "visualizations" and namespace.action is "show"
    # Control code for name popup box
    if ($ '#name_box') isnt []
      ($ '#name_box').modal();
      selectFunc = ->
        ($ '#name_name').select()
      setTimeout selectFunc, 300
      
      ($ '#name_name').keyup (e) ->
        if (e.keyCode == 13)
          ($ '.name_button').click()
      
      ($ '.name_button').click ->
        name = ($ '#name_name').val()
        data = 
          visualization:
            title: name
            
        $.ajax
          url: ($ 'span.edit_menu .menu_save_link').attr 'href'
          type: 'PUT'
          dataType: 'json'
          data: data
          success: ->
            ($ 'span.edit_menu span.info_text').text(name)
            ($ '#name_box').modal('hide')