# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  #selection of featured image
  ($ '.featured_image_selector').click ->
    mo = ($ @).attr("mo_id")
    exp = ($ @).attr("exp_id")
    
    data={}
    data["experiment"] = {}
    data["experiment"]["featured_media_id"] = mo
    
    ($ @).parent().parent().parent().find('.featured_image_selector').each ->
          if ($ this).attr("mo_id") != mo
            ($ this).attr("checked", false)
    $.ajax
      url: "/experiments/#{exp}"
      type: "PUT"
      dataType: "json"
      data:
         data

        
  
  
  # Needs commenting
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
      url: '/experiments/' + ($ this).attr('exp_id') + '/updateLikedStatus'
      dataType: 'json'
      success: (resp) =>
        ($ @).siblings('.like_display').html resp['update']

  ($ '#experiments .pagination a').live 'click', ->
      $.getScript this.href
      false

  ($ '#experiments_search').submit ->
      $.get this.action, ($ this).serialize(), null, 'script'
      false
      
  ($ '.experiments_filter_checkbox').click ->
    ($ '#experiments_search').submit()
    
  ($ '.experiments_sort_select').change ->
    ($ '#experiments_search').submit()
    
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
      tmp = window.location.pathname.split 'experiments/'
      eid = tmp[1]
      url = "/experiment_sessions/#{eid}/postCSV"
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
    url = '/experiments/' + eid + '/sessions/' + ses_list.join ','
    window.location = url
    
  grab_ses = (t) ->
    ses = ($ t).attr 'id'
    ses = ses.split '_'
    ses[3]
    