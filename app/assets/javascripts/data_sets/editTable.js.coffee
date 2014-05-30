IS.onReady "data_sets/edit", ->
  setupEditTable()

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
    
    field_count = ($ '#editTable').find('tr').eq(0).find('th').size() - 1
    
    ($ '#editTable').find('tr').slice(1).each () ->
      ($ @).find('td:not(:last)').each () ->
        ($ @).attr 'width', "#{95 / (field_count)}%"
    ($ '#edit_table_add').click ->
      ($ @).find('td:not(:last)').each () ->
        ($ @).attr 'width', "#{95 / (field_count)}%"

IS.onReady "data_sets/manualEntry", ->
  setupEditTable()
