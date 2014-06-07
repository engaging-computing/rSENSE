$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
  
    divWidth = ($ '#controldiv').width()
    ($ '#fullscreen-viz').click (e) ->  
      console.log divWidth
      fullscreenEnabled = document.fullscreenEnabled || document.mozFullScreenEnabled || document.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
      console.log fullscreenElement
      console.log fullscreenEnabled
      console.log document.mozFullScreenEnabled
      console.log document.webkitFullscreenEnabled
      console.log("FULL SCREEN ELEMENT: #{fullscreenElement}")
      if ($ '#fullscreen-viz').attr('title') == 'Maximize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')
      else if ($ '#fullscreen-viz').attr('title') == 'Minimize'
        ($ '#fullscreen-viz').attr('title', 'Maximize')  
      icon = ($ '#fullscreen-viz').find('i')
      if !fullscreenElement
        window.globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = ($ '#viscontainer')[0]
        browserFullscreenMethod = fullscreenVis.webkitRequestFullScreen || fullscreenVis.mozRequestFullScreen || fullscreenVis.requestFullScreen  
        if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1) 
          ($ '#title_row').hide()
          ($ 'nav').hide()
          ($ '.footer').hide()
          ($ '#outer').bind('mousewheel', ->
            false
          )
          ($ '#viscontainer').bind('mousewheel', ->
            #console.log('Hellooooo')
            #($ '#outer').unbind()
          )
          ($ '#viscontainer').mouseout( ->
            ($ 'body').scrollTop(0);
            ($ '#outer').bind('mousewheel', ->
            false
            )
            
          )
          ($ '#viscontainer').css(
            'height', (($ '.div.container.mainContent').height() * .9)
            'width',100%
            'padding', 0
          )
          ($ 'div.container.mainContent').css('padding', 0, 'margin', 0, 'overflow', 'hidden')
          ($ '#outer').css('padding', 0, 'overflow', 'hidden')
          ($ window).trigger('resize')
        else
          browserFullscreenMethod.call(fullscreenVis)
        console.log("Browser Method:  #{browserFullscreenMethod}")
        #if fullscreenVis.webkitRequestFullScreen
        #($ document).trigger('resize')
      else
        window.globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        if document.webkitExitFullscreen
          if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1) 
            console.log('Its Safari')
            ($ '#title_row').show()
            ($ '.nav.navbar.navbar-default.navbar-static-top').show()
            ($ '#viscontainer').css(
              'height', ''
              'width',''
            )

          #($ window).trigger('resize')
          #($ '#control_hide_button').click().delay(500)
          #($ '#controldiv').css('width', "#{divWidth}px")
          #($ '#control_hide_button').trigger('click')
          document.webkitExitFullscreen()
          #($ '#control_hide_button').click().delay(500)
          console.log "Curvis = #{globals.curVis}"
          #window.setTimeout( ($ window).trigger('resize') , 1000)
          #window.setTimeout( ($ '#control_hide_button').trigger('click') , 5000)
          #($ '#controldiv').css('width', divWidth-1)
          #globals.curVis.start()
          #($ '#controldiv').css('width', "#{divWidth}px")
          #($ window).trigger('resize')
          #($ '#control_hide_button').click().delay(500)
          #($ window).trigger('resize')
        else if document.mozCancelFullScreen
          document.mozCancelFullScreen()  
        else if (document.cancelFullScreen)
          document.cancelFullScreen()
        #($ document).trigger('resize')
        

     ($ document).on('keyup', (e) ->
         #if ($ '#fullscreen-viz').attr('title') == 'Maximize'
           #($ '#fullscreen-viz').attr('title', 'Minimize')
         #else if ($ '#fullscreen-viz').attr('title') == 'Minimize'
           #($ '#fullscreen-viz').attr('title', 'Maximize')  
         
     )
    
    
    
    
    
    
    #($ '#fullscreen-viz').click (e) ->
      #console.log('Very Click')
      #($ document).trigger("fullscreen")
    ###
    ($ document).on("fullscreen", (e) ->
      e.preventDefault()
      console.log('Event handler called')
      if ($ '#fullscreen-viz').attr('title') == 'Maximize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')
      else if ($ '#fullscreen-viz').attr('title') == 'Minimize'
        ($ '#fullscreen-viz').attr('title', 'Maximize')  
      icon = ($ '#fullscreen-viz').find('i')
      if (globals.fullscreen? and globals.fullscreen)
        window.globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        if document.webkitExitFullscreen
          document.webkitExitFullscreen()
        else if document.mozCancelFullScreen
          document.mozCancelFullScreen()  
        else if (document.cancelFullScreen)
          document.cancelFullScreen()
        ($ document).trigger('resize')
          
      else
        window.globals.fullscreen = true
        
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
    )
    ###
    
    #($ document).on("keyup", (e) ->
      #console.log('Very Key, much press!')
      #console.log(e.keyCode)
        #window.globals.fullscreen = false
        #if ($ '#fullscreen-viz').attr('title') == 'Maximize'
          #($ '#fullscreen-viz').attr('title', 'Minimize')
        #if ($ '#fullscreen-viz').attr('title') == 'Minimize'
          #($ '#fullscreen-viz').attr('title', 'Minimize')  
        #($ '#fullscreen-viz').trigger('click')
    #)