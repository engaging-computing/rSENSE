setupMediaObjectsView = () ->
  ($ '.upload_media').find('input:file').change (event) ->
    event.preventDefault()
    ($ this).parents('form').submit()

  ($ '#filechooser').click (event) ->
    event.preventDefault()

    ($ @).parents('div').find('#upload').click()
    false

  # Selection of featured image
  img_selector_click = (obj) ->
    root = ($ '#media_object_list')
    type_id = obj.attr("obj_id")
    type = root.attr("data-type")
    mo = if obj.prop("checked") == false then null else obj.attr("mo_id")

    data = {}
    data[type] = {}
    data[type]["featured_media_id"] = mo

    $.ajax
      url: ""
      type: "PUT"
      dataType: "json"
      data:
        data
      error: ->
        root.find('.img_selector').each ->
          ($ this).prop("checked", false)
      success: ->
        root.find('.img_selector').each ->
          if ($ this).attr("mo_id") != mo
            ($ this).prop("checked", false)

  ($ 'a.media_object_delete').click (e) ->
    e.preventDefault()
    delete_media_object ($ @)

$ ->
  if $('.upload_media')?
    setupMediaObjectsView()
