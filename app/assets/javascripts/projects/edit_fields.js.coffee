$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    # Keeps track of number of different fields added
    numCount = textCount = timestampCount = locationCount = 0
    
    # For the number displayed in the input for numbers/text e.g. Number_1
    displayNumCount = getNextName('Number')
    displayTextCount = getNextName('Text')

    # Names of all hidden inputs that need to be populated before submission
    inputBoxes = ['hidden_num_count', 'hidden_text_count', 'hidden_timestamp_count',
                   'hidden_location_count', 'hidden_deleted_fields']

    # Clear all hidden inputs on load
    for i in [0...5]
      setValue(inputBoxes[i], '')

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
      numCount = numCount + 1
      displayNumCount = displayNumCount + 1
      addRow(["""<input class="input-small form-control" type="text"
                 name="number_#{numCount}" value="Number_#{displayNumCount}">""", "Number",
                 """<input class="input-small form-control" type="text" class="units"
                 name="units_#{numCount}">""", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#text').click ->
      textCount = textCount + 1
      displayTextCount = displayTextCount + 1
      addRow(["""<input class="input-small form-control" type="text"
                 name="text_#{textCount}" value="Text_#{displayTextCount}">""", "Text", "",
              """<input class="input-small form-control" type="text" class="restrictions"
                 name="restrictions_#{textCount}">""", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#timestamp').click ->
      timestampCount = timestampCount + 1
      addRow(["""<input class="input-small form-control" type="text" name="timestamp"
                 value="Timestamp">""", "Timestamp", "", "", """<a href="#" fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById('timestamp').disabled = true

    $('#location').click ->
      locationCount = locationCount + 1
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
      fid = $(@).closest('a').attr('fid')

      # Row index of row being deleted
      rowIndex = $(@).closest('tr').index()

      # Row name of row being deleted
      rowName = $(@).closest('tr').attr('name')

      # Decrease counter based on row name
      if rowName == 'latitude' || rowName == 'longitude'
        locationCount = 0
      else if rowName == 'number'
        numberCount = numberCount - 1
      else if rowName == 'text'
        textCount = textCount - 1
      else
        timestampCount = timestampCount - 1

      # fid != 0 when the field exists in the database
      if fid != '0'
        hiddenDeletedFields = $('#hidden_deleted_fields')
        if rowName == 'latitude'
          hiddenDeletedFields.val(hiddenDeletedFields.val() + fid + ',' + (parseInt(fid) + 1) + ',')
        else if rowName == 'longitude'
          hiddenDeletedFields.val(hiddenDeletedFields.val() + fid + ',' + (parseInt(fid) - 1) + ',')
        else
          hiddenDeletedFields.val(hiddenDeletedFields.val() + fid + ',')
        callDeleteRow(rowIndex, rowName, fid)
      else
        callDeleteRow(rowIndex, rowName, '')

    # Populate hidden fields w/ num of fields and array of deleted fields on submit
    $('#fields_form_submit').click ->
      values = [numCount, textCount, timestampCount, locationCount]

      for i in [0...4]
        setValue(inputBoxes[i], values[i])

# Adds row to table, highlight new row
addRow = (content) ->
  row = document.getElementById('fields_table').insertRow(1)
  $(row).attr('name', content[1].toLowerCase())

  cells = for i in [1...6]
    row.insertCell(i - 1)

  for i in [0...5]
    cells[i].innerHTML = content[i]

# Calls deleteRow based on type of field
callDeleteRow = (rowIndex, rowName, fid) ->
  if rowName == 'timestamp'
    deleteRow(rowIndex, true, 'timestamp')
  else if rowName == 'latitude'
    deleteRow(rowIndex, true, 'location')
    deleteRow(rowIndex, true, 'location')
  else if rowName == 'longitude'
    deleteRow(rowIndex, true, 'location')
    deleteRow(rowIndex - 1, true, 'location')
  else
    deleteRow(rowIndex, false, '')

# Deletes row (enable is true only when field is timestamp or location; btn is
# timestamp or location or empty string for text/number)
deleteRow = (rowIndex, enable, btn) ->
  document.getElementById('fields_table').deleteRow(rowIndex)
  if enable
    document.getElementById(btn).disabled = false

# Set value of hidden input boxes (id is id of hidden input box, value is value
# to set input box)
setValue = (id, value) ->
  document.getElementById(id).value = value

# Returns the index for the name of a number or text field
getNextName = (fieldType) ->
  highest = 0
  table = document.getElementById('fields_table')
  for i in [1...table.rows.length]
    if table.rows[i].cells[1].innerHTML == fieldType
      index = 0
      if ((table.rows[i].cells[0].innerHTML.split(' '))[3]).split('_')[1] != undefined
        index = parseInt(((table.rows[i].cells[0].innerHTML.split(' '))[3].split('_'))[1].split('\"'))
        if index > highest
          highest = index
  return highest
