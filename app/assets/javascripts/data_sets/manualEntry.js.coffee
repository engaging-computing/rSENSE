$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"
  
    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.postURL
        method: 'POST'
      debug: true

    ($ '#manualTable').editTable(settings)

