$ ->
  if namespace.controller is "projects" and namespace.action is "show"
    ### EDIT BUTTON CLICK ###
    ($ '.edit_fields_btn').click ->
      root = ($ @).parent().parent()
      table =  root.find('.fields_table')
      $.ajax
        url: ''
        dataType: 'json'
        type: 'GET'
        data:
          recur: false
        success: (msg) =>
          can_delete_fields = if msg.dataSetCount == 0 then true else false

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
              ($ @).find('.field_name').html("<input type='text' class='input-small' value='#{name_val.trim()}'>")
              if( type_val is 'Number')
                unit_val = ($ @).find('.field_unit').find("div").html()
                ($ @).find('.field_unit').html("<input type='text' class='input-small' value='#{unit_val.trim()}'>")
              
        error: (msg) =>
          console.log msg
          
      ($ '.fields_edit_menu').show()
    
    ### SAVE BUTTON CLICK ###
    ($ '.save_field_changes_btn').click ->
      row = ($ @).parent()
      root = ($ @).parent().parent()
      table =  root.find('.fields_table')
      data = {}
      data['changes'] = {}
      
      if table.data("num_fields") > 0
        table.find('.fields').each ->
          field_type = ($ this).find('td.field_type').attr('value')
          field = ($ this).find(".field_name")
          if field_type not in ["Latitude", "Longitude"]
            field.find("input").popover "destroy"
            data['changes'][field.attr('field_id')] = 
              name: field.find('input').val()
              unit: ($ this).find('.field_unit').find("input").val()
     
        if data['changes'] != {}
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
                  if type_val is 'Number'
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
        else
          console.log "in here"
          table.find('.fields').each ->
            type_val = ($ @).find('.field_type').attr('value')
          row.hide()
          ($ '.fields_edit_option').show()
          ($ '#template_from_file').show()
      else
        row.hide()
        ($ '.fields_edit_option').show()
        ($ '#template_from_file').show()
        
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
              recolored = false
              tbody = row.parents('tbody')
              row.delete_row =>
                row.remove()
                tbody.recolor_rows(recolored)
                recolored = true
              table.data("num_fields",msg.num_fields)
              if msg.num_fields == 0
                ($ '#create_data_set').hide()
                ($ '#template_from_file').show()
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
                  r = ($ this)
                  recolored = false
                  tbody = r.parents('tbody')
                  r.delete_row =>
                    r.remove()
                    tbody.recolor_rows(recolored)
                    recolored = true
                  table.data("num_fields",msg.num_fields)
                  if msg.num_fields == 0
                    ($ '#create_data_set').hide()
                    ($ '#template_from_file').show()
                  ($ '#add-field-dropdown ul li a#add_location_field').show()
                error: (msg) =>
                  console.log msg 
      false
    
    add_row = (msg) ->

      type = if msg.field_type? then msg.field_type else msg.type
        
      table = ($ '.fields_table')
      htmlStr = ""
      typeName = helpers.get_field_name type
      isNotLoc = typeName not in ["Latitude","Longitude"]
      isNumber = typeName is 'Number'
      
      htmlStr = $ """
      <tr class="fields">
      <td class='field_name' field_id='#{msg.id}'>#{if isNotLoc then "<input type='text' class='input-small' value='#{msg.name}'>" else "<div>#{msg.name}</div>"}</td>
      <td class='field_unit'>#{if isNumber then "<input type='text' class='input-small' value='#{msg.unit}'>" else "<div>#{msg.unit}</div>"}</td>
      <td class='field_type' value='#{helpers.get_field_name type}'><div>#{typeName}<a href='/fields/#{msg.id}' class='field_delete_link'><i class='icon-remove' style='float:right;display:block'></i></a></div></td>
      </tr>
      """

      delete_field_btn = htmlStr.find('.field_delete_link')
      delete_field_btn.click remove_field
      delete_field_btn.show()
      table.append htmlStr
      table.find("tbody").recolor_rows(false)
      
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
          table.data("num_fields",1)
          add_row(msg)
          ($ '#template_from_file').hide()
          ($ '#create_data_set').show()
        error: (msg) =>
            console.log msg
            
            
    respond_template = ( resp ) ->
      ($ 'button.finished_button').addClass 'disabled'

      ($ '#template_match_table').html ''
      ($ '#template_match_table').append '<tr><th> Field Name </th><th> Field Unit </th><th> Field Type </th></tr>'

      for field, field_index in resp.fields
        options = "<option value='-1'>Select One...</option>"
        for type, type_index in resp.p_field_types[field_index]
          options += "<option value='#{type_index}'>#{type}</option>"

        html = "<tr><td class='field_name'>#{field.name[0..29]}"

        if field.name.length > 29
          html += '...'

        html += "</td><td><input type='text' class='field_unit' /></td><td><select>#{options}</select></td></tr>"

        ($ '#template_match_table').append html

      ($ "button.cancel_upload_button").click ->
          ($ "#template_match_box").modal("hide")

      ($ "#template_match_table select").change ->
        check = true
        for sel in ($ '#template_match_table').find(':selected')
          if ($ sel).text() == "Select One..."
            check = false

        if check
          ($ 'button.finished_button').removeClass 'disabled'
        else
          ($ 'button.finished_button').addClass 'disabled'


      ($ "button.finished_button").click ->
        if !($ 'button.finished_button').hasClass('disabled')
          newFields =
            pid: resp.pid
            names: []
            units: []
            types: []

          for names in ($ '#template_match_table').find('.field_name')
            newFields.names.push ($ names).text()

          for units in ($ '#template_match_table').find('.field_unit')
            newFields.units.push ($ units).val()

          for types in ($ '#template_match_table').find(':selected')
            newFields.types.push ($ types).text()

          table = ($ '.fields_table')

          $.ajax
            type: "POST"
            dataType: "json"
            url: "#{window.location.pathname}/templateFields"
            data: {save: true, fields: newFields}
            success: (resp) ->
              ($ "#template_match_box").modal("hide")
              table.data("num_fields",1)
              ($ '#create_data_set').show()
              for field in resp.fields
                add_row(field)

      ($ "#template_match_box").modal
          backdrop: 'static'
          keyboard: true        
          
    ($ '#template_from_file').click ->
      ($ '#template_file_input').click()
      false    
          
    ($ '#template_file_input').change ->
      ($ '#template_file_form').attr 'action', "#{window.location.pathname}/templateFields"
      ($ '#template_file_form').submit()        
            
    ($ "#template_file_form").ajaxForm (resp) ->
      respond_template(resp)       
            
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
      ($ '#add-field-dropdown ul li a#add_location_field').hide()
    
    
              
      
