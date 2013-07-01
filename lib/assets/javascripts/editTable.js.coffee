$ = jQuery

$.fn.extend
  editTable: (options) ->
    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: "#"
        method: 'PUT'
      debug: true

    settings = $.extend settings, options

    log = (msg) ->
      console?.log msg if settings.debug

    return @each ()->

      ### START ###
      # variable to keep track of our table

      table = @

      # separate columns by field type/validator

      num_cols = []
      lat_cols = []
      lon_cols = []
      text_cols = []
      time_cols = []

      ($ table).find('th').each (index) ->
        type = ($ @).attr 'data-field-type'

        switch type
          when "Time" then time_cols.push index
          when "Text" then text_cols.push index
          when "Number" then num_cols.push index
          when "Latitude" then lat_cols.push index
          when "Longitude" then lon_cols.push index

      ### FUNCTIONS ###

      remove_row = (row) ->
        ($ row).closest('tr').remove()

      add_row = (tab) ->

        # create a string of the new row
        new_row = "<tr class='new_row'>"

        ($ tab).find('th:not(:last-child)').each (index) ->
          new_row += "<td><div class='text-center'><input type='text' class='input-small' /></div></td>"

        new_row += "<td><div class='text-center'><a class='close' style='float:none;'>&times;</a></div></td></tr>"

        # and attach it to our table
        ($ tab).append new_row

        # attach validators
        for col in num_cols
          do (col) ->
            ($ '.new_row').find('tr').children().eq(col).find('input').addClass 'validate_number'

        for col in lat_cols
          do (col) ->
            ($ '.new_row').find('tr').children().eq(col).find('input').addClass 'validate_latitude'

        for col in lon_cols
          do (col) ->
            ($ '.new_row').find('tr').children().eq(col).find('input').addClass 'validate_longitude'

        for col in text_cols
          do (col) ->
            ($ '.new_row').find('tr').children().eq(col).find('input').addClass 'validate_text'

        for col in time_cols
          do (col) ->
            ($ '.new_row').find('tr').children().eq(col).find('input').addClass 'validate_timestamp'

        # bind row removal
        ($ '.new_row').find('.close').click ->
          remove_row(@)

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

      # make it pretty and functional
      wrap_table = (tab) ->
        ($ tab).find('th').each ->
          ($ @).children().wrap "<div class='text-center' />"

        ($ tab).find('td').not(':has(a.close)').each ->
          ($ @).html "<input type='text' class='input-small' value='#{($ @).text()}' />"
          ($ @).children().wrap "<div class='text-center' />"

        for col in num_cols
          do (col) ->
            ($ tab).find('tbody').find('tr').each ->
              ($ @).children().eq(col).find('input').addClass 'validate_number'

        for col in lat_cols
          do (col) ->
            ($ tab).find('tbody').find('tr').each ->
              ($ @).children().eq(col).find('input').addClass 'validate_latitude'

        for col in lon_cols
          do (col) ->
            ($ tab).find('tbody').find('tr').each ->
              ($ @).children().eq(col).find('input').addClass 'validate_longitude'

        for col in text_cols
          do (col) ->
            ($ tab).find('tbody').find('tr').each ->
              ($ @).children().eq(col).find('input').addClass 'validate_text'

        for col in time_cols
          do (col) ->
            ($ tab).find('tbody').find('tr').each ->
              ($ @).children().eq(col).find('input').addClass 'validate_timestamp'


      # does it pass?
      table_validates = (tab) ->

        if ($ 'input').hasClass 'invalid'
          false
        else
          true

      # add control panel
      ($ table).after "<span id='edit_table_control' class='pull-right'></span>"

      # center TH's
      ($ table).find('th').each ->
        ($ @).html "<div class='text-center'>#{($ @).text()}</div>"

      # add buttons
      for button in settings.buttons
        do (button) ->
          if button is "close" or button is "Close"
            ($ table).find('tr').eq(0).append '<th></th>'
            ($ table).find('tbody').children().each ->
              ($ @).append '<td><div class="text-center"><a class="close" style="float:none;">&times;</a></div></td>'

          if button is "add" or button is "Add"
            ($ '#edit_table_control').append "<button id='edit_table_add' class='btn btn-success' style='margin-right:10px;'>Add Row</button>"

          if button is "save" or button is "Save"
            ($ '#edit_table_control').append "<button id='edit_table_save' class='btn btn-primary'>Save</button>"

      # if control panel is empty get rid of it
      if ($ '#edit_table_control').html() is ""
        ($ '#edit_table_control').remove()

      # bootstrapify the table
      if settings.bootstrapify is true
        ($ @).addClass "table table-bordered table-striped"
        wrap_table(table)

      # bind remove_row to .close buttons
      ($ table).find('td .close').each ->
        ($ @).click ->
          remove_row(@)

      # add row functionality
      ($ '#edit_table_add').click ->
        add_row(table)

      ($ '#edit_table_save').click ->

        if table_validates(table)

          strip_table(table)

          if settings.upload.ajaxify is true

            # collect data and ship it off via AJAX
            head = []

            ($ table).find('th').each ->
              head.push ($ @).text()

            row_data = []

            ($ table).find('tr').has('td').each ->

              row = []

              ($ @).children().each ->
                row.push ($ @).text()

              row_data.push row

            table_data = for tmp, col_i in row_data[0]
              tmp = for row, row_i in row_data
                row[col_i]

            ajax_data =
              headers: head
              data: table_data

            $.ajax "#{settings.upload.url}",
              type: "#{settings.upload.method}"
              dataType: 'json'
              data: ajax_data
              error: (jqXHR, textStatus, errorThrown) ->
                log [textStatus, errorThrown]
                alert "Sorry, something went wrong."
              success: (data, textStatus, jqXHR) ->
                window.location = data.redirect

          else
            ## I guess I'm not gonna write this part because we only use ajax to submit data
            ($ table).wrap "<form action='#{settings.upload.url}' method='#{settings.upload.method}' />"

