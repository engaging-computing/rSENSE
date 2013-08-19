$ ->
  
  #selection of featured image
  ($ '.img_selector').click ->
    root = ($ '#media_object_list')
    type_id = ($ @).attr("obj_id")
    type = root.attr("type") 
    mo = if ($ @).prop("checked") == false then "nil" else ($ @).attr("mo_id")

    data={}
    data[type] = {}
    data[type]["featured_media_id"] = mo

    $.ajax
      url: "/#{type}s/#{type_id}"
      type: "PUT"
      dataType: "json"
      data:
        data
      success: =>
        root.find('.img_selector').each ->
          if ($ this).attr("mo_id") != mo
            ($ this).prop("checked", false)
   
  #Hidden redactor upload
  ($ '#redactor_file_upload_btn').click ->
    root = ($ '#media_object_list')
    type_id = root.attr("obj_id")
    type = root.attr("type") 
    
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    
    path = ""
    if (csrf_param isnt undefined && csrf_token isnt undefined)
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
      path =  "#{type}/#{type_id}?#{params}"
    
    options =
      deniedTags: ['script','applet','iframe']
      clearTags: ['script','applet','iframe']
      imageUpload: "/media_objects/saveMedia/#{path}"
      fileUpload: "/media_objects/saveMedia/#{path}"
    
    root.find('.redactor_file_upload_hidden').redactor options
    root.find('.redactor_toolbar').hide()
    root.find(".redactor_btn_image").trigger("click")