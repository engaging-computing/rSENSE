$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
    
    ### Maximize event ###
    fullscreen = () ->
      ($ '.navbar').hide()
      ($ '#dataset_info').hide()
      ($ '#title_row').hide()
      ($ '.footer').hide()
      console.log ($ '.mainContent').data('padding',  ($ '.mainContent').parent().css('padding'))
      ($ '#viscontainer').css( 'height', Math.floor(($ document).height *.1))
      ($ '.mainContent').data('padding',  ($ '.mainContent').parent().css('padding'))
      ($ '.mainContent').parent().css('padding',"")

    ### Minimize event ###
    unfullscreen = () ->
      ($ '.navbar').show()
      ($ '#dataset_info').show()
      ($ '#title_row').show()
      ($ '.footer').show()
      ($ '.mainContent').parent().css('padding',($ '.mainContent').data('padding'))
    
    ### What to do on min/max button click ###
    ($ '#fullscreen-viz').click ->
      icon = ($ this).find('i')
      if (globals.fullscreen? and globals.fullscreen)
        window.globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        unfullscreen()
      else
        window.globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreen()
      ($ window).trigger('resize')
    
    
