$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"
  
    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.postURL
        method: 'POST'
        success: (data, textStatus, jqXHR) ->
          window.location = data.redirect
      debug: false
    ($ '#manualTable').editTable(settings)
    