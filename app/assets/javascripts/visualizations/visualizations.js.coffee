$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]

    ($ '#fullscreen-viz').click (e) ->
      ($ document).trigger("webkitfullscreenchange")
    
    document.addEventListener("webkitfullscreenchange", () ->      
      console.log('Event handler called')
      if ($ '#fullscreen-vis').title() == 'Maximize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')
      if ($ '#fullscreen-vis').title() == 'Minimize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')  
      if (globals.fullscreen? and globals.fullscreen)
        window.globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        if document.webkitExitFullscreen
          document.webkitExitFullscreen()
        if document.mozCancelFullScreen
          document.mozCancelFullScreen()      
      else
        window.globals.fullscreen = true
        fullscreenVis = ($ '#viscontainer')[0]
        browserFullscreenMethod = fullscreenVis.requestFullScreen || fullscreenVis.webkitRequestFullScreen || fullscreenVis.mozRequestFullScreen
        browserFullscreenMethod.call(fullscreenVis)
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
    )