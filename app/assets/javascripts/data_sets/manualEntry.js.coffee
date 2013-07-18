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
          helpers.name_dataset data.title, data.datasets, () ->
            window.location = data.redirect
      debug: false

    ($ '#manualTable').editTable(settings)
    