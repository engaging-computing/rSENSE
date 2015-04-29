$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    # Variables to keep track of number of different fields added
    num_count = text_count = timestamp_count = location_count = 0
    display_num_count = get_next_name("Number")

    # Array of fids of fields to be deleted
    deleted_fields = []

    # Names of all hidden inputs that need to be populated before submission
    input_boxes = ['hidden_num_count', 'hidden_text_count', 'hidden_timestamp_count',
                   'hidden_location_count', 'hidden_deleted_fields']

    # Clear all hidden inputs on load
    for i in [0...5]
      setValue(input_boxes[i], '')

    # Submit form on enter
    $('#fields_table').keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        $('#fields_form_submit').click()

    # Add row(s), increment counters, disable add buttons (for timestamp/location fields)
    # addRow takes input box for name, type of field, input box for units (number only) or
    # "deg" for lat/long, input box for restrictions (text only), delete
    $('#number').click ->
      num_count = num_count + 1
      display_num_count = display_num_count + 1
      addRow(["""<input class="input-small form-control" type="text"
                 name="number_#{num_count}" value="Number_#{display_num_count}">""", "Number",
                 """<input class="input-small form-control" type="text"
                 name="units_#{num_count}">""", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#text').click ->
      text_count = text_count + 1
      addRow(["""<input class="input-small form-control" type="text"
                 name="text_#{text_count}" value="Text">""", "Text", "",
              """<input class="input-small form-control" type="text"
                 name="restrictions_#{text_count}">""", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#timestamp').click ->
      timestamp_count = timestamp_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="timestamp"
                 value="Timestamp">""", "Timestamp", "", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById('timestamp').disabled = true

    $('#location').click ->
      location_count = location_count + 1
      addRow(["""<input class="input-small form-control" type="text" name="longitude"
                 value="Longitude">""", "Longitude", "deg", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      addRow(["""<input class="input-small form-control" type="text" name="latitude"
                 value="Latitude">""", "Latitude", "deg", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById('location').disabled = true

    # Delete field, enable timestamp/location buttons (NOTE: fid is 0 when the field
    # hasn't yet been added to project in database)
    $('#fields_table').on 'click', '.field_delete', ->
      # fid of row being deleted
      fid = $(this).closest('a').attr('fid')

      # row index of row being deleted
      row_index = $(this).closest('tr').index()

      # row name of row being deleted
      row_name = $(this).closest('tr').attr('name')

      # Decrease counter based on row name
      if row_name == 'latitude' || row_name == 'longitude'
        location_count = 0
      else if row_name == 'number'
        number_count = number_count - 1
      else if row_name == 'text'
        text_count = text_count - 1
      else
        timestamp_count = timestamp_count - 1

      # fid != 0 when the field exists in the database
      if fid != '0'
        hidden_deleted_fields = $('#hidden_deleted_fields')
        if row_name == 'latitude'
          long_fid = parseInt(fid, 10) + 1
          hidden_deleted_fields.val(hidden_deleted_fields.val() + fid + ',' + long_fid + ',')
        else if row_name == 'longitude'
          lat_fid = parseInt(fid, 10) - 1
          hidden_deleted_fields.val(hidden_deleted_fields.val() + fid + ',' + lat_fid + ',')
        else
          hidden_deleted_fields.val(hidden_deleted_fields.val() + fid + ',')
        callDeleteRow(row_index, row_name, fid)
      else
        callDeleteRow(row_index, row_name, '')

    # Populate hidden fields w/ num of fields and array of deleted fields on submit
    $('#fields_form_submit').click ->
      values = [num_count, text_count, timestamp_count, location_count]

      for i in [0...4]
        setValue(input_boxes[i], values[i])

# Adds row to table, highlight new row
addRow = (content) ->
  row = document.getElementById('fields_table').insertRow(1)
  $(row).attr('name', content[1].toLowerCase())

  cells = for i in [1...6]
    row.insertCell(i - 1)

  for i in [0...5]
    cells[i].innerHTML = content[i]

  $(row).effect('highlight', {}, 3000)

# Calls deleteRow based on type of field
callDeleteRow = (row_index, row_name, fid) ->
  if row_name == 'timestamp'
    deleteRow(row_index, true, 'timestamp')
  else if row_name == 'latitude'
    deleteRow(row_index, true, 'location')
    deleteRow(row_index, true, 'location')
  else if row_name == 'longitude'
    deleteRow(row_index, true, 'location')
    deleteRow(row_index - 1, true, 'location')
  else
    deleteRow(row_index, false, '')

# Deletes row (enable is true only when field is timestamp or location; btn is
# timestamp or location or empty string for text/number)
deleteRow = (row_index, enable, btn) ->
  document.getElementById('fields_table').deleteRow(row_index)
  if enable
    document.getElementById(btn).disabled = false

# Set value of hidden input boxes (id is id of hidden input box, value is value
# to set input box)
setValue = (id, value) ->
  document.getElementById(id).value = value
  
get_next_name = (field_type) ->
  count = 0
  table = document.getElementById('fields_table')
  for i in [1...table.rows.length]
    if table.rows[i].cells[1].innerHTML == field_type
      count = count + 1
  return count
