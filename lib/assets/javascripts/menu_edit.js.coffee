$ ->
  ($ 'a.menu_edit').click (e) ->
    e.preventDefault()
    
    # Root div that everything should be in.
    root = ($ @).parents('span.edit_menu')
    
    # value should be the current value of the info box
    val = root.attr('value')
    val = val.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")
    
    # href should be /type/id e.g. /users/jim
    href = ($ @).attr('href')
    
    # The thing that will become a input box
    info_box = root.find('.info_text')
    info_box.html("""
      <div class='input-group'>
        <input type='text' class='info_edit_box form-control' value='#{val}'>
        <span class='input-group-btn menu_save_link' href='#{href}'>
          <button class="btn btn-success" type="button"><i class='fa fa-floppy-o icon-white'></i></button>
        </span>
      </div>""")
    info_box.find('.info_edit_box').focus()
    
    # Hide the edit link
    root.find('span.dropdown').hide()
   
    # Save on enter
    info_box.on 'keypress', (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if code == 13
        ($ this).find('.menu_save_link').trigger 'click'
    
    info_box.find('.menu_save_link').click (e) ->
      e.preventDefault()
      
      # Build the data object to send to the controller
      type = root.attr('type')
      field_name = root.attr('field')
      edit_box = root.find('.info_edit_box')
      value = edit_box.val()
      data = {}
      data[type] = {}
      data[type][field_name] = value
      
      root.find('i').removeClass 'icon-ok'
      root.find('i').addClass 'icon-refresh'
      root.find('span.btn').addClass 'disabled'
      root.find('span.btn').button 'toggle'
        
      # Make the request to update
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data:
          data
        success: =>
                  
          # Swap save and edit links
          root.find('span.dropdown').show()
          ($ @).hide()
          
          root.attr 'value', value
        
          # Make it a link or not
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
        complete: () ->
          root.find('i').addClass 'icon-ok'
          root.find('i').removeClass 'icon-refresh'
          root.find('span.btn').removeClass 'disabled'
          root.find('span.btn').button 'toggle'
        
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
        ($ '#hidden_notice').hide()
        
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

  ### Curate Project ###
  ($ 'a.menu_curate').click (e) ->
    e.preventDefault()
    root = ($ @).parents('span.edit_menu')
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: 'json'
      data:
        project:
          curated: true
      success: =>
        root.find('li.menu_unlock').show()
        root.find('li.menu_lock').hide()
        ($ '#lock_notice').show()
        ($ '#id_notice').hide()
        root.find('li.menu_curate').hide()
        root.find('li.menu_uncurate').show()
      error: (msg) =>
        console.log msg
        
  ### Uncurate Project ###
  ($ 'a.menu_uncurate').click (e) ->
    e.preventDefault()
    root = ($ @).parents('span.edit_menu')
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: 'json'
      data:
        project:
          curated: false
      success: =>
        root.find('li.menu_curate').show()
        root.find('li.menu_uncurate').hide()
      error: (msg) =>
        console.log msg
        
  ### LOCK PROJECT ###
  ($ 'a.menu_lock').click (e) ->
    e.preventDefault()
    root = ($ @).parents('span.edit_menu')
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: 'json'
      data:
        project:
          lock: true
      success: =>
        root.find('li.menu_unlock').show()
        root.find('li.menu_lock').hide()
        ($ '#lock_notice').show()
        ($ '#id_notice').hide()
      error: (msg) =>
        console.log msg
        
  ### UNLOCK PROJECT ###
  ($ 'a.menu_unlock').click (e) ->
    e.preventDefault()
    root = ($ @).parents('span.edit_menu')
    $.ajax
      url: ($ @).attr('href')
      type: 'PUT'
      dataType: 'json'
      data:
        project:
          lock: false
      success: =>
        root.find('li.menu_lock').show()
        root.find('li.menu_unlock').hide()
        ($ '#lock_notice').hide()
      error: (msg) =>
        console.log msg
        
  ($ 'a.summary_edit').click (e) ->
    e.preventDefault()
    root = ($ @).parents("span.edit_menu")
    summary = root.find('.summary')
    summary_text = summary.html()
    type = summary.attr("type")
    summary_input = $ """
      <div class="row">
        <div class="col-md-8">
          <div class='input-group'>
            <textarea id="appendInput" autofocus class='form-control'
              rows='3' style='resize:none;overflow:hidden' maxlength='256'>
                #{summary_text.trim()}</textarea>
            <span class='input-group-btn btn btn-success summary_save' href=''>
              <i class='fa fa-floppy-o'></i></span>
          </div>
        </div>
      </div>
      """
    summary.html(summary_input)
    btn_height = summary.find('textarea').height()
    summary.find('.btn-success').height(btn_height)
    summary_input.find('.summary_save').click (e) ->
      e.preventDefault()
      txt = ($ @).parents('.input-group').find('textarea').val()
      data = {}
      data[type] = {}
      data[type]['summary'] = txt
      $.ajax
        url: ''
        type: 'PUT'
        dataType: 'json'
        data: data
        success: =>
          ($ @).parents('.summary').html(txt)
        error: (msg) =>
          console.log msg
