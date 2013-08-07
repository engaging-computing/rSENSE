$ ->

  ($ 'a.menu_edit').click (e) ->
    
    e.preventDefault()
    
    top = ($ @).parents('span.edit_menu')
    info_box = top.find('.info_text')
    href = ($ @).attr('href')
    val = top.attr 'value'
    info_box.html("<div class='input-append'><input type='text' class='info_edit_box input' id='appendInput' value='#{val}'><span class='add-on'><a href='#{href}' class='menu_save_link'><i class='icon-ok'></i></a></span></div>")
    info_box.find('.info_edit_box').focus()
    
    top.find('span.dropdown').hide()
    top.find('a.menu_save_link').show()
   
    info_box.find('a.menu_save_link').click (e) ->
      e.preventDefault()
      
      top = ($ @).parents('span.edit_menu')
      type = top.attr('type')
      info_box = top.find('.info_text')
      edit_box = info_box.find('.info_edit_box')
      
      value = edit_box.val()
      data = {}
      data[type] = 
        title: value
        
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data: 
          data
        success: =>
          top.find('span.dropdown').show()
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
        
    info_box.find('.info_edit_box').keypress (e) ->
      if (e.keyCode is 13)
        top.find('a.menu_save_link').trigger 'click'   
        
        
  ($ 'a.menu_unhider').click (e) ->
    
    e.preventDefault()
    
    top = ($ @).parents('span.edit_menu')
    type = top.attr('type')
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
        top.find('li.menu_hider').show()
        top.find('li.menu_unhider').hide()
        
  ($ 'a.menu_hider').click (e) ->
    
    e.preventDefault()
    
    top = ($ @).parents('span.edit_menu')
    type = top.attr('type')
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
        window.location = top.attr("escape_link")
        
  ($ 'a.menu_delete').click (e) ->
    
    e.preventDefault()
    
    top = ($ @).parents('span.edit_menu')
    
    val = top.attr 'value'
    
    if helpers.confirm_delete(val)
      $.ajax
        url: ($ @).attr('href')
        type: 'DELETE'
        dataType: "json"
        success: =>
          window.location = top.attr("escape_link")