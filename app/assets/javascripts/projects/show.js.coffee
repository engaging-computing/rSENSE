IS.onReady "projects/show", ->

  # Initializes the dropdown lightbox for google drive upload
  $('#google_doc').click ->
    $('#doc_box').modal()
    false

  $('#cancel_doc').click (e) ->
    e.preventDefault()
    $('#doc_box').modal 'hide'

  $('#doc_box').on 'hidden', ->
    $('#doc_box').hide()

  ##
  # Does the liking and unliking when the thumbs-up icon is clicked
  ##
  $('.liked_status').click ->
    root = $(".likes")
    was_liked = $(@).hasClass('active')

    $.ajax
      url: "/projects/#{ root.attr 'data-project_id' }/updateLikedStatus"
      type: 'POST'
      dataType: 'json'
      success: (resp) ->
        root.find('.like_display').html resp['update']
      error: (j, s, t) =>
        errors = JSON.parse j.responseText
        $(@).popover
          content: errors[0]
          placement: "bottom"
          trigger: "manual"
        $(@).popover 'show'
        if was_liked
          $(@).addClass('active')
        else
          $(@).removeClass('active')

  ###
  # Controls for uploading a file.
  ###
  # Displays the upload csv and upload google doc lightboxes
  $('#upload_datafile').click ->
    $('#datafile_input').click()
    false

  # Auto-submit the file upload form when user hits the open button.
  $('#datafile_input').change ->
    $('#datafile_form').submit()


  ###
  # Controls for uploading template file.
  ###
  $('#template_file_upload').click ->
    $('#template_file_input').click()
    false
  $('#template_file_input').change ->
    $('#template_file_form').submit()

  ###
  # Controls for Data Sets box
  ###
  # Takes all sessions that are checked, appends its id to the url and
  # redirects the user to the view sessions page (Vis page)
  $('#vis_button').click (e) ->
    targets = $(document).find(".dataset .ds_selector input:checked")
    ds_list = (get_ds_id t for t in targets)
    # Set the value in the hidden form field
    $('#visualize_selected>input').attr('value', ds_list)
    # POST form
    $('#visualize_selected').submit()

  $('#export_button').click (e) ->
    $('#export_modal').modal('show')

  $('#export_individual_button').click (e) ->
    $('#export_modal').modal('hide')
    targets = $(document).find(".dataset .ds_selector input:checked")
    ds_list = (get_ds_id t for t in targets)

    if ds_list.length is 0
      alert "No data sets selected for Export. Select at least 1 and try again."
    else
      # Set the value in the hidden form field
      $('#export_selected>input').attr('value', ds_list)
      # POST form
      $('#export_selected').submit()

  $('#export_concatenated_button').click (e) ->
    $('#export_modal').modal('hide')
    targets = $(document).find(".dataset .ds_selector input:checked")
    ds_list = (get_ds_id t for t in targets)

    if ds_list.length is 0
      alert "No data sets selected for Export. Select at least 1 and try again."
    else
      # Set the value in the hidden form field
      $('#export_concatenated_selected>input').attr('value', ds_list)
      # POST form
      $('#export_concatenated_selected').submit()

  # get the session number for viewing vises
  get_ds_id = (t) ->
    ds_id = $(t).attr 'id'
    ds_id = ds_id.split '_'
    ds_id[1]

  #Select all/none check box in the data sets box
  $("a#check_all").click ->
    root = $('#dataset_table')
    root.find("[id^=lbl_]").each (i,j) ->
      $(j)[0].MaterialCheckbox.check()
    $('#vis_button').prop("disabled", false)
    $('#export_button').prop("disabled", false)
    $('#delete_selected_button').prop("disabled", false)

  $("a#uncheck_all").click ->
    root = $('#dataset_table')
    root.find("[id^=lbl_]").each (i,j) ->
      $(j)[0].MaterialCheckbox.uncheck()
    $('#vis_button').prop("disabled", true)
    $('#export_button').prop("disabled", true)
    $('#delete_selected_button').prop("disabled", true)


  #Select all checkboxes created by current logged in user
  $("a#check_mine").click ->
    root = $('#dataset_table')
    root.find("[id^=lbl_]").each (i,j) ->
      $(j)[0].MaterialCheckbox.uncheck()
    root.find(".lbl-mine").each (i,j) ->
      $(j)[0].MaterialCheckbox.check()
    if root.find(".lbl-mine").length isnt 0
      $('#vis_button').prop("disabled", false)
      $('#export_button').prop("disabled", false)
      $('#delete_selected_button').prop("disabled", false)
    else
      $('#vis_button').prop("disabled", true)
      $('#export_button').prop("disabled", true)
      $('#delete_selected_button').prop("disabled", true)
      
  $("a.check_id").click ->
    root = $('#dataset_table')
    $('#vis_button').prop("disabled", true)
    $('#export_button').prop("disabled", true)
    $('#delete_selected_button').prop("disabled", true)
    root.find("[id^=lbl_]").each (i,j) ->
      $(j)[0].MaterialCheckbox.uncheck()
    root.find('tr').each (i,j) =>
      if $(j).find('.key').attr('title') is $(this).attr('m-title')
        $(j).find("[id^=lbl_]")[0].MaterialCheckbox.check()
        $('#vis_button').prop("disabled", false)
        $('#export_button').prop("disabled", false)
        $('#delete_selected_button').prop("disabled", false)

  #Turn off visualize button on page load, and when nothings checked
  check_for_selection = ->
    should_disable = true
    $(":checkbox").each (i,j) ->
      if($(j)[0].checked)
        should_disable = false
      else
        $('#check_selector').prop("checked",false)
        $('#export_button').prop("disabled",false)
      $('#vis_button').prop("disabled", should_disable)
      $('#export_button').prop("disabled", should_disable)
      $('#delete_selected_button').prop("disabled", should_disable)

  check_for_selection()

  #Add click events to all check boxes in the data_sets box
  $('#dataset_table').find(".mdl-checkbox__input").each (i,j) ->
    $(j).click check_for_selection

  # delete selected data sets
  $('#delete_selected_button').click (e) ->
    targets = $(document).find(".dataset .ds_selector input:checked")
    ds_list = (get_ds_id t for t in targets)
    rows = []
    for t in targets
      if $(t).hasClass("mine") is false
        alert("You have selected another user's data set. You may only delete data sets that belong to you.")
        return
      rows.push $(t).parents('tr')

    dsetsAmount = ds_list.length + " data set" + (if ds_list.length == 1 then "" else "s")

    if helpers.confirm_delete dsetsAmount
      $.ajax
        url: window.location.origin + "/delete_data_sets/" + ds_list
        type: "delete"
        dataType: "json"
        success: ->
          # reload page without scrolling back to previous position, so we can see the message at the top.
          window.location.href = window.location.href
        error: (msg) ->
          response = $.parseJSON msg['responseText']
          error_message = response.error
          alert("There was an issue deleting the data sets: " + error_message + ". Please try again.")

  # delete data sets
  $('a.data_set_delete').click (e) ->
    e.preventDefault()

    url = $(@).attr('href')
    row = $(@).parents('tr')
    p_id = url.split '/'
    p_id = p_id[ p_id.length - 1 ]


    if helpers.confirm_delete $(@).attr('name')
      $.ajax
        url: url
        type: "delete"
        dataType: "json"
        success: ->
          recolored = false
          tbody = row.parents('tbody')
          row.delete_row ->
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true
        error: (msg) ->
          response = $.parseJSON msg['responseText']
          error_message = response.errors.join "</p><p>"

          $('.container.mainContent').find('p').before """
            <div class="alert alert-danger fade in">
              <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
              <h4>Error Deleting Data Set:</h4>
              <p>#{error_message}</p>
              <p>
                <button type="button" class="btn btn-danger error_bind" data-retry-text"Retrying...">Retry</button>
                <button type="button" class="btn btn-default error_dismiss">Or Dismiss</button>
              </p>
            </div>"""

          $('.error_dismiss').click ->
            $('.alert').alert 'close'

          $('.error_bind').click ->
            $('.error_bind').button 'loading'
            $.ajax
              url: url
              type: 'DELETE'
              dataType: "json"
              success: ->
                $('.error_bind').button 'reset'
                $('.alert').alert 'close'
                recolored = false
                tbody = row.parents('tbody')
                row.delete_row ->
                  row.remove()
                  tbody.recolor_rows(recolored)
                  recolored = true
              error: (msg) ->
                $('.error_bind').button 'reset'

  # delete visualizations

  $('a.viz_delete').click (e) ->
    e.preventDefault()

    url = e.target.href

    p_id = url.split '/'
    p_id = p_id[ p_id.length - 1 ]

    if helpers.confirm_delete $(@).attr('name')
      $.ajax
        url: $(@).attr('href')
        type: 'DELETE'
        dataType: "json"
        beforeSend: ->
        success: =>
          recolored = false
          row = $(@).parents('tr')
          tbody = row.parents('tbody')
          row.delete_row ->
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true
        error: (msg) ->
          response = $.parseJSON msg['responseText']
          error_message = response.errors.join "</p><p>"

          $('.container.mainContent').find('p').before """
            <div class="alert alert-danger fade in">
              <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
              <h4>Error Deleting Vis:</h4>
              <p>#{error_message}</p>
              <p>
                <button type="button" class="btn btn-danger error_bind" data-retry-text"Retrying...">Retry</button>
                <button type="button" class="btn btn-default error_dismiss">Or Dismiss</button>
              </p>
            </div>"""

          $('.error_dismiss').click ->
            $('.alert').alert 'close'

          $('.error_bind').click ->
            $('.error_bind').button 'loading'

            $.ajax
              url: url
              type: 'DELETE'
              dataType: "json"
              success: =>
                $('.error_bind').button 'reset'
                $('.alert').alert 'close'
                recolored = false
                row = $(@).parents('tr')
                tbody = row.parents('tbody')
                row.delete_row ->
                  row.remove()
                  tbody.recolor_rows(recolored)
                  recolored = true
              error: (msg) ->
                $('.error_bind').button 'reset'


  ###
  # Print for page
  ###
  $('#print').click (e) ->
    e.preventDefault()
    window.print()

  $("select#display_n").change ->
    console.log $("#display_n option:selected").val()

    ###
    $.ajax
      dataType: 'text'
      url: "/projects/#{ namespace.id }"
      type: 'GET'
      data:
        id: namespace.id
        display_n : $("#display_n option:selected").val()
      success: ->
        console.log "SENT AJAX FOR display_n"
    ###
    console.log "/projects/#{ namespace.id }"
    console.log window.location
    
    window.location.href = window.location.origin + window.location.pathname + "?per_page=#{$("#display_n option:selected").val()}"
    ###
      error: (msg) ->
        console.log msg
        console.log "failure"
    ###
       

  ###
  # Tags
  ###
  $('#enter-project-tag-name').keypress (e) ->
    if e.keyCode == 10 or e.keyCode == 13
      e.preventDefault()

  $('#tag-badge-container').on 'click', '.tag-badge-remove', (e) ->
    tagId = $(e.currentTarget).data("id")
    $(e.currentTarget).parent().remove()
    $.ajax
      dataType: 'text'
      url: '/projects/remove_tag'
      type: 'DELETE'
      data:
        id: namespace.id
        tagId: tagId
    if $('#tag-badge-container>.tag-badge').length is 0
      $('#addatag').show()

  $('#tag-badge-add').click ->
    $('#tag-badge-add').hide()
    $('#tag-badge-form').show()
    $('#tag-badge-textfield').focus()

  $('#tag-badge-textfield').bind "enterKey", (e) -> $('#tag-badge-confirm').click()
  $('#tag-badge-textfield').keyup (e) -> if (e.keyCode is 13) then $(this).trigger("enterKey")

  $('#tag-badge-confirm').click ->
    if (tagName = $('#tag-badge-textfield').val()) isnt ''
      if ($("#tag-badge-container>.tag-badge").filter () -> $.trim($(this).text()) is tagName).length is 0
        $.ajax
          dataType: 'text'
          url: '/projects/create_tag'
          type: 'POST'
          data:
            id: namespace.id
            name: tagName
          success: (res) ->
            tagId = JSON.parse(res)["id"]
            tagName = JSON.parse(res)["name"]
            $('#addatag').hide()
            $('#tag-badge-container').append $('<span>',
              class: 'tag-badge',
              html: '<a href="../projects?utf8=✓&search=' + tagName + \
                    '&sort=updated_at&order=DESC">' + tagName + '</a>
                     <div class="tag-badge-remove" data-id="' + tagId + '">&nbsp<i class="fa fa-remove"></i></div>')
      else
        alert "Tag already exists."
    $('#tag-badge-textfield').val('')
    $('#tag-badge-form').hide()
    $('#tag-badge-add').show()


