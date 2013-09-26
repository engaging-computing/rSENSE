$ ->

    get_redactor_options = (top, path) ->
    
        options = {deniedTags: ['script','applet','iframe'], clearTags: ['script','applet','iframe'],imageUpload: "/media_objects/saveMedia/#{path}",fileUpload: "/media_objects/saveMedia/#{path}"}
        
        if top.attr('no_upload')
          options = {deniedTags: ['script','applet','iframe'], clearTags: ['script','applet','iframe']}

        if top.attr('simple')
          options['buttons'] = ['html', '|', 'bold', 'italic', 'deleted', '|', 'link', '|', 'fontcolor', 'backcolor'] 
          
        options

    #This is an evil fix for a redactor/webkit bug. I can fix it in redactors js but it would break on the next update.    
    set_background_white = () =>
      ($ '.redactor_content').css('background-color','white')
      
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
        setTimeout(set_background_white, 100);
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
          top.find('.add_content').show()
          top.find('.redactor_content').hide()
        else
          top.find('.redactor_content_edit').show()
        
      false
    
    $('.redactor_content_save_link').click ->
        top = ($ @).parents('div.redactor_top')
        type = top.attr('type')        
        field_name = top.attr('field')
        top.find('.redactor_content').redactor('toggle')
        value = top.find('.redactor_content').redactor('get')

        data={}
        data[type] = {}
        data[type][field_name] = value
        
        top.find(".redactor_content_cancel_link").addClass 'disabled'
        top.find(".redactor_content_save_link").addClass 'disabled'
        
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
              top.find('.add_content').show()
            else
              top.find('.redactor_content_edit').show()
          complete: ->
            top.find(".redactor_content_cancel_link").removeClass 'disabled'
            top.find(".redactor_content_save_link").removeClass 'disabled'
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
        setTimeout(set_background_white,100)
        top.find('.pillbox').show()
        top.find('.add_content').hide()

