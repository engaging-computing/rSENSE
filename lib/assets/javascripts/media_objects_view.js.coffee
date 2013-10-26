$ ->
  ($ '.upload_media').find('input:file').change (event) ->
      event.preventDefault()
      ($ this).parents('form').submit()
     
  ($ '#filechooser').click (event) ->
    event.preventDefault()

    ($ @).parents('div').find('#upload').click()
    false
  
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
      url: ""
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
    
  ($ '.mo_image a').click (e) ->
    e.preventDefault()
    src = ($ @).attr("href")
    ($ '#mo_image_modal').find('#mo_image').html("<img src='#{src}' ></img>")
    ($ '#mo_image_modal').modal()