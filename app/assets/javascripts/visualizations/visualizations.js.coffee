$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
  
    ($ '#fullscreen-viz').click (e) ->  
      fullscreenEnabled = document.fullscreenEnabled || document.mozFullScreenEnabled || document.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement  
      icon = ($ '#fullscreen-viz').find('i')
      if !fullscreenElement
        window.globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = ($ '#viscontainer')[0]
        browserFullscreenMethod = fullscreenVis.webkitRequestFullScreen || fullscreenVis.mozRequestFullScreen || fullscreenVis.requestFullScreen || fullscreenVis.msRequestFullscreen  
        browserFullscreenMethod.call(fullscreenVis)
      else
        window.globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        if document.webkitExitFullscreen
          document.webkitExitFullscreen()
        else if document.mozCancelFullScreen
          document.mozCancelFullScreen()  
        else if (document.cancelFullScreen)
          document.cancelFullScreen()
        else if (document.msExitFullscreen)
          document.msExitFullscreen()
          
    ($ document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange', ->
      #Deal with Safari resizing peculiarities
      if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1)
        ($ window).trigger('resize')
      if ($ '#fullscreen-viz').attr('title') == 'Maximize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')
      else if ($ '#fullscreen-viz').attr('title') == 'Minimize'
        ($ '#fullscreen-viz').attr('title', 'Maximize')
    )