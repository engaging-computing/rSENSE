   
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
      CKEDITOR.inline elem, filebrowserImageUploadUrl : "/media_objects/saveMedia/#{path}"
      button = root.find('#content_save_button')
      ($ elem).focus ->
        button.show()
      
      button.click =>
        value = root.find('div.content').html()
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
            button.hide()
  
  ($ document).find('.content:visible').each () ->
    turn_on_ck(this)
  
  ($ document).find('.content').each () ->
    root = ($ this).parents('div.content_holder')
    root.find('.add_content_link').click ->
      elem =  root.find('div.content')
      elem.show()
      elem.attr('contenteditable',true)
      ($ this).hide()
      turn_on_ck(elem[0])
      
      
      
  