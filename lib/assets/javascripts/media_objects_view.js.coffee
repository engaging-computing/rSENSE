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