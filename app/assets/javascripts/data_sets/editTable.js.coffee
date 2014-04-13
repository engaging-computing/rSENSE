$ ->
  if namespace.controller is "data_sets" and namespace.action is "edit"
     settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/edit"
        success: (data, textStatus, jqXHR) ->
          redirect = window.location.pathname.split "/"
          redirect.pop()
          url = redirect.join "/"
          window.location = url
          
    ($ '#editTable').editTable(settings)
    
    rowNum = 1
    ($ '#editTable').find('tbody').find('tr').each (i,j) ->
      ($ j).prepend("<td style='width:10%;text-align:center'>" + rowNum + "</td>")
      rowNum += 1
    field_count = ($ '#editTable').find('tr').eq(0).find('th').size()-2
    
    ($ '#editTable').find('tr').slice(1).each () ->
      ($ @).find('td:not(:last):not(:first)').each () ->
        ($ @).attr 'width', "#{85 / (field_count)}%"
      
    remove = ($ '#editTable').find('thead').find('tr').find('th').length
    console.log(remove)    
    #($ '#editTable').find('tbody').find('tr').each (i,j) ->
      #temp = ($ j).find(":nth-child(#{remove})").text()
      #($ j).find(":nth-child(#{remove})").remove()
      #($ j).find(":nth-child(#{remove})").text(temp)
    ($ '#edit_table_add').click ->
      ($ '#editTable').find('tbody').find('tr:last').prepend("<td style='width:10%;text-align:center'>" + ($ '#editTable').find('tbody').find('tr').length + "</td>")
    