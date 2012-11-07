# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
($ document).ready ->
  ($ '#add_data_trigger').click ->
     box = ($ this).parent()
     ($ this).remove()
     box.append '<img id="manual_upload_trigger" src="/assets/manual_upload.png" />OR<img id="file_upload_trigger" src="/assets/file_upload.png" />'
     ($ '#manual_upload_trigger').click (e) ->
        manual_upload box, e
     ($ '#file_upload_trigger').click (e) ->
        file_upload box, e
      
manual_upload = (box, evt) ->
  box.empty()
  box.append '<div class="row"><table id="manual_upload_table" class="span6"></table><a id="commit_data" class="span3">Commit</a></div>'
  table = ($ '#manual_upload_table')
  table.append '<thead><tr></tr></thead><tbody></tbody>'
  ($ '#session_data').find('thead').find('td').each ->
    table.find('thead').find('tr').append this
  table.find('thead').find('tr').append '<td>Add</td><td>Delete</td>'
  table.find('tbody').append '<tr></tr>'
  table.find('thead').find('td').each (i) ->
    if i < table.find('thead').find('td').length - 2
      table.find('tbody').find('tr').append '<td><input type="text" /></td>'
    else if i == table.find('thead').find('td').length - 2
      table.find('tbody').find('tr').append '<td><img src="/assets/add_content.png"></td>'
    else
      table.find('tbody').find('tr').append '<td><i class="icon-edit icon-white icon_content"></i>​</td>'
  box.find('#commit_data').click ->
    jData = []
    jHead = []
    table.find('tbody').find('tr').each (i) ->
      tmp = []
      ($ this).find('td').each (j) ->
        if j < ($ this).parent().find('td').length - 2
          tmp[j] = ($ this).find('input').val()
      jData[i] = tmp
    table.find('thead').find('td').each (i) ->
      if i < ($ this).parent().find('td').length - 2
        jHead[i] = ($ this).text()
    
    upload_data = 
      header : jHead
      data : jData
    
    console.log window.location.href + '/manualUpload'
    $.ajax 
      url: window.location.href + '/manualUpload'
      data: upload_data
      dataType: "json"
      type: "POST"
      success: (data, textStatus, jqXHR) ->
        console.log data
      
    
file_upload = (box, evt) ->
  box.empty()
  box.append('file')