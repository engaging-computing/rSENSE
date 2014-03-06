  #Add submit event to object hider form. Performs AJAX request to update whether or not an object is hidden
$ ->
  ($ ".object_hider").submit ->
    type = ($ @).attr('type')
    data = {}
    data["#{type}"] = {}
    data["#{type}"]["hidden"] = $('.object_hidden_checkbox').is(':checked')

    $.ajax
      url: ($ @).attr('id')
      type: "PUT"
      dataType: "json"
      data:
        data
            
    false
      
  ($ '.object_hidden_checkbox').click ->
    ($ @).parent().submit()
