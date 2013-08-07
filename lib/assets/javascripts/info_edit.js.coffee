$ ->
  ($ '.info_edit_link').click ->
    val = ($ @).parent().attr('value')
    href = ($ @).attr('href')

    info_box = ($ @).siblings('.info_text')
    info_box.html("<div class='input-append'><input type='text' class='info_edit_box input' id='appendInput' value='#{val}'><span class='add-on'><a href='#{href}' class='info_save_link'><i class='icon-ok'></i></a></span></div>")
    info_box.children('.info_edit_box').focus()
    save_link = ($ @)
    save_link.hide()
    

    info_box.find('a.info_save_link').click (e)->
      e.preventDefault()
      
      #Get the parts 
      top = $(@).parent().parent().parent().parent()
      type = top.attr('type')
      field_name = top.attr('field')
      info_box = top.find('.info_text')
      edit_box = info_box.find('.info_edit_box')
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
          save_link.show()
          ($ @).hide()
          
          top.attr 'value', value
          value = helpers.truncate value, (Number top.attr('trunc'))
          if ($ @).parent().parent().parent().parent().attr('make_link') == 'true'
            info_box.html("<a href='#{($ @).attr('href')}'>#{value}</a>")
          else if ($ @).parent().parent().parent().parent().attr('make_link') == 'false'
            info_box.html(value)
        error: (j, s, t) =>
          edit_box.errorFlash()
          
          errors = JSON.parse j.responseText
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
      
    ($ '.info_edit_box').keypress (e) =>
      if(e.keyCode == 13)
        save_link.trigger "click"
    