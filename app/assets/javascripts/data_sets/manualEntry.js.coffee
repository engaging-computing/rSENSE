$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"
    
    ($ document).ready () ->
      ($ '#manualTable').find('thead').find('tr').prepend(
        "<th style='width:10%;text-align:center'> Row Number </th>"
      )
      ($ '#edit_table_add').click()
      
    #setTimeout (-> ($ '#edit_table_add').click()), 200
  
    settings =
      page_name: "manualEntry"
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/jsonDataUpload"
        method: 'POST'
        error: (j, s, t) =>
          
          ($ '.mainContent').prepend(
            "<div class='alert alert-danger alert-dismissable'><strong>An error occured: </strong>" +
            "Data set names must be unique to their project.</div>"
          )
          
          ($ '#manualTable th').each (header_i, header) ->
            ($ header).wrapInner "<div class='center'></div>"
            
          ($ '#manualTable tr').eq(0).append "<th></th>"
            
          ($ '#manualTable th').slice(0, -1).each (col_i, col) ->
            if ($ col).data('field-restrictions') != ""
              ($ col).find('tr').slice(1).each (row_i, row) ->
                input_options = ""
                ($ col).data('field-restrictions').each (res_i, res) ->
                  p_val = ($ '#manualTable tr').eq(row_i).find('td').eq(col_i).val()
                  if res == p_val
                    input_options += "<option value='#{p_val}' selected>#{p_val}</option>"
                  else
                    input_options += "<option value='#{p_val}'>#{p_val}</option>"
                ($ '#manualTable tr').eq(row_i).find('td').eq(col_i).replaceWith("""<td><div class='center'><select
                    class='form-control'>#{input_options}</select></div></td>""")
            else
              ($ '#manualTable').find('tr').each (row_i, row) ->
                ($ row).find('td').eq(col_i).replaceWith("""<td><div class='center'><input type='text'
                    class='form-control' value='#{ ($ '#manualTable tr').eq(row_i).find('td').eq(col_i).text() }'>
                    </div></td>""")
         
          ($ '#manualTable tr').slice(1).each (row_i, row) ->
            ($ row).append "<td><div class='center'><a class='close' style='float:none;'>&times;</a></div></td>"
            ($ row).find('.close').click ->
              ($ ($ @).closest('tr')).remove()
              rowNum = 1
              ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
                ($ j).find('td:first').text(rowNum)
                rowNum += 1
          ($ '#edit_table_add').removeClass 'disabled'
          ($ '#edit_table_save').button 'reset'
          
          ($ '#manualTable tr').slice(1).each (row_i, row) ->
            update_headers()
            # attach validators
            for col in num_cols
              do (col) ->
                ($ row).children().eq(col).find('input').addClass 'validate_number'

            for col in lat_cols
              do (col) ->
                ($ row).children().eq(col).find('input').addClass 'validate_latitude'

            for col in lon_cols
              do (col) ->
                ($ row).children().eq(col).find('input').replaceWith """
                  <div class='input-group'>
                    <input class='validate_longitude form-control ' id='appendedInput'
                      type='text' value='#{ ($ row).find('input').eq(col-1).val() }' />
                    <span class='input-group-btn'>
                      <a href='#' tabindex='32767' class="btn btn-default map_picker">
                        <i class='fa fa-globe'></i>
                      </a>
                    </span>
                  </div>"""
                ($ row).children().eq(col).find('.map_picker').unbind().click ->
                  ($ this).closest("tr").addClass('target')
                  previous_lon = ($ this).closest('tr').find('.validate_longitude').val()
                  previous_lat = ($ this).closest('tr').find('.validate_latitude').val()
                  if (previous_lat != "") and (previous_lon != "")
                    location = new google.maps.LatLng(previous_lat, previous_lon)
                    window.marker.setPosition(location)
                    window.map.setCenter(location)
                    ($ '#address').val("")
                  ($ '#map_picker').modal()
                  
            for col in text_cols
              do (col) ->
                ($ row).children().eq(col).find('input').addClass 'validate_text'

            for col in time_cols
              do (col) ->
                ($ row).children().eq(col).find('input').replaceWith """
                  <div class='input-group datepicker'>
                    <input class='validate_timestamp  form-control' type='text'
                      data-format='yyyy/MM/dd hh:mm:ss' value='#{ ($ row).find('input').eq(col).val() }' />
                    <span class='input-group-btn'>
                      <a href='#' tabindex='32767' class="btn btn-default">
                        <i class='fa fa-calendar'></i>
                      </a>
                    </span>
                  </div>"""
                ($ row).children().eq(col).find('.datepicker').unbind().datetimepicker()
          ($ '#manualTable').find('thead').find('tr').prepend(
            "<th style='width:10%;text-align:center'> Row Number </th>"
          )
          rowNum = 1
          ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
            ($ j).prepend("<td style='text-align:center;width:10%'>" + rowNum + "</td>")
            rowNum += 1
          
      
        success: (data, textStatus, jqXHR) ->
          window.location = data["displayURL"]

            
             
      debug: false
    ($ '#manualTable').editTable(settings)
    
    num_cols = []
    lat_cols = []
    lon_cols = []
    text_cols = []
    time_cols = []
    
    update_headers = () ->
      # separate columns by field type/validator

      num_cols = []
      lat_cols = []
      lon_cols = []
      text_cols = []
      time_cols = []

      ($ '#manualTable').find('th').each (index) ->
        type = ($ @).attr 'data-field-type'
  
        switch type
          when "Timestamp" then time_cols.push index
          when "Text" then text_cols.push index
          when "Number" then num_cols.push index
          when "Latitude" then lat_cols.push index
          when "Latitude" then add_map()
          when "Longitude" then lon_cols.push index
    
    #$('#manualTable').keypress( (e) ->
      #if( e.which == 13 )
        #e.preventDefault()
      #)
  ($ '#edit_table_add').click () ->
    ($ '#manualTable').find('tbody').find('tr:last').prepend(
      "<td style='width:10%;text-align:center'>" +
      ($ '#manualTable').find('tbody').find('tr').length + "</td>"
    )
  ($ '#manualTable').find('.close').click ->
    rowNum = 1
    ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
      ($ j).find('td:first').text(rowNum)
      rowNum += 1