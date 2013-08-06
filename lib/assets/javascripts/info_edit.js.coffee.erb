$ ->
  ($ '.info_edit_link').click ->
    ($ @).siblings('.info_text').wrapInner('<input type="text" class="info_edit_box" value="'+($ @).parent().attr('value')+'">')
    ($ @).siblings('.info_text').children('.info_edit_box').focus()
    ($ @).hide()
    ($ @).siblings('.info_save_link').show()
    ($ '.info_edit_box').keypress (e) ->
      if(e.keyCode == 13)
        ($ @).parent().parent().find('.info_save_link').trigger "click"

  ($ '.info_save_link').click ->
      type = $(@).parent().attr('type')
      info_box = $(@).siblings('.info_text')
      field_name = $(@).parent().attr('field')
      edit_box = info_box.children('.info_edit_box')
      value = edit_box.val()
      data={}
      data[type] = {}
      data[type][field_name] = value
      
      $.ajax
        url: ($ @).attr('href')
        type: "PUT"
        dataType: "json"
        data:
          data
        success: =>
          ($ @).siblings('.info_edit_link').show()
          ($ @).hide()
          
          ($ @).parent().attr 'value', value
          value = helpers.truncate(value, Number ($ @).parent().attr('trunc'))
          
          if ($ @).parent().attr('make_link') == 'true'
            info_box.html("<a href='#{($ @).attr('href')}'>#{value}</a>")
          else if ($ @).parent().attr('make_link') == 'false'
            info_box.html(value)
        error: (j, s, t) =>
          edit_box.errorFlash()
          
          errors = JSON.parse j.responseText
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
      false
    