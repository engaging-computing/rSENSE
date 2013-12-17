$ ->
  if namespace.controller is "data_sets" and namespace.action is "edit"
  
    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        method: 'PUT'
        url: window.postURL
        success: (data, textStatus, jqXHR) ->
          window.location = data.redirect
      debug: false
    ($ '#editTable').editTable()
    