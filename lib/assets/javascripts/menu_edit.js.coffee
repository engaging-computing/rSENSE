$ ->
  ($ 'a.menu_edit').click (e) ->
    e.preventDefault()
    
    #Root div that everything should be in.
    root = ($ @).parents('span.edit_menu')
    
    #value should be the current value of the info box
    val = root.attr('value')
    
    #href should be /type/id e.g. /users/jim
    href = ($ @).attr('href')
    
    #The thing that will become a input box
    info_box = root.find('.info_text')
    info_box.html("<div class='input-append'><input type='text' class='info_edit_box input' id='appendInput' value='#{val}'><span class='add-on'><a href='#{href}' class='menu_save_link'><i class='icon-ok'></i></a></span></div>")
    info_box.find('.info_edit_box').focus()
    
    #Hide the edit link
    root.find('span.dropdown').hide()
   
    info_box.find('a.menu_save_link').click (e) ->
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
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data: 
          data
        success: =>
                  
          #Swap save and edit links
          root.find('span.dropdown').show()
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
        
    info_box.find('.info_edit_box').keypress (e) ->
      if (e.keyCode is 13)
        root.find('a.menu_save_link').trigger 'click'   
        
        
  ($ 'a.menu_unhider').click (e) ->
    
    e.preventDefault()
    
    root = ($ @).parents('span.edit_menu')
    type = root.attr('type')
    data = {}
    data[type] =
      hidden: false
    
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: "json"
      data: 
        data
      success: =>
        root.find('li.menu_hider').show()
        root.find('li.menu_unhider').hide()
        
  ($ 'a.menu_hider').click (e) ->
    
    e.preventDefault()
    
    root = ($ @).parents('span.edit_menu')
    type = root.attr('type')
    data = {}
    data[type] =
      hidden: true
    
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: "json"
      data: 
        data
      success: =>
        window.location = root.attr("escape_link")
        
  ($ 'a.menu_delete').click (e) ->
    
    e.preventDefault()
    
    root = ($ @).parents('span.edit_menu')
    
    val = root.attr 'value'
    
    if helpers.confirm_delete(val)
      $.ajax
        url: ($ @).attr('href')
        type: 'DELETE'
        dataType: "json"
        success: =>
          window.location = root.attr("escape_link")