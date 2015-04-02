$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    ($ '#fields_table').keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()

    ($ '#number').click ->
      addRow("""<input class="input-small form-control" type="text" name="number" value="Number">""", "Number", """<input class="input-small form-control" type="text" name="units">""", "", """<a href="#" id="#{num}" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""")

    ($ '#text').click ->
      addRow("""<input class="input-small form-control" type="text" name="number" value="Text">""", "Text", "", """<input class="input-small form-control" type="text" name="restrictions">""", """<a href="#" id="#{num}" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""")

    ($ '#timestamp').click ->
      addRow("""<input class="input-small form-control" type="text" name="timestamp" value="Timestamp">""", "Timestamp", "", "", """<a href="#" id="#{num}" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""")

    ($ '#location').click ->
      addRow("""<input class="input-small form-control" type="text" name="longitude" value="Longitude">""", "Longitude", "", "", """<a href="#" id="#{num}" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""")
      addRow("""<input class="input-small form-control" type="text" name="latitude" value="Latitude">""", "Latitude", "", "", """<a href="#" id="#{num}" class="field_delete"><i class="fa fa-close slick-delete"></i></a>""")

	addRow = (cellContent1, cellContent2, cellContent3, cellContent4, cellContent5) ->
      row = document.getElementById("fields_table").insertRow(1)
      num = num + 1
      cell1 = row.insertCell(0)
      cell2 = row.insertCell(1)
      cell3 = row.insertCell(2)
      cell4 = row.insertCell(3)
      cell5 = row.insertCell(4)
      cell1.innerHTML = cellContent1
      cell2.innerHTML = cellContent2
      cell3.innerHTML = cellContent3
      cell4.innerHTML = cellContent4
      cell5.innerHTML = cellContent5
      
    ($ '.field_delete').click ->
    