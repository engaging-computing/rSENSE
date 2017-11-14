setupMediaObjectsView = () ->
  ($ '.upload_media').find('input:file').change (event) ->
    event.preventDefault()
    ($ this).parents('form').submit()

  Dropzone.options.upload = {
    paramName: "upload",
    init: () ->
      this.on("complete",(file) ->
        if (this.getUploadingFiles().length is 0 && this.getQueuedFiles().length is 0)
          location.reload()
      )
  }

  # Selection of featured image
  img_selector_click = (obj) ->
    root = ($ '#media_object_list')
    type_id = obj.attr("obj_id")
    type = root.attr("data-type")
    mo = if obj.prop("checked") == false then null else obj.attr("mo_id")
    old_mo = root.find('table > tbody > tr > td input[checked]')

    data = {}
    data[type] = {}
    data[type]["featured_media_id"] = mo

    $.ajax
      url: ""
      type: "PUT"
      dataType: "json"
      data:
        data
      error: (j, s, t) ->
        root.find('.img_selector').each ->
          ($ this).prop("checked", false)
        old_mo.prop("checked", true)
        quickFlash(JSON.parse(j.responseText), 'error')
      success: ->
        root.find('.img_selector').each ->
          if ($ this).attr("mo_id") != mo
            ($ this).prop("checked", false)

  $('.img_selector').click ->
    img_selector_click ($ @)

$(document).ready ->
  if $('.upload_media')?
    setupMediaObjectsView()
