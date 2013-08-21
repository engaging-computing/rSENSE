$ ->

  hide_upload = ->
    if ($ 'table.fields_table tbody tr').size() == 0
      ($ '#create_data_set').hide()
      ($ "#template-from-file").show()
    else
      ($ '#create_data_set').show()
      ($ "#template-from-file").hide()

  delayed_hide = -> setTimeout( (-> hide_upload()), 200 )




  ### New Fields Shit -------------------------------------------------------------###
  ($ '.edit_fields_btn').click ->
    root = ($ @).parent().parent()
    table =  root.find('.mytable')
    can_delete_fields = if table.attr('can_delete_fields') is "true" then true  else false

    # Save state of the div incase of cancel
    root.data("table", table.html())

    #Hide the edit button
    row = ($ @).parent()
    row.hide()
    
    # Turn editable fields into input boxes
    table.find('.fields').each ->
      type_val = ($ @).find('.field_type').find("div").html()
      field_id = ($ @).find('.field_name').attr("field_id")
 
      if(type_val not in ['Latitude','Longitude'])
        name_val = ($ @).find('.field_name').find("div").html()
        unit_val = ($ @).find('.field_unit').find("div").html()
        ($ @).find('.field_name').html("<input type='text' class='input-small' value='#{name_val.trim()}'>")
        ($ @).find('.field_unit').html("<input type='text' class='input-small' value='#{unit_val.trim()}'>")
        
        if can_delete_fields
          delete_link = ($ "<a href='/fields/#{field_id}' class='field_delete_link'><i class='icon-remove' style='float:right;display:block'></i></a>") 
          ($ @).find('.field_type').find("div").append delete_link
          delete_link.click remove_field
          delete_link.show()
    ($ '.fields_edit_menu').show()
    
  ($ '.cancel_field_changes_btn').click ->
    root = ($ @).parent().parent()
    
    #Hide the menu, show the edit button
    row = ($ @).parent()
    row.hide()
    ($ '.fields_edit_option').show()
    
    #Restore old state of fields table
    ($ '.mytable').html(root.data("table"))
    
  ($ '.save_field_changes_btn').click ->
    row = ($ @).parent()
    root = ($ @).parent().parent()
    table =  root.find('.mytable')
    data = {}
    data['changes'] = {}
    table.find('.fields').each ->
      field_name = ($ this).find(".field_name")
      field_name.find("input").popover "destroy"
      data['changes'][field_name.attr('field_id')] = 
        name: field_name.find("input").val()
        unit: ($ this).find('.field_unit').find("input").val()
    
    #Try to save changes. 
    $.ajax
      url: '/projects/12/updateFields'
      type: "post"
      dataType: "json"
      data: 
        data
      success: (msg) =>
        table.find('.fields').each ->
          ($ @).find('i').remove()
          type_val = ($ @).find('.field_type').find("div").html()
          if(type_val not in ['Latitude','Longitude'])
            field_name = ($ this).find(".field_name")
            field_name_value = field_name.find("input").val()
            field_name.html("<div>#{field_name_value}</div>")
            field_unit = ($ this).find(".field_unit")
            field_unit_value = field_unit.find("input").val()
            field_unit.html("<div>#{field_unit_value}</div>")
            row.hide()
            ($ '.fields_edit_option').show()
      error: (msg) =>
        errors = JSON.parse msg.responseText
        for key,value of errors
          tmp = root.find("[field_id='#{key}']").find("input")
          tmp.errorFlash()
          tmp.popover
            content: value
            placement: "left"
            trigger: "manual"
          tmp.popover "show"
          
  remove_field = ->

    root = ($ @).parents('tr')
    type = helpers.get_field_type root.find('.field_type').text() 
    pair_field = null
    field_name = root.find('.field_name').find("input").val()
    if(helpers.confirm_delete "#{field_name}")
      if not (type in [(helpers.get_field_type "Latitude"), (helpers.get_field_type "Longitude")])
        $.ajax
          url: ($ @).attr('href')
          type: "DELETE"
          dataType: "json"
          success: (msg) =>
            root.find("div, input").hide_row =>  
              root.remove()
              ($ 'tr.fields').filter(':visible').each (idx) -> 
                if idx % 2 is 0
                  ($ @).addClass 'feed-even'
                  ($ @).removeClass 'feed-odd'
                else
                  ($ @).removeClass 'feed-even'
                  ($ @).addClass 'feed-odd'
          error: (msg) =>
            console.log msg      
    false