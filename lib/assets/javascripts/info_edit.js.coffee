$ ->
  $('.info-edit-form').hide()

  ($ '.info_edit_link').click (e) ->
    e.preventDefault()

    # Root div that everything should be in.
    root = ($ @).parents('.edit_info')

    # value should be the current value of the info box
    val = root.find('info-show-value').text()
    val = val.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")

    # href should be /type/id e.g. /users/jim
    href = if ($ @).attr('href')? then ($ @).attr('href') else location.pathname

    # Show and focus the edit box.
    root.find('.info-show-text').hide()
    root.find('.info-edit-form').show()
    root.find('.info_edit_box').focus()

    # Enter key should cause a save
    root.find('.info_edit_box').keypress (e) ->
      if (e.keyCode == 13)
        root.find('.info_save_link').trigger "click"

    # Save button
    root.find('.info-save-button').click (e) ->
      e.preventDefault()

      # Build the data object to send to the controller
      type = root.attr('data-type')
      field_name = root.attr('data-field')
      edit_box = root.find('.info_edit_box')
      value = edit_box.val()
      data = {}
      data[type] = {}
      data[type][field_name] = value

      root.find('i').removeClass 'icon-ok'
      root.find('i').addClass 'icon-refresh'
      root.find('span.btn').addClass 'disabled'
      root.find('span.btn').button 'toggle'

      edit_box.popover "destroy"

      # Make the request to update
      $.ajax
        url: href
        type: "PUT"
        dataType: "json"
        data:
          data
        success: ->
          # Update text
          val = root.find('.info_edit_box').val()
          root.find('.info-show-value').text(val)

          # Swap save and edit links
          root.find('.info-show-text').show()
          root.find('.info-edit-form').hide()

        error: (j, s, t) ->
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
