$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    # Variables to keep track of number of different fields added
    num_count = text_count = timestamp_count = location_count = 0
    
    # Array of fids of fields to be deleted
    deleted_fields = []
    
    # ids of all hidden inputs that need to be populated before submission
    input_boxes = ["hidden_num_count", "hidden_text_count", "hidden_timestamp_count", "hidden_location_count", "hidden_deleted_fields"]
    
    # Clear all hidden inputs
    for i in [0...5]
      setValue(input_boxes[i], "")

    # Submit form on enter
    ($ '#fields_table' ).keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()

    # Add rows, increment counters, and disable add buttons (for timestamp and location fields)
    ($ '#number' ).click ->
      num_count = num_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="number_#{num_count}" value="Number">""", "Number", """<input class="input-small form-control" type="text" name="units_#{num_count}">""", "", """<a href="#" fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""", "number"])

    ($ '#text' ).click ->
      text_count = text_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="text_#{text_count}" value="Text">""", "Text", "", """<input class="input-small form-control" type="text" name="restrictions_#{text_count}">""", """<a href="#" fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""", "text"])

    ($ '#timestamp' ).click ->
      timestamp_count = timestamp_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="timestamp" value="Timestamp">""", "Timestamp", "", "", """<a href="#" fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""", "timestamp"])
      document.getElementById("timestamp").disabled = true

    ($ '#location' ).click ->
      location_count = location_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="longitude" value="Longitude">""", "Longitude", "", "", """<a href="#" fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""", "longitude"])
      addRow(["""<input class="input-small form-control" type="text" name="latitude" value="Latitude">""", "Latitude", "", "", """<a href="#" fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""", "latitude"])
      document.getElementById("location").disabled = true

    # Delete field, enable timestamp/location buttons (fid is 0 when the field hasn't yet been added)
    ($ "#fields_table" ).on "click", ".field_delete", ->
      fid = ($ this).closest('a').attr('fid')
      row_index = ($ this).closest('tr').index()
      row_name = ($ this).closest('tr').attr('name')
      if row_name == "latitude" || row_name == "longitude"
        location_count = 0
      else
        "#{row_name}_count".to_sym = "#{row_name}_count".to_sym - 1
      if fid != "0"
        hidden_deleted_fields = $('#hidden_deleted_fields')
        hidden_deleted_fields.val(hidden_deleted_fields.val() + fid + ",")
        callDeleteRow(row_index, row_name, fid)
      else
        callDeleteRow(row_index, row_name, "")

    # Populate hidden fields w/ num of fields and array of deleted fields on submit
    ($ '#fields_form_submit').click ->
      values = [num_count, text_count, timestamp_count, location_count]
      
      for i in [0...4]
        setValue(input_boxes[i], values[i])

    # Adds row to table, highlight new row  
	addRow = (content) ->
      row = document.getElementById("fields_table").insertRow(1)
      ($ row).attr('name', content[5])
      
      cells = for i in [1...6]
        row.insertCell(i-1)

      for i in [0...5]
        cells[i].innerHTML = content[i]
        
      ($ row).effect("highlight", {}, 3000)
        
    # Calls deleteRow based on type of input
    callDeleteRow = (row_index, row_name, fid) ->
      if row_name == "timestamp"
        deleteRow(row_index, true, "timestamp")
      else if row_name == "latitude"
        location_count = location_count - 1
        deleteRow(row_index, true, "location")
        deleteRow(row_index, true, "location")
      else if row_name == "longitude"
        location_count = location_count - 1
        deleteRow(row_index, true, "location")
        deleteRow(row_index - 1, true, "location")
      else
        deleteRow(row_index, false, "")

    # Deletes row
    deleteRow = (row, enable, btn) ->
      document.getElementById("fields_table").deleteRow(row)
      if enable
        document.getElementById(btn).disabled = false
        
    # Set value of hidden input boxes
    setValue = (id, value) ->
      document.getElementById(id).value = value