$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"

    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.postURL
        method: 'POST'
      debug: true

    ($ '#manualTable').editTable(settings)

    ###
    fields = window.fields
    url = ""

    url = window.postURL

    rows = 1
    columns = fields.length

    # Sets the apropriate validator class for each column
    setValidators = ->
      for i in [0...columns]
        if fields[i].field_type is helpers.get_field_type("Number")
          ($ "input.col#{i}").addClass 'validate_number'
        if fields[i].field_type is helpers.get_field_type("Latitude")
          ($ "input.col#{i}").addClass 'validate_latitude'
        if fields[i].field_type is helpers.get_field_type("Longitude")
          ($ "input.col#{i}").addClass 'validate_longitude'

    setValidators()

    ($ ".add_row_button").click =>
      ($ '#manualTable').append "<tr id=row#{rows}>"
      for i in [0...columns]
        ($ "#row#{rows}").append "<td><input class='col#{i}' style='width:100%' /></td>"

      setValidators()

      rows += 1

    ($ ".submit_manual_data").click ->

      # Don't submit unvalidated data
      if ($ 'input').hasClass 'invalid'
        return

      data_for_upload =
        header: []
        data: []

      # Pack up header data
      data_for_upload.header.push { id: field.id, type:field.field_type } for field in fields

      # Extract data from table
      for row in [0...rows]
        data_for_upload.data[row] = []
        for col in [0...columns]
          data_for_upload.data[row][col] = ($ "#row#{row} td input.col#{col}").val()

      $.ajax url,
        type: 'POST',
        data: { ses_info: data_for_upload },
        success: (data, textStatus, jqXHR) ->
          data = JSON.parse(data)
          helpers.name_dataset data.title, data.datasets, () ->
                window.location = data.redirect
        error: (jqXHR, textStatus, errorThrown) ->
          alert "Somthing went horribly wrong. I'm sorry."###