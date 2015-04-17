$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    # Submit form on enter
    ($ '#fields_table' ).keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()
    ###
    FOR MOVING ROWS AROUND
    - Uncomment th on edit_fields.html.erb
    - Uncomment this coffeescript
    - TO DO: add up/down controls to addRow, handle lat/long, add display_id to fields,
             fix indexes in addRow
    ($ "#fields_table" ).on "click", ".up, .down", ->
      row = $(this).parents("tr:first")
      if $(this).is(".up")
        row.insertBefore(row.prev())
      else
        row.insertAfter(row.next())
    ###

    # Variables to keep track num of text/num fields for name purposes
    num_count = 0
    text_count = 0
    timestamp_count = 0
    location_count = 0

    # Add rows, disable buttons, increment counters (depends on field added)
    ($ '#number' ).click ->
      num_count = num_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="number_#{num_count}" value="Number">""", "Number", """<input class="input-small form-control" type="text" name="units_#{num_count}">""", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    ($ '#text' ).click ->
      text_count = text_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="text_#{text_count}" value="Text">""", "Text", "", """<input class="input-small form-control" type="text" name="restrictions">""", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    ($ '#timestamp' ).click ->
      timestamp_count = timestamp_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="timestamp" value="Timestamp">""", "Timestamp", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById("timestamp").disabled = true

    ($ '#location' ).click ->
      location_count = location_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="longitude" value="Longitude">""", "Longitude", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      addRow(["""<input class="input-small form-control" type="text" name="latitude" value="Latitude">""", "Latitude", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById("location").disabled = true

    # Delete field, enable timestamp/location buttons
    ($ "#fields_table" ).on "click", ".field_delete", ->
      row = this.closest('tr').rowIndex
      if this.closest('tr').name == "Timestamp"
        deleteRow(row, true, "timestamp")
      else if this.closest('tr').name == "Latitude"
        deleteRow(row, true, "location")
        deleteRow(row, true, "location")
      else if this.closest('tr').name == "Longitude"
        deleteRow(row, true, "location")
        deleteRow(row - 1, true, "location")
      else
        deleteRow(row, false, "")

    ($ '#fields_form_submit').click ->
      document.getElementById("hidden_num_count").value = num_count
      document.getElementById("hidden_text_count").value = text_count
      document.getElementById("hidden_timestamp_count").value = timestamp_count
      document.getElementById("hidden_location_count").value = location_count

    # Adds rows    
	addRow = (content) ->
      row = document.getElementById("fields_table").insertRow(1)
      row.name = content[1]
      
      cells = for i in [1...6]
        row.insertCell(i-1)

      for i in [0...5]
        cells[i].innerHTML = content[i]
        
      ($ row).effect("highlight", {}, 3000)

    # Deletes rows
    deleteRow = (row, enable, btn) ->
      document.getElementById("fields_table").deleteRow(row)
      if enable
        document.getElementById(btn).disabled = false
