$ ->
  ($ '#login_box').on 'show', ->    
    ($ '.login_button').click login_ajax_submit        
    ($ '.login_field').keydown (e) ->
      if e.which is 13 then login_ajax_submit()
    selectFunc = ->
      ($ "#login_user").select()
    setTimeout selectFunc, 300
     
  ($ '#login_box').on 'hide', ->  
    ($ '#login_box a.btn').off 'click'
  
  ($ '.cancel_login_button').click ->
    ($ '#login_box').modal 'hide'
    ($ '#login_user').css 'border-color', 'black'
    ($ '#login_password').css 'border-color', 'black'
  
  #($ '#login_box').on 'hidden', ->
      #($ '#login_box').hide()

  ($ '#login_box').modal                 
    backdrop: 'static'
    keyboard: true
    show: false

  login_ajax_submit = ->
    $.ajax
        url: '/login'
        type: 'POST'
        dataType: 'json'
        data:
          username_or_email: ($ '#login_user').val()
          password: ($ '#login_password').val()
        success: (data) ->
          switch data.status
            when 'success'
              ($ '#login_box').modal 'hide'
              target =  $.data($('#login_box')[0], "redirect")
              if target isnt undefined
                window.location = target
              else
                location.reload(true)
            when 'fail'
              ($ '#login_user').errorFlash()
              ($ '#login_password').errorFlash()
             #($ '#login_user').css 'background','red'
             #($ '#login_password').css 'background','red'
            
  
  ($ 'a.login').click ->
    ($ '#login_box').modal()
    false
  
    
