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

    respond_template = ( resp ) ->
      ($ 'button.finished_button').addClass 'disabled'

      ($ '#template_match_table').html ''
      ($ '#template_match_table').append '<tr><th> Field Name </th><th> Field Unit </th><th> Field Type </th></tr>'

      for field, field_index in resp.fields
        options = "<option value='-1'>Select One...</option>"
        for type, type_index in resp.p_field_types[field_index]
          options += "<option value='#{type_index}'>#{type}</option>"

        html = "<tr><td class='field_name'>#{field.name[0..29]}"

        if field.name.length > 29
          html += '...'

        html += "</td><td><input type='text' class='field_unit' /></td><td><select>#{options}</select></td></tr>"

        ($ '#template_match_table').append html

      ($ "button.cancel_upload_button").click ->
          ($ "#template_match_box").modal("hide")

      ($ "#template_match_table select").change ->
        check = true
        for sel in ($ '#template_match_table').find(':selected')
          if ($ sel).text() == "Select One..."
            check = false

        if check
          ($ 'button.finished_button').removeClass 'disabled'
        else
          ($ 'button.finished_button').addClass 'disabled'


      ($ "button.finished_button").click ->
        if !($ 'button.finished_button').hasClass('disabled')
          newFields =
            pid: resp.pid
            names: []
            units: []
            types: []

          for names in ($ '#template_match_table').find('.field_name')
            newFields.names.push ($ names).text()

          for units in ($ '#template_match_table').find('.field_unit')
            newFields.units.push ($ units).val()

          for types in ($ '#template_match_table').find(':selected')
            newFields.types.push ($ types).text()

          $.ajax
            type: "POST"
            dataType: "json"
            url: "#{window.location}/templateFields"
            data: {save: true, fields: newFields}
            success: (resp) ->
              ($ "#match_box").modal("hide")
              window.location = window.location

      #begin horrible hackeyness of prodding the modal box
      #were gonna strech it and try and poke it to the center
      ($ '#template_match_box').css('width', '670px')

      ($ "#template_match_box").modal
          backdrop: 'static'
          keyboard: true


    respond_csv = ( resp ) ->
      ($ "#match_table").html ''
      ($ "#match_table").append "<tr><th> Experiment Field </th> <th> CSV Header </th></tr>"

      for field, fieldIndex in resp.fields

        options = "<option value='-1'> Select One... </option>"
        for header, headerIndex in resp.headers
          if (resp.partialMatches[fieldIndex] isnt undefined) and (resp.partialMatches[fieldIndex].hindex is headerIndex)
            options += "<option selected='true' value='#{headerIndex}'> #{header} </option>"
          else
            options += "<option value='#{headerIndex}'> #{header} </option>"

        ($ "#match_table").append "<tr>
                                  <td> #{field} </td>
                                  <td><select>" + options + "</select></td>
                                  </tr>"

      ($ "button.cancel_upload_button").click ->
        ($ "#match_box").modal("hide")

      ($ "button.finished_button").click ->

        matchData =
          pid: resp.pid
          fields: resp.fields
          headers: resp.headers
          matches: []
          tmpFile: resp.tmpFile

        ($ "#match_table tr").each (idx, ele) ->
          if idx > 0
            matchVal = ($ ele).find("td select").val()
            headerIndex = Number matchVal
            fieldIndex = idx - 1

            if headerIndex is -1
              ($ "#match_table tr td select[value=-1]").errorFlash()

            matchData.matches[fieldIndex] =
              findex: fieldIndex
              hindex: headerIndex

        $.ajax
          type: "POST"
          dataType: "json"
          url: "/projects/#{resp['pid']}/uploadCSV"
          data: matchData
          success: (resp) ->
            ($ "#match_box").modal("hide")
            helpers.name_dataset resp.title, resp.datasets, () ->
              window.location = resp.redirect
          error: (resp) ->
            alert "Somthing went horribly wrong. I'm sorry."

      ($ "#match_box").modal
        backdrop: 'static'
        keyboard: true

    # A File has been uploaded, decide what to do
    ($ "#csv_file_form").ajaxForm (resp) ->

      if resp.status == "success"
        helpers.name_dataset resp.title, resp.datasets, () ->
          window.location = resp.redirect
      else
        respond_csv(resp)

    ($ "#template_file_form").ajaxForm (resp) ->
      respond_template(resp)



    load_qr = ->
      ($ '#exp_qr_tag').empty()
      ($ '#exp_qr_tag').qrcode { text : window.location.href, height: ($ '#exp_qr_tag').width()*.75, width: ($ '#exp_qr_tag').width()*.75 }

    load_qr()

    ($ window).resize ->
      load_qr()

    #selection of featured image
    ($ '.img_selector').click ->
      mo = ($ @).attr("mo_id")
      exp = ($ @).attr("exp_id")

      data={}
      data["project"] = {}
      data["project"]["featured_media_id"] = mo

      $.ajax
        url: "/projects/#{exp}"
        type: "PUT"
        dataType: "json"
        data:
          data

    # Initializes the dropdown lightbox for google drive upload
    ($ '#doc_box').modal
      backdrop: 'static'
      keyboard: true
      show: false

    # Does the liking and unliking when the star icon is clicked
    ($ '.liked_status').click ->
      icon = ($ @).children 'i'
      if icon.attr('class').indexOf('icon-star-empty') != -1
        icon.replaceWith "<i class='icon-star'></i>"
      else
        icon.replaceWith "<i class='icon-star-empty'></i>"
      $.ajax
        url: '/projects/' + ($ this).attr('exp_id') + '/updateLikedStatus'
        dataType: 'json'
        success: (resp) =>
          ($ @).siblings('.like_display').html resp['update']


    # This is black magic that displays the upload csv and upload google doc lightboxes
    ($ '#upload_csv').click ->
      ($ '#csv_file_input').click()
      false

    ($ '#csv_file_input').click ->
      ($ '#csv_file_form').attr 'action', "#{window.location}/uploadCSV"

    ($ '#template_file_form').click ->
      ($ '#template_file_form').attr 'action', "#{window.location}/templateFields"

    ($ '#template-from-file').click ->
      ($ '#template_file_input').click()
      false

    ($ '#csv_file_input').change ->
      ($ '#csv_file_form').submit()

    ($ '#template_file_input').change ->
      ($ '#template_file_form').submit()

    ($ '#cancel_doc').click ->
      ($ '#doc_box').modal 'hide'

    ($ '#doc_box').on 'hidden', ->
        ($ '#doc_box').hide()

    ($ '#google_doc').click ->
      ($ '#doc_box').modal()
      false

    # Parse the Share url from a google doc to upload a csv from google drive
    ($ '#save_doc').click ->
      tmp = ($ '#doc_url').val()
      if tmp.indexOf('key=') isnt -1
        tmp = tmp.split 'key='
        key = tmp[1]
        tmp = window.location.pathname.split 'projects/'
        pid = tmp[1]
        url = "/data_sets/#{pid}/postCSV"
        $.ajax( { url: url, data: { key: key, id: pid } } ).done (data, textStatus, error) ->
          if data.status is 'success'
            window.location = data.redirrect
      else
        ($ '#doc_url').css 'background-color', 'red'

    # Takes all sessions that are checked, appends its id to the url and
    # redirects the user to the view sessions page (Vis page)
    ($ '#vis_button').click (e) ->
      targets = ($ @).parent().parent().parent().find('td input:checked')
      ses = ($ targets[0]).attr 'id'
      ses = ses.split '_'
      pid = ses[1]
      ses_list = (grab_ses t for t in targets )
      url = '/projects/' + pid + '/data_sets/' + ses_list.join ','
      window.location = url

    # get the session number for viewing vises
    grab_ses = (t) ->
      ses = ($ t).attr 'id'
      ses = ses.split '_'
      ses[3]

    #Select all/none check box in the data sets box
    ($ "#check_selector").click ->
      if ($ this).is(":checked")
        ($ this).parent().parent().parent().find("[id^=project_]").each (i,j) =>
          ($ j).prop("checked",true)
        ($ '#vis_button').prop("disabled",false)
      else
        ($ this).parent().parent().parent().find("[id^=project_]").each (i,j) =>
          ($ j).prop("checked",false)
          ($ '#vis_button').prop("disabled",true)

    #Turn off visualize button on page load, and when nothings checked
    check_for_selection = =>
      should_disable = true
      ($ document).find("[id^=project_]").each (i,j) =>
        if(($ j).is(":checked"))
          should_disable = false
        $('#vis_button').prop("disabled", should_disable)

    ($ '#vis_button').prop("disabled",true)

    #Add click events to all check boxes in the data_sets box
    ($ document).find("[id^=project_]").each (i,j) =>
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
          ($ @).parents('div.dataset').hide_row()
          ($ 'div#datset_list div.dataset').filter(':visible').each (idx) ->
            if idx % 2 is 0
              ($ @).addClass 'feed-even'
              ($ @).removeClass 'feed-odd'
            else
              ($ @).removeClass 'feed-even'
              ($ @).addClass 'feed-odd'
          
    ($ 'a.data_set_delete').click (e) ->
  
      e.preventDefault()
      
      if helpers.confirm_delete ($ @).attr('name')
        $.ajax
          url: ($ @).attr('href')
          type: 'DELETE'
          dataType: "json"
          success: =>
            ($ @).parents('div.dataset').hide_row()
            ($ 'div#datset_list div.dataset').filter(':visible').each (idx) ->
              if idx % 2 is 0
                ($ @).addClass 'feed-even'
                ($ @).removeClass 'feed-odd'
              else
                ($ @).removeClass 'feed-even'
                ($ @).addClass 'feed-odd'
