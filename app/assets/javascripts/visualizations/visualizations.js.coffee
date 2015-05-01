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
    globals.configs.ctrlsOpen ?= true

    globals.curVis = null
    globals.VIS_MARGIN_WIDTH = 20
    globals.VIS_MARGIN_HEIGHT = 70

    ###
    CoffeeScript version of runtime.
    ###
    # Toggle control panel
    resizeVis = (toggleControls = true, aniLength = 600, init = false) ->
      newHeight = $(window).height()
      embed = globals.options? and globals.options.isEmbed?
      presentation = globals.options and globals.options.presentation?

      unless embed then newHeight -= $('.navbar').height()
      $('#vis-wrapper').height(newHeight)

      visWrapperWidth =
        if embed then window.innerWidth or window.outerWidth
        else $('#vis-wrapper').innerWidth()
      visWrapperHeight = $('#vis-wrapper').outerHeight()
      visHeaderHeight = $('#vis-title-bar').outerHeight() +
        $('#vis-tab-list').outerHeight()
      controlOpac = $('#vis-ctrls').css 'opacity'
      controlSize = 320
      controlOpac = 1.0

      if (init and globals.options.startCollapsed?) or
      $('#vis-ctrl-container').is(':hidden')
        globals.configs.ctrlsOpen = false

      unless globals.configs.ctrlsOpen
        controlSize = 0
        controlOpac = 0.0

      $('#ctrls-menu-btn').toggleClass('down', globals.configs.ctrlsOpen)

      # Adjust heights
      $('#vis-container').height(visWrapperHeight)
      $('#vis-ctrl-container').height(visWrapperHeight)
      newHeight = visWrapperHeight
      unless presentation then newHeight -= visHeaderHeight
      $('#vis-container > .tab-content').height(newHeight)

      # Animate the collapsing controls and the expanding vis
      $('#vis-ctrl-container').animate({width: controlSize}, aniLength,
        'linear')
      $('#vis-ctrls').animate({width: controlSize, opacity: controlOpac},
        aniLength, 'linear')

      # New widths should take into account visibility of tools
      nWidth =
        if globals.configs.ctrlsOpen then visWrapperWidth - controlSize
        else visWrapperWidth
      $('#vis-container').animate({width: nWidth}, aniLength, 'linear')
      globals.curVis.resize(nWidth, newHeight, aniLength)

    # Resize vis on page resize
    $(window).resize () ->
      resizeVis(false, 0)

    ### Hide all vis canvases to start ###
    $(can).hide() for can in ['#map-canvas', '#timeline-canvas',
      '#scatter-canvas', '#bar-canvas', '#histogram-canvas', '#pie-canvas',
      '#table-canvas', '#summary-canvas','#viscanvas','#photos-canvas']

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
      Number(keys)

    # Set default for logY
    globals.configs.logY ?= 0

    # Set default field selection (we use [..] syntax to indicate array)
    if data.normalFields.length > 1
      globals.configs.fieldSelection ?= data.normalFields[1..1]
    else
      globals.configs.fieldSelection ?= data.normalFields[0..0]

    ### Generate tabs ###
    for vis of data.allVis
      ctx = {}
      dark = "#{data.allVis[vis]}_dark"
      light = "#{data.allVis[vis]}_light"

      enabled = data.allVis[vis] in data.relVis
      lower = data.allVis[vis].toLowerCase()
      ctx.id = 'vis-tab-' + lower
      ctx.name = data.allVis[vis]
      ctx.canvas = lower + '-canvas'
      ctx.icon = if enabled then window.icons[dark] else window.icons[light]

      tab = HandlebarsTemplates['visualizations/vis-tab'](ctx)
      $('#vis-tab-list').append(tab)

      unless enabled
        $("#vis-tab-#{ctx.name.toLowerCase()}").addClass('strikethrough')

    ### Launch a default vis ###
    cvis = defaultVis
    globals.configs.curVis = 'globals.' + cvis
    ccanvas = cvis + '-canvas'

    # Pointer to the actual vis
    globals.curVis = eval(globals.configs.curVis)

    # Start up vis
    globals.curVis.start()

    # Highlight the starting tab
    $("#vis-tab-list a[href='##{ccanvas}']").tab('show')

    # Initialize View
    resizeVis(false, 0, true)

    ### Change vis click handler ###
    $('#vis-tab-list a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

      oldVis = globals.curVis

      href = $(this).attr('href')

      start = href.indexOf('#')
      end = href.indexOf('-canvas')
      start = start + 1

      link = href.substr(start, end - start)

      globals.configs.curVis = 'globals.' + link
      globals.curVis = eval(globals.configs.curVis)

      if oldVis is globals.curVis
        return

      oldVis.end() if oldVis?
      globals.curVis.start()
      resizeVis(false, 0, true)

    $('#ctrls-menu-btn').click ->
      globals.configs.ctrlsOpen = !globals.configs.ctrlsOpen
      resizeVis()

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
        fullscreenVis = $('#vis-container')[0]
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

    events = 'webkitfullscreenchange mozfullscreenchange fullscreenchange'
    $(document).on events, ->
      if $('#fullscreen-vis').attr('title') == 'Maximize'
        $('#fullscreen-vis').attr('title', 'Minimize')
      else if $('#fullscreen-vis').attr('title') == 'Minimize'
        $('#fullscreen-vis').attr('title', 'Maximize')
        window.globals.fullscreen = false

      $(window).trigger('resize')

    $.fn.carousel.defaults =
      interval: false,
      pause: 'hover'
