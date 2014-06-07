$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
    
    ### Maximize event ###
    fullscreen = () ->
      ($ '.navbar').hide()
      ($ '#dataset_info').hide()
      ($ '#title_row').hide()
      ($ '.footer').hide()
      ($ '.mainContent').data('padding',  ($ '.mainContent').parent().css('padding'))
      ($ '.mainContent').parent().css('padding',"")
      ($ '#fullscreen-viz').attr('title', 'Minimize')
      ($ '#viscontainer').css('margin', '0px')
      #($ '#outer').css('min-height', '')
      #($ '#viscontainer').css('height', '200px')
      #($ '.vis_canvas.ui-tabs-panel.ui-widget-content.ui-corner-bottom').css('height', '200px')
      fullscreenVis = ($ '#viscontainer')[0]
      browserMethod = fullscreenVis.requestFullScreen || fullscreenVis.webkitRequestFullScreen || fullscreenVis.mozRequestFullScreen;
      browserMethod.call(fullscreenVis)
      #console.log(($ document).find('body'))
      ###($ document).find('body').css({
        'min-height', '',
        'max-height', '70%'
      })
      ###
      #($ document).find('body').css('background-color', 'red')
      #($ 'div.container.mainContent.mc-wide').css('height', ($ '#outer').height())
      #($ '#viscontainer').css('height', '50%')
    ### Minimize event ###
    unfullscreen = () ->
      fullscreenVis = ($ '#viscontainer')[0]
      browserMethod = 
        document.cancelFullScreen or document.webkitExitFullscreen or document.mozCancelFullscreen or document.msCancelFullScreen or document.exitFullscreen
      console.log(browserMethod)
      browserMethod.call
      event = $.Event 'keydown'
      event.keyCode = 27
      console.log(event)
      console.log(event.keyCode)
      ($ document).trigger(event)
      #document.cancelFullScreen
      #document.webkitCancelFullScreen
      #document.mozCancelFullScreen
      ($ '.navbar').show()
      ($ '#dataset_info').show()
      ($ '#title_row').show()
      ($ '.footer').show()
      ($ '.mainContent').parent().css('padding',($ '.mainContent').data('padding'))
      ($ '#fullscreen-viz').attr('title', 'Maximize')
    ### What to do on min/max button click ###
    ($ '#fullscreen-viz').click ->
      console.log 'margin = ' + ($ '#viscontainer').css('margin')
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