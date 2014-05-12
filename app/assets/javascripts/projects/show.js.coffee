$ ->
  if namespace.controller is "projects" and namespace.action is "show"
    
    # Loads a QR code for the page
    ($ '#exp_qr_tag').qrcode {
      text: window.location.href,
      height: ($ '#exp_qr_tag').width(),
      width: ($ '#exp_qr_tag').width()
    }

    # Control code for name popup box, Only for manual entry at the moment.
    if ($ '#name_box') isnt []
      ($ '#name_box').modal()
      selectFunc = ->
        ($ '#name_name').select()
      setTimeout selectFunc, 300

      ($ '#name_name').keyup (e) ->
        if (e.keyCode == 13)
          ($ '.name_button').click()

      ($ '.name_button').click ->
        name = ($ '#name_name').val()
        data =
          project:
            title: name

        $.ajax
          url: ($ 'span.edit_menu .menu_save_link').attr 'href'
          type: 'PUT'
          dataType: 'json'
          data: data
          success: ->
            ($ 'span.edit_menu span.info_text').text(name)
            ($ '#name_box').modal('hide')


    # Initializes the dropdown lightbox for google drive upload
    ($ '#google_doc').click ->
      ($ '#doc_box').modal()
      false
      
    ($ '#cancel_doc').click (e) ->
      e.preventDefault()
      ($ '#doc_box').modal 'hide'

    ($ '#doc_box').on 'hidden', ->
      ($ '#doc_box').hide()


    # Does the liking and unliking when the thumbs-up icon is clicked
    ($ '.liked_status').click ->
      root = ($ ".likes")
      was_liked = ($ @).hasClass('active')

      $.ajax
        url: '/projects/' + root.attr('project_id') + '/updateLikedStatus'
        type: 'POST'
        dataType: 'json'
        success: (resp) ->
          root.find('.like_display').html resp['update']
        error: (resp) =>
          ($ @).errorFlash()
          if was_liked
            ($ @).addClass('active')
          else
            ($ @).removeClass('active')
    

    ###
    # Controls for uploading a file.
    ###
    # This is black magic that displays the upload csv and upload google doc lightboxes
    ($ '#upload_datafile').click ->
      ($ '#datafile_input').click()
      false

    # Auto-submit the file upload form when user hits the open button.
    ($ '#datafile_input').change ->
      ($ '#datafile_form').submit()

      
    ###
    # Controls for uploading template file.
    ###
    ($ '#template_file_upload').click ->
      ($ '#template_file_input').click()
      false
    ($ '#template_file_input').change ->
      ($ '#template_file_form').submit()

    ###
    # Controls for Data Sets box
    ###
    # Takes all sessions that are checked, appends its id to the url and
    # redirects the user to the view sessions page (Vis page)
    ($ '#vis_button').click (e) ->
      targets = ($ document).find(".dataset .ds_selector input:checked")
      ds_list = (get_ds_id t for t in targets)
      window.location = ($ this).attr("href") + ds_list
    
    ($ '#export_button').click (e) ->
      ($ '#export_modal').modal('show')
    
    ($ '#export_individual_button').click (e) ->
      ($ '#export_modal').modal('hide')
      targets = ($ document).find(".dataset .ds_selector input:checked")
      ds_list = (get_ds_id t for t in targets)
            
      if ds_list.length is 0
        alert "No data sets selected for Export. Select at least 1 and try again."
      else
        window.location = ($ this).attr("href") + ds_list

    ($ '#export_concatenated_button').click (e) ->
      ($ '#export_modal').modal('hide')
      targets = ($ document).find(".dataset .ds_selector input:checked")
      ds_list = (get_ds_id t for t in targets)
            
      if ds_list.length is 0
        alert "No data sets selected for Export. Select at least 1 and try again."
      else
        window.location = ($ this).attr("href") + ds_list

    # get the session number for viewing vises
    get_ds_id = (t) ->
      ds_id = ($ t).attr 'id'
      ds_id = ds_id.split '_'
      ds_id[1]

    #Select all/none check box in the data sets box
    ($ "a#check_all").click ->
      root = ($ '#dataset_table')
      root.find("[id^=ds_]").each (i,j) ->
        ($ j).prop("checked",true)
      ($ '#vis_button').prop("disabled",false)
      ($ '#export_button').prop("disabled",false)

    ($ "a#uncheck_all").click ->
      root = ($ '#dataset_table')
      root.find("[id^=ds_]").each (i,j) ->
        ($ j).prop("checked",false)
      ($ '#vis_button').prop("disabled",true)
      ($ '#export_button').prop("disabled",true)

    ($ "a#check_mine").click ->
      root = ($ '#dataset_table')
      root.find("[id^=ds_]").each (i,j) ->
        ($ j).prop("checked",false)
      root.find(".mine").each (i,j) ->
        ($ j).prop("checked",true)
      if root.find(".mine").length isnt 0
        ($ '#vis_button').prop("disabled",false)
        ($ '#export_button').prop("disabled",false)
      else
        ($ '#vis_button').prop("disabled",true)
        ($ '#export_button').prop("disabled",true)
    ($ "a.check_id").click ->
      root = ($ '#dataset_table')
      ($ '#vis_button').prop("disabled",true)
      ($ '#export_button').prop("disabled",true)
      root.find("[id^=ds_]").each (i,j) ->
        ($ j).prop("checked",false)
      root.find('tr').each (i,j) =>
        if ($ j).find('.key').attr('title') is ($ this).attr('m-title')
          ($ j).find("[id^=ds_]").prop("checked",true)
          ($ '#vis_button').prop("disabled",false)
          ($ '#export_button').prop("disabled",false)
    #Turn off visualize button on page load, and when nothings checked
    check_for_selection = ->
      should_disable = true
      ($ document).find("[id^=ds_]").each (i,j) ->
        if(($ j).is(":checked"))
          should_disable = false
        else
          ($ '#check_selector').prop("checked",false)
          ($ '#export_button').prop("disabled",false)
        ($ '#vis_button').prop("disabled", should_disable)
        ($ '#export_button').prop("disabled", should_disable)
        
    check_for_selection()

    #Add click events to all check boxes in the data_sets box
    ($ document).find("[id^=ds_]").each (i,j) ->
      ($ j).click check_for_selection

    ###
    # Hide and delete for datasets
    ###
    ($ 'a.data_set_hide').click (e) ->
    
      e.preventDefault()
      
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data:
          data_set:
            hidden: true
        success: =>
          recolored = false
          row = ($ @).parents('tr')
          tbody = row.parents('tbody')
          row.delete_row ->
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true
              
    ($ 'a.data_set_delete').click (e) ->
   
      e.preventDefault()
      if helpers.confirm_delete ($ @).attr('name')
        $.ajax
          url: ($ @).attr('href')
          type: 'DELETE'
          dataType: "json"
          success: =>
            recolored = false
            row = ($ @).parents('tr')
            tbody = row.parents('tbody')
            row.delete_row ->
              row.remove()
              tbody.recolor_rows(recolored)
              recolored = true
              
    ###
    # Hide and delete for visualizations
    ###
    ($ 'a.viz_hide').click (e) ->
      e.preventDefault()
      
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data:
          visualization:
            hidden: true
        success: =>
          recolored = false
          row = ($ @).parents('tr')
          tbody = row.parents('tbody')
          row.delete_row ->
            row.remove()
            tbody.recolor_rows(recolored)
            recolored = true
              
    ($ 'a.viz_delete').click (e) ->
      e.preventDefault()
      
      if helpers.confirm_delete ($ @).attr('name')
        $.ajax
          url: ($ @).attr('href')
          type: 'DELETE'
          dataType: "json"
          success: =>
            recolored = false
            row = ($ @).parents('tr')
            tbody = row.parents('tbody')
            row.delete_row ->
              row.remove()
              tbody.recolor_rows(recolored)
              recolored = true
              
              
    ###
    # Print for page
    ###
    ($ '#print').click (e) ->
      e.preventDefault()
      window.print()
      
