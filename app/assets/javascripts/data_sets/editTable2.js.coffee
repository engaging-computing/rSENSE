window.setupEditTable = () ->
  # Only allows the plugin to run on certain pages. Probably not the right place to do this.
  if (namespace.controller is "data_sets") and (namespace.action is "manualEntry" or namespace.action is "edit")
    offset = 0
    if namespace.action is "manualEntry"
      offset = 1
     
  $.fn.extend
    editTable: (options) ->
      settings =
        page_name: "blank"
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
            alert "An upload error occurred."

        type: (field) ->
          if field is 1
            "Timestamp"
          else if field is 2
            "Number"
          else if field is 3
            "Text"
          else if field is 5
            "Longitude"
          else if field is 4
            "Latitude"

          else if field is "Timestamp"
            1
          else if field is "Number"
            2
          else if field is "Text"
            3
          else if field is "Longitude"
            5
          else if field is "Latitude"
            4
        debug: true

      settings = $.extend settings, options

      log = (msg) ->
        console?.log msg if settings.debug

      return @each () =>

        ### START ###
        # variable to keep track of our table

        table = @

        num_cols = []
        lat_cols = []
        lon_cols = []
        text_cols = []
        time_cols = []

        restrictions = []

        ($ table).find('th').each () ->
          restrictions.push eval( ($ @).attr 'data-field-restrictions' )

        #Enter events to add new row or go to begining of next row.
        ($ @).on 'keypress', 'input', (event) ->
          code = if event.keyCode then event.keyCode else event.which
          if code == 13
            cur_index = ($ event.target).closest('tr')[0].rowIndex
            last_index = table.find('tr:last')[0].rowIndex
            if cur_index == last_index
              add_row(table)
              ($ '#manualTable').find('tbody').find('tr:last').prepend(
                "<td style='width:10%;text-align:center'>" +
                (($ '#manualTable').find('tbody').find('tr').length) + "</td>"
              )
            table.find("tr:nth-child(#{cur_index+1})").find('input:first').select()


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
          rowNum = 1
          ($ row).closest('tr').remove()
          ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
            ($ j).find('td:first').text(rowNum)
            rowNum += 1
        add_validators = (row) ->
          row = ($ row).closest('tr')

          update_headers()
          # attach validators
          for col in num_cols
            do (col) ->
              ($ row).children().eq(col - offset).find('input').addClass 'validate_number'

          for col in lat_cols
            do (col) ->
              ($ row).children().eq(col - offset).find('input').addClass 'validate_latitude'

          for col in lon_cols
            val = ($ row).find('input').eq(col).val()
            if namespace.action is "manualEntry"
              val = ''
              
            do (col) ->
              ($ row).children().eq(col - offset ).find('input').replaceWith """
                <div class=''>
                  <input class='validate_longitude form-control ' id='appendedInput' type='text'
                    value="#{ val }" />
                </div>"""
              

          for col in text_cols
            do (col) ->
              ($ row).children().eq(col - offset).find('input').addClass 'validate_text'

          for col in time_cols
            do (col) ->
              ($ row).children().eq(col - offset).find('input').replaceWith """
                <div class='datepicker'>
                  <input class='validate_timestamp  form-control' type='text'
                    data-format='yyyy/MM/dd hh:mm:ss' value='#{ ($ row).find('input').eq(col - offset).val() }' />
                </div>"""
#               ($ row).children().eq(col - offset).find('.datepicker').unbind().datetimepicker()

        add_row = (tab) ->
          # create a string of the new row
          rowNum = ($ 'manualTable').find('tbody').find('tr').size + 1
          newRow = "<tr class='new_row'>"
          bounds = ($ tab).find('th:not(:last-child)')
          if namespace.action is "manualEntry"
            bounds = ($ tab).find('th:not(:last-child):not(:first-child)')
          ($ bounds).each (index) ->
            if restrictions[index] == undefined
              newRow += "<td><div class='text-center'><input type='text' class=' form-control'/></div></td>"
            else
              newRow += "<td><div clastables='text-center'><select class='form-control'><option>Select One</option>"
              ($ restrictions[index]).each (r_index) ->
                newRow += "<option value='#{restrictions[index][r_index]}'>#{restrictions[index][r_index]}</option>"
              newRow += "</select></div></td>"

          newRow += "<td><div class='text-center'><a class='close' style='float:none;'>&times;</a></div></td></tr>"
          
          # and attach it to our table
          ($ tab).append newRow

          # attach validators
          add_validators ($ '.new_row')

          # bind row removal
          ($ '.new_row').find('.close').click ->
            remove_row(@)
         
          # remove token
          ($ '.new_row').removeClass('new_row')

          #window.onload = ( -> ($ '#edit_table_add').click() )

        # strip table for upload
        strip_table = (tab) ->
          ($ tab).find('td').has('input').each ->
            ($ @).html ($ @).find('input').val()

          ($ tab).find('th:last-child').empty().remove()

          ($ tab).find('td').has('a.close').each ->
            ($ @).remove()

          ($ tab).find('th').each ->
            ($ @).html ($ @).text()

        # make it pretty and functional the first row.
        wrap_table = (tab) ->
          ($ tab).find('th').each ->
            ($ @).children().wrap "<div class='text-center' />"

          ($ tab).find('tr').slice(1).each (row_index, row) ->
            ($ row).find('td').not(':has(a.close)').each (col_index, col) ->
              if restrictions[col_index] == undefined
                ($ @).html "<input type='text' class=' form-control' value='#{($ @).text()}' />"
                ($ @).children().wrap "<div class='text-center' />"

          ($ tab).find('tr').each ->
            add_validators ($ @)

          ($ tab).find("td:first").find("input").focus()

        submit_form = () ->

          strip_table(table)

          # collect data and ship it off via AJAX
          table_data = {}
          ($ table).find('th').each ->
            table_data[($ @).data('field-id')] = []
          ($ table).find('tr').slice(1).has('td').each ->
            ($ @).children().each (index) ->
              if restrictions[index] == undefined
                parent_id = ($ table).find("th:nth-child(#{index+1})").data('field-id')
                table_data[parent_id].push(($ @).text())
              else
                parent_id = ($ table).find("th:nth-child(#{index+1})").data('field-id')
                table_data[parent_id].push(($ @).find('option:selected').val())


          dname = ($ '#data_set_name').val()
          cname = ($ '#contrib_name').val()

          ajax_data =
            title: dname
            contributor_name: cname
            data: table_data

          ($ '#edit_table_add').addClass 'disabled'
          ($ '#edit_table_save').button 'loading'

          $.ajax
            url: "#{settings.upload.url}"
            type: "POST"
            dataType: 'JSON'
            data: ajax_data
            error: settings.upload.error
            success: settings.upload.success


        # does it pass?
        table_validates = (tab) ->
          ($ '#manualTable').find('tr').each (i,j) ->
            ($ j).children(':first').remove()
          #Check for zero rows
          if (($ tab).find('td').has('input').length == 0 and ($ tab).find('td').has('select').length == 0)
            ($ '#manualEntry').find('thead').find('tr').prepend(
              "<th style='width:10%;text-align:center'> Row Number </th>"
            )
            rowNum = 1
            ($ '#manualEntry').find('tbody').find('tr').each (i,j) ->
              ($ j).prepend("<td style='text-align:center;width:10%'>" + rowNum + "</td>")
              rowNum += 1
            alert "You must enter at least one row of data."
            return false

          # Check that there is at least one value
          noInput = true
          ($ tab).find('td').has('input, select').each ->
            noInput = noInput and ((($ @).find('input').val() == "") or
            ($ @).find('select').val() == "Select One")
          if noInput
            rowNum = 1
            ($ '#manualTable').find('thead').find('tr').prepend(
              "<th style='width:10%;text-align:center'> Row Number </th>"
            )
            ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
              ($ j).prepend("<td style='text-align:center;width:10%'>" + rowNum + "</td>")
              rowNum += 1
            alert "You must enter at least one item of data."
            return false

          if ($ 'input').hasClass 'invalid'
            ($ '#manualTable').find('thead').find('tr').prepend(
              "<th style='width:10%;text-align:center'> Row Number </th>")
            rowNum = 1
            ($ '#manualTable').find('tbody').find('tr').each (i,j) ->
              ($ j).prepend("<td style='width:10%;text-align:center'>" + rowNum + "</td>")
              rowNum += 1
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
              button_container.append("""<button id='edit_table_add' class='btn btn-success'
                style='margin-right:10px;'>Add Row</button>""")

            if button is "save" or button is "Save"
              button_container.append("""<button id='edit_table_save' class='btn btn-primary'
                data-loading-text='Saving...' autocomplete='off' >Save</button>""")

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
            

        # add row functionality
        ($ '#edit_table_add').click ->
          add_row(table)

        ### SAVE TABLE ###

        ($ '#edit_table_save').click ->
          if !($ '#edit_table_save').hasClass 'disabled'
            if ($ '#data_set_name').val() == "" and settings.page_name == "manualEntry"
              ($ '.mainContent').prepend """<div class='alert alert-danger alert-dismissable'>
                <button type='button' class='close' data-dismiss='alert' aria-hidden='true'>
                &times;</button><strong>An error occurred: </strong>
                Please enter a name for your Data Set.</div>"""
            else
              if table_validates(table)
                #($ '#edit_table_save').unbind()

                if settings.upload.ajaxify is true
                  submit_form()

                else
                  ## I guess I'm not gonna write this part because we only use ajax to submit data
                  ($ table).wrap "<form action='#{settings.upload.url}' method='#{settings.upload.method}' />"
