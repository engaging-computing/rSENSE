###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']
    window.globals ?= {}
    globals.configs ?= {}
    globals.options ?= {}
    globals.configs.toolsOpen ?= false

    globals.curVis = null
    globals.VIS_MARGIN_WIDTH = 20
    globals.VIS_MARGIN_HEIGHT = 70

    ###
    CoffeeScript version of runtime.
    ###

    ### hide all vis canvases to start ###
    $(can).hide() for can in ['#map_canvas', '#timeline_canvas',
      '#scatter_canvas', '#bar_canvas', '#histogram_canvas', '#pie_canvas',
      '#table_canvas', '#summary_canvas','#viscanvas','#photos_canvas']

    # Restore saved globals
    if data.savedGlobals?
      savedGlobals = JSON.parse(data.savedGlobals)
      savedConfigs = savedGlobals['globals']
      $.extend(globals.configs, savedConfigs)

      # Restore vis specific configs
      for visName in data.allVis
        vis  = eval "globals.#{visName.toLowerCase()}"
        if vis? and savedGlobals[visName]?
          $.extend(vis.configs, savedGlobals[visName])

      delete data.savedGlobals

    ### Set Defaults ###
    # Set defaults for grouping
    globals.configs.groupById ?= data.DATASET_NAME_FIELD
    data.setGroupIndex(globals.configs.groupById)
    data.groupSelection ?= for vals, keys in data.groups
      Number keys

    # Set default for logY
    globals.configs.logY ?= 0

    # Set default field selection (we use [..] syntax to indicate array)
    if data.normalFields.length > 1
      globals.configs.fieldSelection ?= data.normalFields[1..1]
    else
      globals.configs.fieldSelection ?= data.normalFields[0..0]

    ### Generate tabs ###
    for vis of data.allVis
      dark = "#{data.allVis[vis]}_dark"
      light = "#{data.allVis[vis]}_light"
      if data.allVis[vis] in data.relVis
        $('#vistablist').append """
          <li role='presentation'>
            <a href='##{data.allVis[vis].toLowerCase()}_canvas' role='tab'
              aria-controls='#{data.allVis[vis].toLowerCase()}_canvas'
              data-toggle='tab'>
              <span class='hidden-sm hidden-xs'>#{data.allVis[vis]}</span>
              <span class='visible-sm visible-xs'>
                <img height='32px' width='32px'
                  src='#{window.icons[dark]}'
                  data-disable-src='/assets/vis_#{window.icons[light]}'/>
              </span>
            </a>
          </li>
          """
      else
        $('#vistablist').append """
          <li role='presentation'>
            <a href='##{data.allVis[vis].toLowerCase()}_canvas' role='tab'
              aria-controls='#{data.allVis[vis].toLowerCase()}_canvas'
              data-toggle='tab'>
              <span class='hidden-sm hidden-xs'
                style='text-decoration:line-through'>
                #{data.allVis[vis]}
              </span>
              <span class='visible-sm visible-xs'>
                <img height='32px' width='32'
                  src='#{window.icons[light]}'
                  data-enable-src='#{window.icons[dark]}'/>
              </span>
            </a>
          </li>
          """

    ### Pick vis ###
    if not (data.defaultVis in data.relVis)
      globals.configs.curVis = 'globals.' + data.relVis[0].toLowerCase()
    else
      globals.configs.curVis = 'globals.' + data.defaultVis.toLowerCase()

    # Pointer to the actual vis
    globals.curVis = eval(globals.configs.curVis)

    ### Change vis click handler ###
    $('#vistablist a').click ->
      oldVis = globals.curVis

      href = $(this).attr 'href'

      start = href.indexOf('#')
      end = href.indexOf('_canvas')
      start = start + 1

      link = href.substr(start, end - start)

      globals.configs.curVis = 'globals.' + link
      globals.curVis = eval(globals.configs.curVis)

      if oldVis is globals.curVis
        return

      oldVis.end() if oldVis?
      globals.curVis.start()
      resizeVis(false, 0, true)

    # Start up vis
    globals.curVis.start()

    # Toggle control panel
    resizeVis = (toggleControls = true, aniLength = 600, init = false) ->
      newHeight = $(window).height()
      unless globals.options? and globals.options.isEmbed?
        newHeight -= $(".navbar").height()

      $("#viswrapper").height(newHeight)

      visWrapperSize = $('#viswrapper').innerWidth()
      visWrapperHeight = $('#viswrapper').outerHeight()
      visTitleBarHeight = $('#vistitlebar').outerHeight() + $('#vistablist').outerHeight()
      hiderSize     = $('#controlhider').outerWidth()
      controlSize   = $('#controldiv').outerWidth()
      controlOpac = $('#controldiv').css 'opacity'

      controlSize = visWrapperSize * .2 - hiderSize
      controlOpac = 1.0
      $("#control_hide_button").html('<')

      $("#viscontainer").height(visWrapperHeight - visTitleBarHeight)

      if toggleControls and ($ '#controlcontainer').width() > hiderSize or
      (init and globals.options.startCollapsed?) or !globals.configs.toolsOpen
        controlSize = 0
        controlOpac = 0.0
        $("#control_hide_button").html('>')

      contrContSize = hiderSize + controlSize

      newWidth = visWrapperSize - contrContSize
      newHeight = $('#viscontainer').height() - $('#vistablist').outerHeight()

      $('#controlcontainer').height $('#viswrapper').height()
      $('#controlcontainer').animate {width: contrContSize}, aniLength, 'linear'

      # Animate the collapsing controls and the expanding vis
      $('#controldiv').animate {width: controlSize, opacity: controlOpac},
        aniLength, 'linear'
      $('#viscontainer').animate {width: newWidth}, aniLength, 'linear'

      globals.curVis.resize(newWidth, newHeight, aniLength)

    # Resize vis on page resize
    $(window).resize () ->
      resizeVis(false, 0)

    $('#control_hide_button').click ->
      globals.configs.toolsOpen = !globals.configs.toolsOpen
      resizeVis()

    # Initialize Tabs
    $('#vistablist a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

      $('.control_header').click (e) ->
        $(@).siblings('.control_outer').slideToggle()

    # Initialize View
    resizeVis(false, 0, true)

    # Deal with full screen
    $('#fullscreen-vis').click (e) ->
      fullscreenEnabled = document.fullscreenEnabled or
        document.mozFullScreenEnabled ordocument.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement or
        document.mozFullScreenElement or document.webkitFullscreenElement
      icon = $('#fullscreen-vis').find('i')
      if !fullscreenElement
        globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = $('#viscontainer')[0]
        browserFullscreenMethod = fullscreenVis.webkitRequestFullScreen or
          fullscreenVis.mozRequestFullScreen or
          fullscreenVis.requestFullScreen or
          fullscreenVis.msRequestFullscreen
        browserFullscreenMethod.call(fullscreenVis)
      else
        globals.fullscreen = false
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
      if $('#fullscreen-vis').attr('title') == 'Maximize'
        $('#fullscreen-vis').attr('title', 'Minimize')
      else if $('#fullscreen-vis').attr('title') == 'Minimize'
        $('#fullscreen-vis').attr('title', 'Maximize')
        window.globals.fullscreen = false

      $(window).trigger('resize')
