$ ->

    get_redactor_options = (top, path) ->
    
        options = {}
        
        if top.attr('no_upload')
          options = {}
        else
          options = 
            imageUpload: "/media_objects/saveMedia/#{path}"
            fileUpload: "/media_objects/saveMedia/#{path}"
            
        if top.attr('simple')
          options['buttons'] = ['html', '|', 'bold', 'italic', 'deleted', '|', 'link', '|', 'fontcolor', 'backcolor'] 
          
        options

    $('.redactor_content_edit_link').click ->
        top = ($ @).parents('div.redactor_top')
        type = top.attr("type")
        row_id = top.attr("row_id")
        
        top.attr 'saved_content', top.find('.redactor_content').html()
        
        csrf_token = $('meta[name=csrf-token]').attr('content');
        csrf_param = $('meta[name=csrf-param]').attr('content');
        
        path = ""
        if (csrf_param isnt undefined && csrf_token isnt undefined)
          params = csrf_param + "=" + encodeURIComponent(csrf_token);
          path =  "#{type}/#{row_id}?#{params}"
          
        top.find('.redactor_content').redactor get_redactor_options(top, path)
        
        top.find('.pillbox').show()
        top.find('.redactor_content_edit').hide()
    
    ($ '.redactor_content_cancel_link').click ->
      if confirm("Are you sure you want to cancel? All changes will be lost.")
      
        top = ($ @).parents('div.redactor_top')
        saved_content = top.attr 'saved_content'
        
        top.find('.redactor_content').redactor('destroy')
        top.find(".redactor_content").html(saved_content)
        
        top.find('.pillbox').hide()
        
        if saved_content is ""
          ($ ".add_content").parent().show()
        else
          top.find('.redactor_content_edit').show()
        
      false
    
    $('.redactor_content_save_link').click ->
        top = ($ @).parents('div.redactor_top')
        type = top.attr('type')        
        field_name = top.attr('field')
        value = top.find('.redactor_content').redactor('get')
        
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
            top.find('.redactor_content').redactor('destroy')
            
            top.find('.pillbox').hide()
        
            if value is ""
              ($ ".add_content").parent().show()
            else
              top.find('.redactor_content_edit').show()
        false
        
    $('.add_content_link').click ->
        top = ($ @).parents('div.redactor_top')
        
        top.find('.redactor_content').show()
        
        type = top.attr("type")
        row_id = top.attr("row_id")
        
        csrf_token = $('meta[name=csrf-token]').attr('content');
        csrf_param = $('meta[name=csrf-param]').attr('content');
        path = ""
        if (csrf_param isnt undefined && csrf_token isnt undefined)
          params = csrf_param + "=" + encodeURIComponent(csrf_token);
          path =  "#{type}/#{row_id}?#{params}"
        
        top.attr 'saved_content', ""
        
        top.find('.redactor_content').redactor get_redactor_options(top, path)
        top.find('.pillbox').show()
        ($ ".add_content").parent().hide()

