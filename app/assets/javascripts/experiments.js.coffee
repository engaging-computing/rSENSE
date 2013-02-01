# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
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