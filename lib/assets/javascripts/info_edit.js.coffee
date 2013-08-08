$ ->
  ($ '.info_edit_link').click (e)->
    e.preventDefault()
  
    #Root div that everything should be in.
    root = ($ @).parents('.edit_info')
   
    #value should be the current value of the info box
    val = root.attr('value')
   
    #href should be /type/id e.g. /users/jim
    href = ($ @).attr('href')

    #The thing that will become a input box
    info_box = root.find('.info_text')
    info_box.html("<div class='input-append'><input type='text' class='info_edit_box input-medium' id='appendInput' value='#{val}'><span class='add-on'><a href='#{href}' class='info_save_link'><i class='icon-ok'></i></a></span></div>")
    root.find('.info_edit_box').focus()
    
    #Hide the edit link
    ($ @).hide()

    info_box.find('a.info_save_link').click (e)->
      e.preventDefault()

      #Build the data object to send to the controller
      type = root.attr('type')
      field_name = root.attr('field')
      edit_box = root.find('.info_edit_box')
      value = edit_box.val()
      data={}
      data[type] = {}
      data[type][field_name] = value
      
      #Make the request to update 
      $.ajax
        url: href
        type: "PUT"
        dataType: "json"
        data:
          data
        success: =>
          
          #Swap save and edit links
          root.find('.info_edit_link').show()
          ($ @).hide()

          root.attr 'value', value
          value = helpers.truncate value, (Number root.attr('trunc'))
          
          #Make it a link or not
          if root.attr('make_link') == 'true'
            info_box.html("<a href='#{($ @).attr('href')}'>#{value}</a>")
          else if root.attr('make_link') == 'false'
            info_box.html(value)
        error: (j, s, t) =>
          edit_box.errorFlash()
          errors = JSON.parse j.responseText
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
    
    #Enter key should cause a save
    info_box.find('.info_edit_box').keypress (e) =>
      if(e.keyCode == 13)
        root.find('a.info_save_link').trigger "click"
    