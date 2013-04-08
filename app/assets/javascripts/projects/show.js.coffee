$ ->
  # A File has been uploaded, decide what to do
  ($ "#csv_file_form").ajaxForm (resp) ->
    if resp["status"] == "success"
      window.location = resp['redirect']
    else
      ($ "#match_table").html ''
      ($ "#match_table").append "<tr><th> Experiment Field </th> <th> CSV Header </th></tr>"
      
      for field, fieldIndex in resp["fields"]

        options = "<option value='-1'> Select One... </option>"
        for header, headerIndex in resp['headers']
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
          eid: resp.eid
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
          url: "/projects/#{resp['eid']}/uploadCSV"
          data: matchData
          success: (resp) ->
            window.location = resp['redirect']
          error: (resp) ->
            alert "Somthing went horribly wrong. I'm sorry."
      
      ($ "#match_box").modal
        backdrop: 'static'
        keyboard: true  
        
  load_qr = ->
    ($ '#exp_qr_tag').empty()
    ($ '#exp_qr_tag').qrcode { text : window.location.href, height: ($ '#exp_qr_tag').width(), width: ($ '#exp_qr_tag').width() }
  
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

  # Initializes the dropdown lightbox for google drive upload
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
  
  ($ '#csv_file_input').change ->
    ($ '#csv_file_form').submit()
    
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
      eid = tmp[1]
      url = "/data_sets/#{eid}/postCSV"
      $.ajax( { url: url, data: { key: key, id: eid } } ).done (data, textStatus, error) ->
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
    eid = ses[1]
    ses_list = (grab_ses t for t in targets )
    url = '/projects/' + eid + '/data_sets/' + ses_list.join ','
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
