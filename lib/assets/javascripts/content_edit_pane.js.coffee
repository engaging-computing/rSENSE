   
$ ->
  
  csrf_token = $('meta[name=csrf-token]').attr('content');
  csrf_param = $('meta[name=csrf-param]').attr('content');
  
  turn_on_ck = (elem) =>
    root = ($ elem).parents('div.content_holder')
    row_id = ($ elem).attr('row_id')
    type = ($ elem).attr('type')
    field = ($ elem).attr('field')
    can_edit = ($ elem).attr('can_edit')

    path = ""
    if (csrf_param isnt undefined && csrf_token isnt undefined)
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
      path =  "#{type}/#{row_id}?#{params}"
    
    if Boolean(can_edit)
      editor = CKEDITOR.replace elem,
        startupFocus: true
        filebrowserImageUploadUrl:  "/media_objects/saveMedia/#{path}"
      # Save previous value
      root.attr('saved-data',  root.find('div.content').html())
       
      saveButton = root.find('#content_save_button')
      cancelButton = root.find('#content_cancel_button')

      saveButton.show()
      cancelButton.show()
      
      cancelButton.click =>
        editor.destroy()
        root.find('div.content').html(root.attr('saved-data'))
        saveButton.hide()
        cancelButton.hide()
      
      saveButton.click =>
        value = editor.getData()
        data = {}
        data[type] = {}
        data[type][field] = value

        if type == "news"
          url = "/#{type}/#{row_id}"
        else
          url = "/#{type}s/#{row_id}"
  
        $.ajax
          url: url
          type: "PUT"
          dataType: "json"
          data: data
          success: =>
            # Save previous value now that it has updated
            root.attr('saved-data',  editor.getData())
            saveButton.hide()
            cancelButton.hide()
            editor.destroy()
  
  ($ document).find('.content:visible').click () ->
    turn_on_ck(this)
  
  ($ document).find('.content').each () ->
    root = ($ this).parents('div.content_holder')
    root.find('.add_content_link').click ->
      elem =  root.find('div.content')
      elem.show()
      elem.attr('contenteditable',true)
      ($ this).hide()
      turn_on_ck(elem[0])
      elem[0].focus()
      
      
      
  