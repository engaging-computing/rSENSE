$ = jQuery

$ ->
  # Only allows the plugin to run on certain pages. Probably not the right place to do this.
  if (namespace.controller is "data_sets") and (namespace.action is "manualEntry" or namespace.action is "edit")

    #-----------------------------------------------------------------------
    # Map Specific Code
    #-----------------------------------------------------------------------
    for x in window.fields

      #Check if there is location in the experiment
      if x["name"] == "Latitude"
      
        #If there is location add the map picker modal dialog
        ($ ".mainContent").append '<div id="map_picker" class="modal hide fade well container" style="width:400px"><div id="map_canvas" style="width:400px; height:300px"></div><br/><label>Address: </label><input id="address"  type="text"/><button class="btn btn-primary pull-right" id="apply_location">Apply</button></div>'

        #Set up the Map and geocoder
        latlng = new google.maps.LatLng(42.6333,-71.3167)
        options =
          zoom: 16
          center: latlng
        window.map = new google.maps.Map(document.getElementById("map_canvas"), options)

        window.geocoder = new google.maps.Geocoder()

        marker_options =
          map: window.map
          draggable: true

        window.marker = new google.maps.Marker marker_options

        #Event to grab lat/lon when the marker is released on the map
        google.maps.event.addListener window.marker, 'dragend', ->
          window.geocoder.geocode {'latLng': window.marker.getPosition()},(results, status) ->
            if (status == google.maps.GeocoderStatus.OK)
              if (results[0])
                $('#address').val(results[0].formatted_address)

        #Add autocomplete to the dialog with responses from the geocoder.
        ($ "#address").autocomplete
          #This bit uses the geocoder to fetch address values
          source: (request, response) ->
            window.geocoder.geocode {'address': request.term }, (results, status) ->
              response $.map results, (item) ->
                x =
                  label:  item.formatted_address
                  value: item.formatted_address
                  latitude: item.geometry.location.lat()
                  longitude: item.geometry.location.lng()
          #This bit is executed upon selection of an address
          select: (event, ui) ->
            location = new google.maps.LatLng(ui.item.latitude, ui.item.longitude)
            window.marker.setPosition(location)
            window.map.setCenter(location)

        ($ "#address").autocomplete("option", "appendTo", "#map_picker")

        #Maps are dumb and need to be resized if shown in a dynamicly sized window
        ($ '#map_picker').on 'shown', () ->
          google.maps.event.trigger window.map, "resize"

        #What to do when a location is picked
        ($ "#apply_location").click ->
          ($ "#map_picker").modal('hide')
          location = window.marker.getPosition()
         
          ($ '.target').find('.validate_longitude').val(location.lng());
          ($ '.target').find('.validate_latitude').val(location.lat());
          ($ '.target').removeClass('target')
          
        ($ "#map_picker").on "hidden", ->
          ($ '.target').removeClass('target')
    #-----------------------------------------------------------------------
    # End of Map Specific Code
    #-----------------------------------------------------------------------

  $.fn.extend
    editTable: (options) ->
      settings =
        buttons: ['close', 'add', 'save']
        bootstrapify: true
        upload:
          ajaxify: true
          url: "#"
          method: 'PUT'
          success: (data, textStatus, jqXHR) ->
            window.location = data.redirect
          error: (jqXHR, textStatus, errorThrown) ->
            ($ '#edit_table_add').removeClass 'disabled'
            ($ '#edit_table_save').button 'reset'
            log [textStatus, errorThrown]
            alert "An upload error occured."
            
        type: (field) ->
          if field is 1
            "Timestamp"
          else if field is 2
            "Number"
          else if field is 3
            "Text"
          else if field is 4
            "Longitude"
          else if field is 5
            "Latitude"
            
          else if field is "Timestamp"
            1
          else if field is "Number"
            2
          else if field is "Text"
            3
          else if field is "Longitude"
            4
          else if field is "Latitude"
            5
        debug: true

      settings = $.extend settings, options

      log = (msg) ->
        console?.log msg if settings.debug

      return @each ()->

        ### START ###
        # variable to keep track of our table

        table = @
        
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

          ($ table).find('th').each (index) ->
            type = ($ @).attr 'data-field-type'
  
            switch type
              when "Timestamp" then time_cols.push index
              when "Text" then text_cols.push index
              when "Number" then num_cols.push index
              when "Latitude" then lat_cols.push index
              when "Latitude" then add_map()
              when "Longitude" then lon_cols.push index

        ### FUNCTIONS ###
        
        update_headers()

        remove_row = (row) ->
          ($ row).closest('tr').remove()

        add_validators = (row) ->
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
              ($ row).children().eq(col).find('input').replaceWith "<div class='input-append'><input class='validate_longitude input-small' id='appendedInput' type='text' value='#{ ($ row).find('input').eq(col).val() }' /><span class='add-on'><a href='#' ><i class='icon-globe map_picker'></i></a></span></div>"
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
              ($ row).children().eq(col).find('input').replaceWith "<div class='input-append datepicker'><input class='validate_timestamp input-small' type='text' data-format='yyyy/MM/dd hh:mm:ss' value='#{ ($ row).find('input').eq(col).val() }' /><span class='add-on'><a href='#'><i class='icon-calendar'></i></a></span></div>"
              ($ row).children().eq(col).find('.datepicker').unbind().datetimepicker()
              

        add_row = (tab) ->

          # create a string of the new row
          new_row = "<tr class='new_row'>"

          ($ tab).find('th:not(:last-child)').each (index) ->
            new_row += "<td><div class='text-center'><input type='text' class='input-small'/></div></td>"

          new_row += "<td><div class='text-center'><a class='close' style='float:none;'>&times;</a></div></td></tr>"

          # and attach it to our table
          ($ tab).append new_row

          # attach validators
          add_validators ($ '.new_row')

          # bind row removal
          ($ '.new_row').find('.close').click ->
            remove_row(@)

          # bind map button
          ($ '.new_row').find('.map_picker').click ->
            ($ @).closest("tr").addClass('target')
            previous_lon = ($ this).closest('tr').find('.validate_longitude').val()
            previous_lat = ($ this).closest('tr').find('.validate_latitude').val()
            if (previous_lat != "") and (previous_lon != "")
              location = new google.maps.LatLng(previous_lat, previous_lon)
              window.marker.setPosition(location)
              window.map.setCenter(location)
              ($ '#address').val("")
            ($ '#map_picker').modal()
            
          # bind time to input
          ($ '.new_row').find('.datepicker').datetimepicker()

          # remove token
          ($ '.new_row').removeClass('new_row')

        # strip table for upload
        strip_table = (tab) ->
          ($ tab).find('td').has('.input-small').each ->
            ($ @).html ($ @).find('.input-small').val()

          ($ tab).find('th:last-child').empty().remove()

          ($ tab).find('td').has('a.close').each ->
            ($ @).remove()

          ($ tab).find('th').each ->
            ($ @).html ($ @).text()

        # make it pretty and functional the first row.
        wrap_table = (tab) ->
          ($ tab).find('th').each ->
            ($ @).children().wrap "<div class='text-center' />"

          ($ tab).find('td').not(':has(a.close)').each ->
            ($ @).html "<input type='text' class='input-small' value='#{($ @).text()}' />"
            ($ @).children().wrap "<div class='text-center' />"

          ($ tab).find('tr').each ->
            add_validators ($ @)

        submit_form = () ->

          strip_table(table)

          # collect data and ship it off via AJAX
          head = []

          ($ table).find('th').each ->
            head.push ($ @).data('field-id')
            
          row_data = []

          ($ table).find('tr').has('td').each ->

            row = []

            ($ @).children().each ->
              row.push ($ @).text()
                              
            row_blank = true
              
            ($ @).children().each (index, element) ->
              if( row[index]? and row[index] != "" )
                row_blank = false

            if !row_blank
              row_data.push row

          table_data = for tmp, col_i in row_data[0]
            tmp = for row, row_i in row_data
              row[col_i]

          ajax_data =
            headers: head
            data: table_data
            
          #console.log ajax_data

          ($ '#edit_table_add').addClass 'disabled'
          ($ '#edit_table_save').button 'loading'

          $.ajax
            url: "/projects/#{($ table).data('project-id')}"
            type: "GET"
            dataType: "json"
            success: (data, textStatus, jqXHR) ->
              local = []
              remote = []
              add_fields = []
              field_deleted = false
              dup = []
                              
              $(data.fields).each (i, e) ->
                remote.push e.id
              local = ajax_data.headers
              
              ($ remote).each (index, field) ->
                if !(field in local)
                  add_fields.push( data.fields[index] )
                                        
              ($ local).each (index, field) ->
                if !(field in remote)
                  field_deleted = true
                  
              if field_deleted
                alert "The project owner deleted a field/fields while you were entering data. Unfortunately we must refresh the page (losing data) to correct the fields."
                location.reload true

              if add_fields.length == 0
               
                $.ajax "#{settings.upload.url}",
                  type: "#{settings.upload.method}"
                  dataType: 'json'
                  data: ajax_data
                  error: settings.upload.error
                  success: settings.upload.success
                  
              else
              
                alert "The project owner added a field/fields while you were entering data. We are adding these new fields for you now, press save again to submit data with the new fields."
                    
                ($ add_fields).each (index, element) ->
                  ($ table).find('thead tr').eq(0).append("<th data-field-type='#{settings.type(element.type)}' data-field-id='#{element.id}' data-field-name='#{element.name}'>#{element.name}</th>")
                ($ table).find('tbody').find('tr').each (i, e) ->
                  ($ add_fields).each () ->
                    ($ e).append('<td></td>')
                 
                wrap_table(table)
                      
                # add buttons
                for button in settings.buttons
                  do (button) ->
                    if button is "close" or button is "Close"
                      ($ table).find('tr').eq(0).append '<th></th>'
                      ($ table).find('tbody').children().each ->
                        ($ @).append '<td><div class="text-center"><a class="close" style="float:none;">&times;</a></div></td>'
                        ($ @).find('.close').click () ->
                          remove_row(@)
          
                    if button is "add" or button is "Add"
                      ($ '#edit_table_add').removeClass 'disabled'
          
                    if button is "save" or button is "Save"
                      ($ '#edit_table_save').button 'reset'
                      ($ '#edit_table_save').click submit_form

        # does it pass?
        table_validates = (tab) ->
        
          #Check for zero rows
          if ($ tab).find('td').has('.input-small').length == 0
            alert "You must enter at least one row of data."
            return false
            
          # Check that there is at least one value
          noInput = true
          ($ tab).find('td').has('.input-small').each ->
              noInput = noInput and (($ @).find('.input-small').val() == "")
          if noInput
            alert "You must enter at least one item of data."
            return false

          if ($ 'input').hasClass 'invalid'
            false
          else
            true


        ### FIRST PASS (on load) ###

        ### MODIFY HTML ###

        # add control panel
        ($ table).after "<span id='edit_table_control' class='pull-right'></span>"

        # center TH's
        ($ table).find('th').each ->
          ($ @).html "<div class='text-center'>#{($ @).text()}</div>"

        button_container = ($ '.edit_table_control')
        if button_container.length == 0
          button_container = ($ '#edit_table_control')
          
        # add buttons
        for button in settings.buttons
          do (button) ->
            if button is "close" or button is "Close"
              ($ table).find('tr').eq(0).append '<th></th>'
              ($ table).find('tbody').children().each ->
                ($ @).append '<td><div class="text-center"><a class="close" style="float:none;">&times;</a></div></td>'

            if button is "add" or button is "Add"
              button_container.append "<button id='edit_table_add' class='btn btn-success' style='margin-right:10px;'>Add Row</button>"

            if button is "save" or button is "Save"
              button_container.append "<button id='edit_table_save' class='btn btn-primary' data-loading-text='Saving...' autocomplete='off' >Save</button>"

        # if control panel is empty get rid of it
        if ($ '#edit_table_control').html() is ""
          ($ '#edit_table_control').remove()

        # bootstrapify the table
        if settings.bootstrapify is true
          ($ @).addClass "table table-bordered table-striped"
          wrap_table(table)

        ### BIND ACTIONS ###

        # bind remove_row to .close buttons
        ($ table).find('td .close').each ->
          ($ @).click ->
            remove_row(@)

        # bind map button
        ($ 'td').find('.map_picker').click ->
          ($ this).closest("tr").addClass('target')
          previous_lon = ($ this).closest('tr').find('.validate_longitude').val()
          previous_lat = ($ this).closest('tr').find('.validate_latitude').val()
          if (previous_lat != "") and (previous_lon != "")
            location = new google.maps.LatLng(previous_lat, previous_lon)
            window.marker.setPosition(location)
            window.map.setCenter(location)
            ($ '#address').val("")
          ($ '#map_picker').modal();

        #bind time button
        ($ 'td').find('.datepicker').datetimepicker()

        # add row functionality
        ($ '#edit_table_add').click ->
          add_row(table)

        ### SAVE TABLE ###

        ($ '#edit_table_save').click ->

          if table_validates(table)
            
            ($ '#edit_table_save').unbind()

            if settings.upload.ajaxify is true
              
              submit_form()


            else
              ## I guess I'm not gonna write this part because we only use ajax to submit data
              ($ table).wrap "<form action='#{settings.upload.url}' method='#{settings.upload.method}' />"
