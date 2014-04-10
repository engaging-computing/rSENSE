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
    rowNum = 0 
    ($ '#editTable').find('tbody').find('tr').each (i,j) ->
      rowNum += 1
      ($ j).prepend("<td style='text-align: center'> " + rowNum + "</td>")      
    ($ '#editTable').find('tbody').find('tr').each (i,j) ->
       ($ j).find('td:first').removeAttr('input')
    removedRow = 0 
    ($ 'a.close').click ->
      rowNum -= 1
      console.log(rowNum)
      removedRow = parseInt(($ this).closest('tr').find('td:first').text())
      ($ '#editTable').find('tbody').find('tr').each (i,j) ->
        if(removedRow < parseInt(($ j).closest('tr').find('td:first').text())) 
          temp = parseInt(($ j).children(':first').text())
          temp -= 1
          ($ j).children(':first').text(temp).css('text-align', 'center')
    
    #field_count = ($ '#editTable').find('tr').eq(0).find('th').size()-1
    
    #($ '#editTable').find('tr').slice(1).each () ->
      #($ @).find('td:not(:last)').each () ->
        #($ @).attr 'width', "#{95 / (field_count)-1}%"
    