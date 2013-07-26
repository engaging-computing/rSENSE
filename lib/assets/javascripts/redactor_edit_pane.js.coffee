
$(document).ready ->
    $('.redactor_content_edit_link').click ->
        window.saved_content = ($ '.redactor_content').html()
        tmp = ($ @).parent().parent()
        type = tmp.attr("type")
        row_id = tmp.attr("row_id")
        csrf_token = $('meta[name=csrf-token]').attr('content');
        csrf_param = $('meta[name=csrf-param]').attr('content');
        path = ""
        if (csrf_param isnt undefined && csrf_token isnt undefined)
          params = csrf_param + "=" + encodeURIComponent(csrf_token);
          path =  "#{type}/#{row_id}?#{params}"
        $(@).parent().parent().find('.redactor_content').redactor
          imageUpload: "/media_objects/saveMedia/#{path}"
          fileUpload: "/media_objects/saveMedia/#{path}"
        $(@).siblings('.redactor_content_save_link').show();
        $(@).siblings('.redactor_content_cancel_link').show();
        $(@).hide();
    
    ($ '.redactor_content_cancel_link').click ->
      r = confirm("This will remove any changes since the last save. Are you sure?")
      if r == true
        ($ @).parent().parent().find('.redactor_content').redactor('destroy')
        ($ @).siblings('.redactor_content_save_link').hide();
        ($ @).siblings('.redactor_content_edit_link').show();
        ($ @).hide()
        ($ ".redactor_content").html(window.saved_content)
      false
    
    $('.redactor_content_save_link').click ->
        type = $(@).parent().parent().attr('type')
        $(@).siblings('.redactor_content_edit_link').show()
        $(@).siblings('.redactor_content_cancel_link').hide()
        $(@).hide()
        
        field_name = $(@).parent().parent().attr('field')
        value = $(@).parent().parent().find('.redactor_content').redactor('get')
        data={}
        data[type] = {}
        data[type][field_name] = value
        
        $.ajax
            url: $(@).attr('href')
            type: "PUT"
            dataType: "json"
            data:
                data
            success: =>
                $(@).parent().parent().find('.redactor_content').redactor('destroy')
        false
        
    $('.add_content_link').click ->
        $(@).parent().parent().siblings('.redactor_content').show()
        tmp = ($ @).parent().parent()
        type = tmp.attr("type")
        row_id = tmp.attr("row_id")
        csrf_token = $('meta[name=csrf-token]').attr('content');
        csrf_param = $('meta[name=csrf-param]').attr('content');
        path = ""
        if (csrf_param isnt undefined && csrf_token isnt undefined)
          params = csrf_param + "=" + encodeURIComponent(csrf_token);
          path =  "#{type}/#{row_id}?#{params}"
        
        $(@).parent().parent().siblings('.redactor_content').redactor
          imageUpload: "/media_objects/saveMedia/#{path}"
          fileUpload: "/media_objects/saveMedia/#{path}"
        $(@).parent().parent().parent().parent().find('.redactor_content_save_link').show()
        $(@).parent().parent().parent().parent().find('.redactor_content_cancel_link').show()
        $(@).parent().parent().hide()

