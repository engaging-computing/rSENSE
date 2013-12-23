$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"
  
    settings =
      page_name: "manualEntry"
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.postURL
        method: 'POST'
        success: (data, textStatus, jqXHR) ->
          new_data = {}
          new_data['data_set'] =
            title: ($ '#data_set_name').val()
            
          $.ajax
            url: data.url
            type: 'PUT'
            dataType: 'json'
            data: new_data
            success: ->
              window.location = data.url
            error: (j, s, t) =>
              ($ '#mainContent').prepend "<div class='alert alert-danger alert-dismissable'><strong>An error occurred: </strong> #{}</div>"
              alert 'Something went HORRIBLY wrong.'
              console.log j
              console.log s
              console.log t
        
      debug: false
    ($ '#manualTable').editTable(settings)
    