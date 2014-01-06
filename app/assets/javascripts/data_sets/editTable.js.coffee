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
    
    field_count = ($ '#editTable').find('tr').eq(0).find('th').size()
    
    ($ '#editTable').find('tr').slice(1).each () ->
      ($ @).find('td:not(:last)').each () ->
        ($ @).attr 'width', "#{95 / (field_count - 1)}%"
    