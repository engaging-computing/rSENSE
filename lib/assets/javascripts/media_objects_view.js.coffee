$ ->
  
  #selection of featured image
  img_selector_click = (obj) ->
    root = ($ '#media_object_list')
    type_id = obj.attr("obj_id")
    type = root.attr("type") 
    mo = if obj.prop("checked") == false then null else obj.attr("mo_id")

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
  
  ($ '.img_selector').click ->
    img_selector_click ($ @)
    
  #Delete Media Object
  delete_media_object = (obj) ->
   if helpers.confirm_delete obj.attr('name')
      $.ajax
        url: obj.attr("href")
        type: 'DELETE'
        dataType: "json"
        success: =>
          recolored = false
          row = obj.parents('tr')
          tbody = row.parents('tbody')
          row.delete_row =>
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true
          
    
  ($ 'a.media_object_delete').click (e) ->
    e.preventDefault()
    delete_media_object ($ @)
    
   
 
  add_media_object = (dom_element,obj) ->
    root = ($ '#media_object_list')
    table = root.find('#media_table')
    object_id = root.attr("obj_id")

    htmlStr =$ """
    <tr><td id='media_icon'><div><img src="#{obj.mo.tn_src}" width="32" height="32"></div></td>
    <td style="max-width:150px"><div class="truncate"><a href="#{obj.mo.src}">#{obj.filename}</div></td>
    <td><div class="controls"><a href="/media_objects/#{obj.mo.id}">Edit</a> | <a class='media_object_delete' href='/media_objects/#{obj.mo.id}' name=#{obj.mo.name}>Delete</a></div></td>
    <td><div class="center">#{if obj.mo.mediaType == "image" then "<input type='checkbox' class='img_selector' name='img_selector' obj_id='#{object_id}' mo_id='#{obj.mo.id}'></input>" else ""}</div></td>
    </tr>  
    """
    delete_btn = htmlStr.find(".media_object_delete")
    img_select = htmlStr.find(".img_selector")
    
    delete_btn.click (e) ->
      e.preventDefault()
      delete_media_object ($ @)
      
    img_select.click (e) ->
      img_selector_click ($ @)
      
    table.append htmlStr
    recolor_rows()
  
   
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
      fileUploadCallback: (x,y) ->
        add_media_object(x,y)
        true
      imageUploadCallback: (x,y) ->
        add_media_object(x,y)
        true
      
    
    root.find('.redactor_file_upload_hidden').redactor options
    root.find('.redactor_toolbar').hide()
    root.find('.redactor_btn_image').trigger("click")
    $('.redactor_tabs_act').siblings("a").hide() #Hide the link tab for media upload