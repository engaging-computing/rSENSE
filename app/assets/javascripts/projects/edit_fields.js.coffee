$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    ($ '#fields_table' ).keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()
    
    ($ "#fields_table" ).on "click", ".up, .down", ->
      row = $(this).parents("tr:first")
      if $(this).is(".up")
        row.insertBefore(row.prev())
      else
        row.insertAfter(row.next())

    ($ '#number' ).click ->
      addRow(["""<a href="#" class="up"><i class="fa fa-arrow-up"></i></a>&nbsp;<a href="#" class="down"><i class="fa fa-arrow-down"></i></a>""", """<input class="input-small form-control" type="text" name="number" value="Number">""", "Number", """<input class="input-small form-control" type="text" name="units">""", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    ($ '#text' ).click ->
      addRow(["""<a href="#" class="up"><i class="fa fa-arrow-up"></i></a>&nbsp;<a href="#" class="down"><i class="fa fa-arrow-down"></i></a>""", """<input class="input-small form-control" type="text" name="number" value="Text">""", "Text", "", """<input class="input-small form-control" type="text" name="restrictions">""", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])

    ($ '#timestamp' ).click ->
      addRow(["""<a href="#" class="up"><i class="fa fa-arrow-up"></i></a>&nbsp;<a href="#" class="down"><i class="fa fa-arrow-down"></i></a>""", """<input class="input-small form-control" type="text" name="timestamp" value="Timestamp">""", "Timestamp", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById("timestamp").disabled = true

    ($ '#location' ).click ->
      addRow(["""<a href="#" class="up"><i class="fa fa-arrow-up"></i></a><a href="#" class="down"><i class="fa fa-arrow-down"></i></a>""", """<input class="input-small form-control" type="text" name="longitude" value="Longitude">""", "Longitude", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      addRow(["""<a href="#" class="up"><i class="fa fa-arrow-up"></i></a><a href="#" class="down"><i class="fa fa-arrow-down"></i></a>""", """<input class="input-small form-control" type="text" name="latitude" value="Latitude">""", "Latitude", "", "", """<a href="#" class="field_delete"><i class="fa fa-close slick-delete"></i></a>"""])
      document.getElementById("location").disabled = true

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

	addRow = (content) ->
      row = document.getElementById("fields_table").insertRow(1)
      row.name = content[2]
      
      cells = for i in [1...7]
        row.insertCell(i-1)

      for i in [0...6]
        cells[i].innerHTML = content[i]
        
      ($ row).effect("highlight", {}, 3000)

    deleteRow = (row, enable, btn) ->
      document.getElementById("fields_table").deleteRow(row)
      if enable
        document.getElementById(btn).disabled = false