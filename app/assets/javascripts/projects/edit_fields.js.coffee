$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    ($ '#fields_table').keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()

    ($ '#number').click ->
      ($ '#text_fields').val('1')
      ($ '#fields_table').submit
      
    ($ '#text').click ->
      ($ '#num_fields').val('1')
      ($ '#fields_table').submit
      
    ($ '.field_delete').click (e) ->
      e.preventDefault()
      root = ($ @).parents('tr')
      $.ajax
        url: ($ @).attr('href')
        dataType: 'json'
        type: 'DELETE'
        data:
          field: ($ @).attr('fid')
        success: (msg) ->
          if root.hasClass('location')
            ($ 'tr.location').each ->
              ($ this).remove()
          else
            root.remove()
          
          $('#options').load(document.URL +  ' #options')
            

        error:(msg) ->
          response = $.parseJSON msg['responseText']
          error_message = response.errors.join "</p><p>"

          ($ '.container.mainContent').find('form').before """
            <div class="alert alert-danger fade in">
              <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
              <h4>Error Removing Field:</h4>
              <p>#{error_message}</p>
              <p>
                <button type="button" class="btn btn-danger error_bind" data-retry-text"Retrying...">Retry</button>
                <button type="button" class="btn btn-default error_dismiss">Or Dismiss</button>
              </p>
            </div>"""
          
          ($ '.error_dismiss').click ->
            ($ '.alert').alert 'close'
          
          ($ '.error_bind').click ->
            
            ($ '.error_bind').button 'loading'
            
            target = root.find '.field_delete'
            
            $.ajax
              url: ($ target).attr('href')
              dataType: 'json'
              type: 'DELETE'
              data:
                field: ($ target).attr('fid')
              success: (msg) ->
                ($ '.error_bind').button 'reset'
                if root.hasClass('location')
                  root.parents('table').find('tr.location').each ->
                  ($ this).remove()
                else
                  root.remove()
                
                ($ '.alert').alert 'close'
                
              error: (msg) ->
                ($ '.error_bind').button 'reset'
                