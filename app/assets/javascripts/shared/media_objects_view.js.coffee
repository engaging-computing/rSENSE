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

  ($ '.img_selector').click ->
    img_selector_click ($ @)

  # Delete Media Object
  delete_media_object = (obj) ->
    if helpers.confirm_delete obj.attr('name')
      $.ajax
        url: obj.attr("href")
        type: 'DELETE'
        dataType: "json"
        error: (j, s, t) ->
          errors = JSON.parse j.responseText
          $(obj).popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          $(obj).popover 'show'
        success: ->
          recolored = false
          row = obj.parents('tr')
          tbody = row.parents('tbody')
          row.delete_row ->
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true

  ($ 'a.media_object_delete').click (e) ->
    e.preventDefault()
    delete_media_object ($ @)

$ ->
  if $('.upload_media')?
    setupMediaObjectsView()
