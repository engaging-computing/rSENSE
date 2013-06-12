$ = jQuery

$.fn.extend
  editTable: (options) ->
    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: "#"
        method: 'get'
      debug: true

    settings = $.extend settings, options

    log = (msg) ->
      console?.log msg if settings.debug

    return @each ()->
      table = @

      remove_row = (row) ->
        ($ row).parent().parent().parent().remove()

      strip_table = (tab) ->
        ($ tab).find('td').has('input').each ->
          ($ @).html ($ @).find('input').val()

        ($ tab).find('th:last-child').empty().remove()

        ($ tab).find('td').has('button.close').each ->
          ($ @).remove()

        ($ tab).find('th').each ->
          ($ @).html ($ @).text()

      wrap_table = (tab) ->
        ($ @).find('th').each ->
          ($ @).html "<div class='text-center'>#{($ @).html()}</div>"
        ($ @).find('td').each ->
          ($ @).html "<div class='text-center'>#{($ @).html()}</div>"


      ($ table).after "<span id='edit_table_control' class='pull-right'></span>"

      for button in settings.buttons
        do (button) ->
          if button is "close" or button is "Close"
            ($ table).find('tr').eq(0).append '<th></th>'
            ($ table).find('tbody').children().each ->
              ($ @).append '<td><button type="button" class="close" style="float:none;">&times;</button></td>'

          if button is "add" or button is "Add"
            ($ '#edit_table_control').append "<button id='edit_table_add' class='btn btn-success'>Add Row</button>"

          if button is "save" or button is "Save"
            ($ '#edit_table_control').append "<button id='edit_table_save' class='btn btn-primary'>Save</button>"

      if ($ '#edit_table_control').html() is ""
        ($ '#edit_table_control').remove()

      if settings.bootstrapify
        ($ @).addClass "table table-bordered table-striped"
        wrap_table(table)

      ($ table).find('td .close').each ->
        ($ @).click ->
          remove_row(@)

      ($ '#edit_table_add').click ->

        new_row = "<tr>"
        ($ table).find('th').each ->
          new_row += "<td><div class='text-center'><input type='text' class='input' /></div></td>"
        new_row += "<td><div class='text-center'><button type='button' class='close' style='float:none;'>&times;</button></div></td></tr>"

        ($ table).append new_row

        ($ table).find('tbody').find('tr:last-child').find('.close').click ->
          remove_row(@)

      ($ '#edit_table_save').click ->
        strip_table(table)

        if settings.upload.ajaxify

          head = [($ table).find('th').text()]

          log head

          data =
            headers: head
        else
          ($ table).wrap "<form action='#{settings.upload.url}' method='#{settings.upload.method}' />"

