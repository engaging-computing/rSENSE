$ ->
  if namespace.controller is "projects" and namespace.action is "show"
    
   # Control code for name popup box
    if ($ '#name_box') isnt []
      ($ '#name_box').modal();
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

   

    # A File has been uploaded, decide what to do
#     ($ "#csv_file_form").ajaxForm
#       error: (resp, status, xhr)->
#         alert resp['responseText']
#       
#       success: (resp, status, xhr)->
#         if xhr.status == 201
#           helpers.name_popup resp, "Dataset", "data_set"
#         else
#           respond_csv(resp)

    load_qr = ->
      ($ '#exp_qr_tag').empty()
      ($ '#exp_qr_tag').qrcode { text : window.location.href, height: ($ '#exp_qr_tag').width()*.75, width: ($ '#exp_qr_tag').width()*.75 }

    load_qr()

    ($ window).resize ->
      load_qr()

    # Initializes the dropdown lightbox for google drive upload
    ($ '#doc_box').modal
      backdrop: 'static'
      keyboard: true
      show: false

    # Does the liking and unliking when the thumbs-up icon is clicked
    ($ '.liked_status').click ->
      root = ($ ".likes")
      was_liked = ($ @).hasClass('active')

      $.ajax
        url: '/projects/' + root.attr('project_id') + '/updateLikedStatus'
        dataType: 'json'
        success: (resp) =>
          root.find('.like_display').html resp['update']
        error: (resp) =>
          ($ @).errorFlash()
          if was_liked
            ($ @).addClass('active')
          else
            ($ @).removeClass('active')
    

    # This is black magic that displays the upload csv and upload google doc lightboxes
    ($ '#upload_csv').click ->
      ($ '#csv_file_input').click()
      false

    ($ '#csv_file_input').change ->
      ($ '#csv_file_form').attr 'action', "/data_sets/uploadCSV2"
      ($ '#csv_file_form').submit()

    ($ '#cancel_doc').click ->
      ($ '#doc_box').modal 'hide'

    ($ '#doc_box').on 'hidden', ->
        ($ '#doc_box').hide()

    ($ '#google_doc').click ->
      ($ '#doc_box').modal()
      false

    # Takes all sessions that are checked, appends its id to the url and
    # redirects the user to the view sessions page (Vis page)
    ($ '#vis_button').click (e) ->
      targets = ($ document).find(".dataset .ds_selector input:checked")
      ds_list = (get_ds_id t for t in targets)
      window.location = ($ this).attr("href") + ds_list
      
    ($ '#export_button').click (e) ->
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
        root.find("[id^=ds_]").each (i,j) =>
          ($ j).prop("checked",true)
        ($ '#vis_button').prop("disabled",false)
        ($ '#export_button').prop("disabled",false)

    ($ "a#uncheck_all").click ->
        root = ($ '#dataset_table')
        root.find("[id^=ds_]").each (i,j) =>
            ($ j).prop("checked",false)
        ($ '#vis_button').prop("disabled",true)
        ($ '#export_button').prop("disabled",true)

    ($ "a#check_mine").click ->
        root = ($ '#dataset_table')
        root.find("[id^=ds_]").each (i,j) =>
            ($ j).prop("checked",false)
        root.find(".mine").each (i,j) =>
            ($ j).prop("checked",true)
        if root.find(".mine").length isnt 0
          ($ '#vis_button').prop("disabled",false)
          ($ '#export_button').prop("disabled",false)
        else
          ($ '#vis_button').prop("disabled",true)
          ($ '#export_button').prop("disabled",true)

    #Turn off visualize button on page load, and when nothings checked
    check_for_selection = =>
      should_disable = true
      ($ document).find("[id^=ds_]").each (i,j) =>
        if(($ j).is(":checked"))
          should_disable = false
        else
          ($ '#check_selector').prop("checked",false)
          ($ '#export_button').prop("disabled",false)
        ($ '#vis_button').prop("disabled", should_disable)
        ($ '#export_button').prop("disabled", should_disable)
        
    check_for_selection()

    #Add click events to all check boxes in the data_sets box
    ($ document).find("[id^=ds_]").each (i,j) =>
      ($ j).click check_for_selection

    #Add submit event to project filters form. Performs AJAX request to update project filters
    ($ ".project_filters").submit ->

      x = ($ @).children("input:checked").map ->
          return this.name

      filters = ""
      filters += x[j] + " " for i,j in x

      data={}
      data["project"] = {}
      data["project"]["filter"] = filters

      $.ajax
        url: ($ @).attr('id')
        type: "PUT"
        dataType: "json"
        data:
          data

      false


    ($ ".projects_add_filter_checkbox").click ->
      $(@).parent().submit()
      
    ###
    Links for Datasets
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
            row.delete_row =>
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
            row.delete_row =>
              row.remove()
              tbody.recolor_rows(recolored)
              recolored = true
              
    ## controls for saved vizes  
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
          row.delete_row =>
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
            row.delete_row =>
              row.remove()
              tbody.recolor_rows(recolored)
              recolored = true
              
              
