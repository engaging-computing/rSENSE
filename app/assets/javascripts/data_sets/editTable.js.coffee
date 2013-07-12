$ ->
  if namespace.controller is "data_sets" and namespace.action is "edit"

    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: location.pathname
        method: 'POST'
      debug: true

    ($ '#editTable').editTable(settings)