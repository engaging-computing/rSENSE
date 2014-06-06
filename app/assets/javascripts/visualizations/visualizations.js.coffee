$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
    
    ### Maximize event ###
    fullscreen = () ->
      ($ '.navbar').hide()
      ($ '#dataset_info').hide()
      ($ '#title_row').hide()
      ($ '.footer').hide()
      console.log ($ '.mainContent').data('padding',  ($ '.mainContent').parent().css('padding'))
      ($ '#viscontainer').css( 'height', Math.floor(($ document).height *.1) + "px")
      ($ '.mainContent').data('padding',  ($ '.mainContent').parent().css('padding'))
      ($ '.mainContent').parent().css('padding',"")
      ($ '#fullscreen-viz').prop('title', 'Minimize')

    ### Minimize event ###
    unfullscreen = () ->
      ($ '.navbar').show()
      ($ '#dataset_info').show()
      ($ '#title_row').show()
      ($ '.footer').show()
      ($ '.mainContent').parent().css('padding',($ '.mainContent').data('padding'))
      ($ '#fullscreen-viz').prop('title', 'Maximize') 
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
      ($ '#viscontainer').css('height', ($ window).height() * .90)
      ($ '#controldiv').css('height', ($ '#viscontainer').height())
      ($ '#map_canvas').css('height', ($ '#controldiv').height())
      ($ '#scatter_canvas').css('height', ($ '#viscontainer').height())
      ($ '#timeline_canvas').css('height', ($ '#controldiv').height())
      ($ '#bar_canvas').css('height', ($ '#controldiv').height())
      ($ '#histogram_canvas').css('height', ($ '#controldiv').height())
      ($ '#table_canvas').css('height', ($ '#controldiv').height())
      ($ '#summary_canvas').css('height', ($ '#controldiv').height())
      ($ '#photos_canvas').css( 'height', ($ '#controldiv').height())
      ($ '.highcharts-container').css('height', ($ '#viscontainer').height())
    
