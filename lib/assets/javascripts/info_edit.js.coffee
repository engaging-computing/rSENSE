$ ->
  ($ '.info_edit_link').click (e)->
    e.preventDefault()
    
    #Root div that everything should be in.
    root = ($ @).parents('.edit_info')
   
    #value should be the current value of the info box
    val = root.attr('value')
    val = val.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")

    #href should be /type/id e.g. /users/jim
    href = ($ @).attr('href')

    #The thing that will become a input box
    info_box = root.find('.info_text')
    info_box.html("<div class='input-append'><input type='text' class='info_edit_box input-medium' id='appendInput' value='#{val}'><span class='add-on btn btn-success info_save_link' href='#{href}'><i class='icon-ok icon-white'></i></span></div>")
    root.find('.info_edit_box').focus()
    
    #Hide the edit link
    ($ @).hide()

    #Save on enter
    info_box.on 'keypress', (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if code == 13
        ($ this).find('.info_save_link').trigger 'click'
    
    #Save button
    info_box.find('.info_save_link').click (e)->
      e.preventDefault()

      #Build the data object to send to the controller
      type = root.attr('type')
      field_name = root.attr('field')
      edit_box = root.find('.info_edit_box')
      value = edit_box.val()
      data={}
      data[type] = {}
      data[type][field_name] = value
      
      root.find('i').removeClass 'icon-ok'
      root.find('i').addClass 'icon-refresh'
      root.find('span.btn').addClass 'disabled'
      root.find('span.btn').button 'toggle'

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
          
          #Make it a link or not
          if root.attr('make_link') == 'true'
            info_box.html("<a href='#{($ @).attr('href')}'>#{value}</a>")
          else if root.attr('make_link') == 'false'
            info_box.html(value)
        error: (j, s, t) =>
          edit_box.errorFlash()
          errors = JSON.parse j.responseText
          console.log errors
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
        complete: () ->
          root.find('i').addClass 'icon-ok'
          root.find('i').removeClass 'icon-refresh'
          root.find('span.btn').removeClass 'disabled'
          root.find('span.btn').button 'toggle'
    
    #Enter key should cause a save
    info_box.find('.info_edit_box').keypress (e) =>
      if(e.keyCode == 13)
        root.find('a.info_save_link').trigger "click"
    