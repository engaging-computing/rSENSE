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
          console.log redirect
    
    ($ '#editTable').editTable(settings)
    