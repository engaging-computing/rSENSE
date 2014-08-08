$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
    ###
    Fullscreen Visualizations
    ###
    hidden = false
    originalWidth = 210
    ($ '#fullscreen-viz').click (e) ->
      fullscreenEnabled = document.fullscreenEnabled || document.mozFullScreenEnabled ||
      document.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement || document.mozFullScreenElement ||
      document.webkitFullscreenElement
      icon = ($ '#fullscreen-viz').find('i')
      if !fullscreenElement
        window.globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = ($ '#viscontainer')[0]
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
          
    ($ document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange', ->
      if !hidden
        ($ '#controldiv').width(originalWidth)
      #Deal with Safari and Firefox resizing peculiarities
      if ((navigator.userAgent.search("Safari") >= 0 && navigator.userAgent.search("Chrome") < 0) or
         navigator.userAgent.indexOf('Firefox') > -1)
        ($ window).trigger('resize')
      if ($ '#fullscreen-viz').attr('title') == 'Maximize'
        ($ '#fullscreen-viz').attr('title', 'Minimize')
      else if ($ '#fullscreen-viz').attr('title') == 'Minimize'
        ($ '#fullscreen-viz').attr('title', 'Maximize')
    )

    ($ '#control_hide_button').on('click', () ->
      hidden = !hidden
    )

    ###
    Add Select All Options for Y Axis to Timeline, Bar Chart, and Scatter Plot
    ###
    addSelectAllY = (id) ->
      ($ "##{id}").prepend(
        "<div class='inner_control_div'>
          <div class='checkbox all-y-fields'>
            <label class='all-y'>
              <input id='select-all-y' type='checkbox'> #Select All </input>
            </label>
          </div>
        </div>"
      )
      
      ($ "##{id}").height(($ "##{id}").height() + ($ '.checkbox:first').height() / 2)
    areAllFieldsSelected = () ->
      if data.normalFields.length == globals.fieldSelection.length
        return true
      else
        return false
    
    bindYAxisEventHandlers = () ->
      ($ '.all-y-fields').on('click', () ->
        window.allYAxes = !window.allYAxes
        if window.allYAxes
          ($ "#yAxisControl").find('.y_axis_input').each (i,j) ->
            if ($ j).prop('checked') == false
              ($ j).trigger('click')
          window.allYaxes = true
        else
          window.allYAxes = false
          ($ "#yAxisControl").find('.y_axis_input').each (i,j) ->
            if ($ j).prop('checked') == true
              ($ j).trigger('click')
      )
      ($ '.y_axis_input').on('click', () ->
        if data.normalFields.length == globals.fieldSelection.length
          window.allYAxes = true
          ($ '#select-all-y').prop('checked', true)
        else
          window.allYAxes = false
          ($ '#select-all-y').prop('checked', false)
      )
    ($ document).ready () ->
      if globals.curVis.canvas == 'timeline_canvas'
        id = ($ '#controldiv').find('.outer_control_div:eq(1)').attr('id')
        window.allYAxes = areAllFieldsSelected()
        addSelectAllY(id)
      else if globals.curVis.canvas == 'scatter_canvas'
        id = ($ '#controldiv').find('.outer_control_div:eq(2)').attr('id')
        addSelectAllY(id)
      else if globals.curVis.canvas == 'bar_canvas'
        id = ($ '#controldiv').find('.outer_control_div:eq(1)').attr('id')
        addSelectAllY(id)
      if window.allYAxes
        ($ '#select-all-y').attr('checked', true)
      bindYAxisEventHandlers()
      window.globals.curVis.update()
      
    ($ '#ui-id-2').on('click', () ->
      window.allYAxes = areAllFieldsSelected()
      addSelectAllY(($ '#controldiv').find('.outer_control_div:eq(1)').attr('id'))
      if window.allYAxes
        ($ '#select-all-y').prop('checked', true)
      bindYAxisEventHandlers()
    )
      
    ($ '#ui-id-3').on('click', () ->
      addSelectAllY(($ '#yAxisControl').find('.outer_control_div:first').attr('id'))
      window.allYAxes = areAllFieldsSelected()
      if window.allYAxes
        ($ '#select-all-y').prop('checked', true)
      bindYAxisEventHandlers()
    )
       
    ($ '#ui-id-4').on('click', () ->
      addSelectAllY(($ '#controldiv').find('.outer_control_div:eq(1)').attr('id'))
      window.allYAxes = areAllFieldsSelected()
      if window.allYAxes
        ($ '#select-all-y').prop('checked', true)
      bindYAxisEventHandlers()
    )
      
