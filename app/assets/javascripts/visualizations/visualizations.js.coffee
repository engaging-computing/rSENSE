$ ->
  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis","show"]
    hidden = false
    originalWidth = 220
    $('#fullscreen-vis').click (e) ->
      fullscreenEnabled = document.fullscreenEnabled || document.mozFullScreenEnabled ||
      document.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement || document.mozFullScreenElement ||
      document.webkitFullscreenElement
      icon = $('#fullscreen-vis').find('i')
      if !fullscreenElement
        window.globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = $('#viscontainer')[0]
        browserFullscreenMethod = fullscreenVis.webkitRequestFullScreen || fullscreenVis.mozRequestFullScreen ||
        fullscreenVis.requestFullScreen || fullscreenVis.msRequestFullscreen
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

    $(document).on 'webkitfullscreenchange mozfullscreenchange fullscreenchange', ->
      if !hidden
        $('#controldiv').width(originalWidth)

      if $('#fullscreen-vis').attr('title') == 'Maximize'
        $('#fullscreen-vis').attr('title', 'Minimize')
      else if $('#fullscreen-vis').attr('title') == 'Minimize'
        $('#fullscreen-vis').attr('title', 'Maximize')
        window.globals.fullscreen = false

      $(window).trigger('resize')

    $('#control_hide_button').on 'click', () ->
      hidden = !hidden
