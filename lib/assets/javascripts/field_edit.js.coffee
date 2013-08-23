$ ->

  ### EDIT BUTTON CLICK ###
  ($ '.edit_fields_btn').click ->
    root = ($ @).parent().parent()
    table =  root.find('.fields_table')
    can_delete_fields = if table.attr('can_delete_fields') is "true" then true  else false

    row = ($ @).parent()
    row.hide()
    
    table.find('.fields').each ->
      type_val = ($ @).find('.field_type').attr('value')
      field_id = ($ @).find('.field_name').attr("field_id")
      if can_delete_fields
          delete_link = ($ "<a href='/fields/#{field_id}' class='field_delete_link'><i class='icon-remove' style='float:right;display:block'></i></a>") 
          ($ @).find('.field_type').find("div").append delete_link
          delete_link.click remove_field
          delete_link.show()
      if(type_val not in ['Latitude','Longitude'])
        name_val = ($ @).find('.field_name').find("div").html()
        unit_val = ($ @).find('.field_unit').find("div").html()
        ($ @).find('.field_name').html("<input type='text' class='input-small' value='#{name_val.trim()}'>")
        ($ @).find('.field_unit').html("<input type='text' class='input-small' value='#{unit_val.trim()}'>")
        
        
    ($ '.fields_edit_menu').show()
  
  ### SAVE BUTTON CLICK ###
  ($ '.save_field_changes_btn').click ->
    row = ($ @).parent()
    root = ($ @).parent().parent()
    table =  root.find('.fields_table')
    data = {}
    data['changes'] = {}
    
    table.find('.fields').each ->
      field_name = ($ this).find(".field_name").find("input")
      if field_name.val() not in ["Latitude", "Longitude"]
        field_name.find("input").popover "destroy"
        data['changes'][($ this).find(".field_name").attr('field_id')] = 
          name: field_name.val()
          unit: ($ this).find('.field_unit').find("input").val()
          
    $.ajax
      url: '/projects/12/updateFields'
      type: "post"
      dataType: "json"
      data: 
        data
      success: (msg) =>
        table.find('.fields').each ->
          ($ @).find('i').remove()
          type_val = ($ @).find('.field_type').attr('value')
          if(type_val not in ['Latitude','Longitude'])
            field_name = ($ this).find(".field_name")
            field_name_value = field_name.find("input").val()
            field_name.html("<div>#{field_name_value}</div>")
            field_unit = ($ this).find(".field_unit")
            field_unit_value = field_unit.find("input").val()
            field_unit.html("<div class='truncate'>#{field_unit_value}</div>")
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
       
  ### SLIDE HIDE ###
  delete_row = (row) ->     
    row.find("div, input").hide_row =>  
      row.remove()
      ($ 'tr.fields').filter(':visible').each (idx) -> 
        if idx % 2 is 0
          ($ @).addClass 'feed-even'
          ($ @).removeClass 'feed-odd'
        else
          ($ @).removeClass 'feed-even'
          ($ @).addClass 'feed-odd'   
  
  recolor_rows = () ->
    ($ 'tr.fields').filter(':visible').each (idx) -> 
      if idx % 2 is 0
        ($ @).addClass 'feed-even'
        ($ @).removeClass 'feed-odd'
      else
        ($ @).removeClass 'feed-even'
        ($ @).addClass 'feed-odd'   

  ### DELETE BUTTON CLICK ###
  remove_field = ->
    table = ($ '.fields_table')

    row = ($ @).parents('tr')
    type = helpers.get_field_type row.find('.field_type').text() 
    pair_field = null
    field_name = row.find('.field_name').find("input").val()

    if not (type in [(helpers.get_field_type "Latitude"), (helpers.get_field_type "Longitude")])
      if(helpers.confirm_delete "#{field_name}")
        $.ajax
          url: ($ @).attr('href')
          type: "DELETE"
          dataType: "json"
          data:
            project_id: table.attr('project')
          success: (msg) =>
            delete_row row
            if msg.num_fields == 0
              ($ '#create_data_set').hide()
          error: (msg) =>
            console.log msg
    else     
      if(helpers.confirm_delete "Latitude & Longitude")
        table.find('.fields').each ->
          type_val = helpers.get_field_type ($ this).find('.field_type').text() 
          if (type_val in [(helpers.get_field_type "Latitude"), (helpers.get_field_type "Longitude")])
            $.ajax
              url: ($ this).find('.field_delete_link').attr('href')
              type: "DELETE"
              dataType: "json"
              data:
                project_id: table.attr('project')
              success: (msg) =>
                delete_row ($ this)
                if msg.num_fields == 0
                  ($ '#create_data_set').hide()
              error: (msg) =>
                console.log msg 
    false
  
  ### ADD FIELD ###
  addField = (typeName) ->

    type = helpers.get_field_type typeName
    unit = helpers.get_default_unit type
    table = ($ '.fields_table')
    editable = true
   
    $.ajax
      url: "/fields/"
      type: "POST"
      dataType: "json"
      data:
        field:
          project_id: table.attr 'project'
          name: typeName
          unit: unit
          field_type: type
      success: (msg) =>
        htmlStr = ""
        if typeName not in ["Latitude", "Longitude"]
          htmlStr = $ """
          <tr class="fields">
          <td class='field_name' field_id='#{msg.id}'><input type='text' class='input-small' value='#{msg.name}'></td>
          <td class='field_unit'><input type='text' class='input-small' value='#{msg.unit}'></td>
          <td class='field_type' value='#{helpers.get_field_name msg.type}'><div>#{typeName}<a href='/fields/#{msg.id}' class='field_delete_link'><i class='icon-remove' style='float:right;display:block'></i></a></div></td>
          </tr>
          """
        else
          htmlStr = $ """
          <tr class="fields">
          <td class='field_name' field_id='#{msg.id}'><div>#{msg.name}</div></td>
          <td class='field_unit'><div>#{msg.unit}</div></td>
          <td class='field_type' value='#{helpers.get_field_name msg.type}'><div>#{typeName}<a href='/fields/#{msg.id}' class='field_delete_link'><i class='icon-remove' style='float:right;display:block'></i></a></div></td>
          </tr>
          """
        delete_field_btn = htmlStr.find('.field_delete_link')
        delete_field_btn.click remove_field
        delete_field_btn.show()
        table.append htmlStr
        recolor_rows()
        ($ '#create_data_set').show()
      error: (msg) =>
          console.log msg
          
  ### ADD FIELD CLICKS ###
  ($ '#add_timestamp_field').click -> 
    addField 'Timestamp'
  ($ '#add_number_field').click -> 
    addField 'Number'
  ($ '#add_text_field').click -> 
    addField 'Text'
  ($ '#add_location_field').click -> 
    addField 'Latitude'
    addField 'Longitude'
    ($ '#add-field-dropdown ul li a.add_location_field').hide()
  
  
            
    