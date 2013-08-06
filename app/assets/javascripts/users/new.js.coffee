$ ->
  if namespace.controller is "users" and namespace.action is "new"
    ($ "#register").click ->
      data = 
        user:
          firstname: ($ "#firstname").val()
          lastname: ($ "#lastname").val()
          username: ($ "#username").val()
          email: ($ "#email").val()
          password: ($ "#password").val()
          password_confirmation: ($ "#password_confirmation").val()
          
      ($ "#firstname").popover "destroy"
      ($ "#lastname").popover "destroy"
      ($ "#username").popover "destroy"
      ($ "#email").popover "destroy"
      ($ "#password").popover "destroy"
          
      $.ajax
        url: "/users"
        type: "POST"
        data: data
        dataType: "json"
        success: (dat) ->
          window.location = dat.url
        error: (j, s, t) ->
          errors = JSON.parse j.responseText
          
          for field, error of errors
            do (error) ->
              element = null
              message = ""
            
              switch field
                when "firstname"
                  element = ($ "#firstname")
                  message = "First Name " + error[0]
                when "lastname"
                  element = ($ "#lastname")
                  message = "Last Name " + error[0]
                when "username"
                  element = ($ "#username")
                  message = "Username " + error[0]
                when "email"
                  element = ($ "#email")
                  message = "Email " + error[0]
                when "password", "password_digest"
                  element = ($ "#password")
                  message = "Password " + error[0]
              
              element.errorFlash()
              element.popover
                content: message
                placement: "right"
                trigger: "manual"
                
              element.popover "show"
            