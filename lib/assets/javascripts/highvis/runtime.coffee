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
  if namespace.controller is "visualizations" and namespace.action in ["displayVis", "embedVis", "show"]

    window.globals ?= {}
    globals.curVis = null

    globals.CONTROL_SIZE = 210
    globals.VIS_MARGIN_WIDTH = 20
    globals.VIS_MARGIN_HEIGHT = 70

    ###
    CoffeeScript version of runtime.
    ###

    ### Fix height ###
    if globals.options? and globals.options.isEmbed?
      ($ "#viscontainer").height
    else
      h = (Number ($ "div.mainContent").css("padding-top").replace("px", ""))
      h += ($ ".navbar").height()
      h += ($ "#title_row").outerHeight(true)
      h += globals.VIS_MARGIN_HEIGHT

      ($ "#viscontainer").height(($ window).height() - h)

    ### hide all vis canvases to start ###
    ($ can).hide() for can in ['#map_canvas', '#timeline_canvas', '#scatter_canvas',
      '#bar_canvas', '#histogram_canvas', '#pie_canvas', '#table_canvas',
      '#summary_canvas','#viscanvas','#photos_canvas']

    ### Load saved data if there ###
    if data.savedGlobals?
      hydrate = new Hydrate()
      globals.extendObject globals, (hydrate.parse data.savedGlobals)
      delete data.savedGlobals

    ### Generate tabs ###
    for vis of data.allVis #when vis isnt 'Summary'
      dark = "#{data.allVis[vis]}_dark"
      light = "#{data.allVis[vis]}_light"
      if data.allVis[vis] in data.relVis
        ($ '#visTabList').append """<li class='vis_tab'>
          <a href='##{data.allVis[vis].toLowerCase()}_canvas'>
            <span class='hidden-sm hidden-xs'>#{data.allVis[vis]}</span>
            <img class='visible-xs visible-sm' height='32px' width='32'
              src='#{window.icons[dark]}' data-disable-src='/assets/vis_#{window.icons[light]}' >
          </a>
          </li>"""
      else
        ($ '#visTabList').append """<li class='vis_tab' >
          <a href='##{data.allVis[vis].toLowerCase()}_canvas'>
            <span class='hidden-sm hidden-xs' style='text-decoration:line-through'>
              #{data.allVis[vis]}</span>
            <img class='visible-xs visible-sm' height='32px' width='32'
              src='#{window.icons[light]}' data-enable-src='#{window.icons[dark]}' />
          </a></li>"""

    ### Jquery up the tabs ###
    ($ '#viscontainer').tabs()
    ($ '#tabcontainer').tabs()

    ### Pick vis ###
    if not (data.defaultVis in data.relVis)
      globals.curVis = (eval 'globals.' + data.relVis[0].toLowerCase())
      ($ '#viscontainer').tabs('option', 'active', data.allVis.indexOf(data.relVis[0]))
    else
      globals.curVis = (eval 'globals.' + data.defaultVis.toLowerCase())
      ($ '#viscontainer').tabs('option', 'active', data.allVis.indexOf(data.defaultVis))

    ### Change vis click handler ###
    ($ '#visTabList a').click ->
      oldVis = globals.curVis

      href = ($ this).attr 'href'

      start = href.indexOf('#')
      end = href.indexOf('_canvas')
      start = start + 1

      link = href.substr(start, end - start)

      globals.curVis = (eval 'globals.' + link)

      if oldVis is globals.curVis
        return

      oldVis.end() if oldVis?
      globals.curVis.start()

    # Set initial div sizes
    containerSize = ($ '#viscontainer').width()
    hiderSize     = ($ '#controlhider').outerWidth()
    controlSize =  if globals.options? and globals.options.startCollapsed?
      $("#control_hide_button").html('<')
      0
    else
      $("#control_hide_button").html('>')
      globals.CONTROL_SIZE

    visWidth = containerSize - (hiderSize + controlSize + 10)
    visHeight = ($ '#viscontainer').height() - ($ '#visTabList').outerHeight()

    if globals.options? and globals.options.presentation?
      ($ '.vis_canvas').css width:"100%"
      ($ '.vis_canvas').css height:"100%"
    else
      ($ '.vis_canvas').width  visWidth
      ($ '.vis_canvas').height visHeight

    ($ '#controldiv').width 0
    ($ '#controldiv').height visHeight

    #($ '.vis_canvas').css('padding', 0)
    #($ '.vis_canvas').css('margin', 0)


    # Start up vis
    globals.curVis.start()

    # Toggle control panel
    resizeVis = (toggleControls = true, aniLength = 600) ->

      if (globals.fullscreen? and globals.fullscreen)
        ($ "#viscontainer").height(($ window).height())
      else
        ($ "#viscontainer").height(($ window).height() - h)

      containerSize = ($ '#viscontainer').width()
      hiderSize     = ($ '#controlhider').outerWidth()
      controlSize   = ($ '#controldiv').width()
      controlVisibility = ($ '#controldiv').css 'opacity'

      if toggleControls
        controlSize = if ($ '#controldiv').width() <= 0
          globals.CONTROL_SIZE
        else
          0
        controlVisibility = if ($ '#controldiv').width() <= 0
          1.0
        else
          0.0

      newWidth = containerSize - (hiderSize + controlSize + 10)
      newHeight = ($ '#viscontainer').height() - ($ '#visTabList').outerHeight()

      ($ '#controldiv').height newHeight
      ($ '#controldiv').animate {width: controlSize, opacity: controlVisibility}, aniLength, 'linear'

      ($ '.vis_canvas').height newHeight
      ($ '.vis_canvas').animate {width: newWidth}, aniLength, 'linear'

      globals.curVis.resize newWidth, newHeight, aniLength

    # Set initial size if not in presentation mode
    if globals.options? and globals.options.presentation?
      1
    else
      setTimeout resizeVis, 0

    # Resize vis on page resize
    ($ window).resize () ->
      resizeVis(false, 0)

    ($ '#control_hide_button').click ->

      if ($ '#controldiv').width() is 0
        $("##{@id}").html('>')
      else
        $("##{@id}").html('<')
      resizeVis()



