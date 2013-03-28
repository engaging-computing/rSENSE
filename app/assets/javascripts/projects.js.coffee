# This is the coffeescript for the project controller
#
# ($ '#doc_box').modal
# Initializes the dropdown lightbox for google drive upload
#
# ($ '.liked_status').click ->
# Binds the click handlers for liking an project
#
# ($ '#projects .pagination a').live 'click', ->
# Binds a click handler to the project pagination links
# that requests the pagination data through ajax as a json object
#
# ($ '#projects_search').submit ->
# Binds an ajax request for searching projects to the #projects_search form
#
# ($ '.projects_filter_checkbox').click ->
# Binds a click handler to the filters (Math, Physics, Chemistry, etc.)
# that immediately searches for the filtered list of projects
#
# ($ '.projects_sort_select').change ->
# Calls the search with a new sort order (Newest, Oldest, Rated) when changed
#
# ($ '#upload_csv').click -> to ($ '#google_doc').click ->
# This is black magic that displays the upload csv and upload google doc lightboxes
#
# ($ '#save_doc').click ->
# Parse the Share url from a google doc to upload a csv from google drive
#
# ($ '#vis_button').click (e) ->
# Takes all sessions that are checked, appends its id to the url and
# redirects the user to the view sessions page (Vis page)

$ ->

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

  ($ '#doc_box').modal                 
    backdrop: 'static'
    keyboard: true
    show: false

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

  ($ '#projects .pagination a').live 'click', ->
      $.getScript this.href
      false

  $("#projects_search").submit ->
      $.ajax
        url: this.action
        data: $(this).serialize()
        success: (data, textStatus)->
          
          $('#projects').isotope('remove', $('.item'))
          
          addProjectButton = $("<div id='addProjectButton' style='text-align:center;cursor: pointer;' class='item'><img style='width:66%;' src='/assets/green_plus_icon.svg'><br /><h4 style='color:#0a0;'>Create Project</h4></img></div>")
          
          $('#projects').append(addProjectButton).isotope('insert', addProjectButton)
          
          $('#addProjectButton').click ->
            $.ajax
              type: "POST"
              url: "/projects/"
              data: {}
              dataType: "json"
              success: (data) =>
                window.location.replace("/projects/#{data['id']}");
          
          for object in data
            do (object) ->
              newItem =   "<div class='item'>"

              if(object.mediaPath)
                newItem += "<img src='#{object.mediaPath}'></img>"
                
              newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.projectPath}'>#{object.title}</a>"
              
              if(object.featured)
                newItem += "<span style='color:#57C142'> (featured)</span>"
            
              newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerPath}'>#{object.ownerName}</a><br />"
              newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"
              
              ###
              if(object.filters)
                newitem += "<b>#{object.filters}</b>"
              ###
              
              newItem +=  "</div>"
              
              newItem = $(newItem)
              
              $('#projects').append(newItem).isotope('insert', newItem)
          
          $(window).resize()
          
        dataType: "json"
      return false
      
  ($ '.projects_filter_checkbox').click ->
    ($ '#projects_search').submit()
    
  ($ '.projects_sort_select').change ->
    ($ '#projects_search').submit()
    
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
      
  ($ '#vis_button').click (e) ->
    targets = ($ @).parent().parent().find('table tbody tr input:checked')
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
# A File has been uploaded, decide what to do
#   ($ "#csv_file_form").ajaxForm (resp) ->
#     if resp["status"] == "success"
#       console.log "should redirect"
#     else
#       console.log "sending back mismatch data"
#       $.ajax
#         type: "POST"
#         dataType: "json"
#         url: "/projects/#{resp['eid']}/uploadCSV"
#         data:
#           mismatch: "true"
#           tmpFile: resp['tmpFile']
#         success: =>
#           console.log "fixed, should redirect"
