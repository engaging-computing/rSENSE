$ ->
  if namespace.controller is 'projects' and (namespace.action in ['edit_fields', 'edit_formula_fields'])
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

    # Make table sortable
    $( '#sortable' ).sortable();

    # Delete field, enable timestamp/location buttons (NOTE: fid is 0 when the field
    # hasn't yet been added to project in database)
    $('#fields_table').on 'click', '.field_delete', ->
      # fid of row being deleted
      fid = $(@).closest('a').attr('fid')

      # Row index of row being deleted
      rowIndex = $(@).closest('tr').index() + 1

      # Row name of row being deleted
      rowName = $(@).closest('tr').attr('name')

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


    $('#fields_form_submit').click (e) ->
      # don't do a form submit
      e.preventDefault()

      # Populate hidden fields w/ num of fields and array of deleted fields on submit
      values = [numCount, textCount, timestampCount, locationCount]

      for i in [0...4]
        setValue(inputBoxes[i], values[i])

      # add hidden input for each field with it's position
      t = document.getElementById('fields_table')
      for i in [1...t.rows.length]
        field_id = t.rows[i].cells[5].getElementsByTagName('a')[0].getAttribute('fid')
        # This is for new fields that do not have an id yet
        if field_id == '0'
          field_id = t.rows[i].cells[1].getElementsByTagName('input')[0].getAttribute('name')
        input = $("<input type='hidden' name='#{field_id}_index' value='#{i - 1}' />")
        $('#hidden_index_inputs').append(input)

      # construct a JSON object to send the server via AJAX
      formData = {}
      form = $('form[name="fields_form"]')
      form.serializeArray().map (x) ->
        formData[x.name] = x.value

      # disable some buttons so we can't hit save multiple times
      $('#fields_form_submit, #fields_form_cancel').addClass 'disabled'
      $('#fields_form_submit').val 'Saving...'

      # send the form data to try and create the field
      $.ajax
        type: 'POST'
        url: form.attr('action')
        data: formData
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          window.location = data.redirect
        error: (jqXHR, textStatus, errorThrown) ->
          showErrors(jqXHR.responseJSON.errors)
          $('#fields_form_submit, #fields_form_cancel').removeClass 'disabled'
          $('#fields_form_submit').val 'Save and Return'


  if namespace.controller is 'projects' and namespace.action is 'edit_fields'
    # Add row(s), increment counters, disable add buttons (for timestamp/location fields)
    # addRow takes input box for name, type of field, input box for units (number only) or
    # "deg" for lat/long, input box for restrictions (text only), delete
    $('#number').click ->
      numCount = numCount + 1
      displayNumCount = displayNumCount + 1
      addRow(["""<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>""",
             """<input class="input-small form-control" type="text"
                 name="number_#{numCount}" value="Number_#{displayNumCount}">""", "Number",
                 """<input class="input-small form-control" type="text" class="units"
                 name="units_#{numCount}">""", "", """<a fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#text').click ->
      textCount = textCount + 1
      displayTextCount = displayTextCount + 1
      addRow(["""<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>""",
             """<input class="input-small form-control" type="text"
                 name="text_#{textCount}" value="Text_#{displayTextCount}">""", "Text", "",
                 """<input class="input-small form-control" type="text" class="restrictions"
                 name="restrictions_#{textCount}">""", """<a fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    $('#timestamp').click ->
      timestampCount = timestampCount + 1
      addRow(["""<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>""",
             """<input class="input-small form-control" type="text" name="timestamp"
                 value="Timestamp">""", "Timestamp", "", "", """<a fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById('timestamp').disabled = true

    $('#location').click ->
      locationCount = locationCount + 1
      addRow(["""<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>""",
             """<input class="input-small form-control" type="text" name="longitude"
                 value="Longitude">""", "Longitude", "deg", "", """<a fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      addRow(["""<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>""",
             """<input class="input-small form-control" type="text" name="latitude"
                 value="Latitude">""", "Latitude", "deg", "", """<a fid="0"
                 class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById('location').disabled = true

  if namespace.controller is 'projects' and namespace.action is 'edit_formula_fields'
    # Add row(s), increment counters, disable add buttons (for timestamp/location fields)
    # addRow takes input box for name, type of field, input box for units (number only) or
    # "deg" for lat/long, input box for restrictions (text only), delete
    $('#number').click ->
      numCount = numCount + 1
      displayNumCount = displayNumCount + 1
      addRow(['<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>',
              """<input class="input-small form-control" type="text"
                name="number_#{numCount}" value="Formula_Number_#{displayNumCount}">""",
              "Number",
              """<input class="input-small form-control" type="text" class="units" name="units_#{numCount}">""",
              """<a class="field_edit_formula" fid="0" data-toggle="modal" data-target=".modal">
                   <i class="fa fa-pencil-square-o slick-delete"></i>
                 </a>
                 <input type="hidden" class="formula" name="nformula_#{numCount}" value="">
                 <input type="hidden" class="refname" value="???">""",
              '<a fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>'])

    $('#text').click ->
      textCount = textCount + 1
      displayTextCount = displayTextCount + 1
      addRow(['<i class="sort-hamburger glyphicon glyphicon-menu-hamburger"></i>',
              """<input class="input-small form-control" type="text"
                name="text_#{textCount}" value="Formula_Text_#{displayTextCount}">""",
              'Text',
              '',
              """<a class="field_edit_formula" fid="0" data-toggle="modal" data-target=".modal">
                   <i class="fa fa-pencil-square-o slick-delete"></i>
                 </a>
                 <input type="hidden" class="formula" name="tformula_#{textCount}" value="">
                 <input type="hidden" class="refname" value="???">""",
              '<a fid="0" class="field_delete"><i class="fa fa-close slick-delete"></i></a>'])

    # jQuery event for opening the formula edit modal
    $('#fields_table').on 'click', '.field_edit_formula', ->
      generateRefNames($(this).closest('tr').index())
      $hiddenField = $(this).parent().children('input.formula')
      contents = $hiddenField.val()
      $formulaText = $('#formula-text')
      $formulaText.val(contents)
      $formulaText.data('onClose', $hiddenField)

    # jQuery event for closing the formula edit modal and saving the changes
    $('#formula-save').click ->
      contents = $('#formula-text').val()
      $hiddenField = $('#formula-text').data('onClose')
      $hiddenField.val(contents)
      $('.modal').modal('hide')

# Adds row to table, highlight new row
addRow = (content) ->
  row = document.getElementById('sortable').insertRow(0)
  $(row).attr('name', content[2].toLowerCase())

  cells = for i in [1...7]
    row.insertCell(i - 1)

  for i in [0...6]
    cells[i].innerHTML = content[i]

  $(row).highlight(500)

# Calls deleteRow based on type of field
callDeleteRow = (rowIndex, rowName, fid) ->
  if rowName == 'timestamp'
    deleteRow(rowIndex, true, 'timestamp')

  else if rowName == 'latitude'
    t = document.getElementById('fields_table')
    deleteRow(rowIndex, true, 'location')
    for i in [1...t.rows.length]
      if t.rows[i].cells[2].innerHTML.trim() == 'Longitude'
        deleteRow(i, true, 'location')

  else if rowName == 'longitude'
    t = document.getElementById('fields_table')
    deleteRow(rowIndex, true, 'location')
    for i in [1...t.rows.length]
      if t.rows[i].cells[2].innerHTML.trim() == 'Latitude'
        deleteRow(i, true, 'location')

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
  if namespace.action == 'edit_formula_fields'
    fieldType = 'Formula_' + fieldType

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

# Given the names of the formula fields, compute which refnames are available to
#   each formula
# This function depends on the DOM representation of the field edit table, so
#   modifying that will most likely break this function.  This is not ideal, but
#   the correct way of implementing something like this is more or less
#   incompatible with the site's current implementation
generateRefNames = (index) ->
  ffRefs = $('#formula-field-refs')
  fTable = $('#fields_table > tbody > tr')

  ffRefs.empty()

  fTable.each (i) ->
    if i <= index
      row = $(this)
      name = row.find('td:nth-child(2) > input').val().trim()
      type = row.find('td:nth-child(3)').text().trim()
      refName = row.find('.refname').val().trim()
      newRow = $("<tr><td>#{name}</td><td>#{refName}</td><td>#{type}</td></tr>")
      ffRefs.append(newRow)

showErrors = (errors) ->
  $('.mainContent').children('.alert-danger').remove()

  errBold = if errors.length == 1 then 'An error occured: ' else 'Some errors occured: '

  errBody = $('<div class="alert alert-danger alert-dismissable">')
  errBody.append('<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>')
  errBody.append("<strong>#{errBold}</strong>")

  if errors.length == 1
    errItem = $('<span>').text(errors[0])
    errBody.append(errItem)
  else
    errList = $('<ul>')
    errors.forEach (err) ->
      errItem = $('<li>').text(err)
      errList.append(errItem)
    errBody.append(errList)

  $('.mainContent').prepend errBody
