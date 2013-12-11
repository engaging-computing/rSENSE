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
          console.log data
          console.log textStatus
          console.log jqXHR
          helpers.name_popup data, "Dataset", "data_set", ""
      debug: false
    ($ '#manualTable').editTable(settings)
    