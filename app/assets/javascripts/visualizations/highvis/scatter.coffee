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
  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]

    class window.Scatter extends BaseHighVis
      ###
      Initialize constants for scatter display mode.
      ###
      constructor: (@canvas) ->
        super(@canvas)

        @SYMBOLS_LINES_MODE = 3
        @LINES_MODE = 2
        @SYMBOLS_MODE = 1

        @MAX_SERIES_SIZE = 600
        @INITIAL_GRID_SIZE = 150

        @xGridSize = @yGridSize = @INITIAL_GRID_SIZE

        # Used for data reduction triggering
        @updateOnZoom = true

        @configs.mode ?= @SYMBOLS_MODE
        @configs.xAxis ?= data.normalFields[0]
        # TODO write a migration to nuke @configs.yAxis
        @configs.advancedTooltips ?= 0

        # Do the cool existential operator thing
        @configs.savedRegressions ?= []

        @configs.xBounds ?=
          dataMax: undefined
          dataMin: undefined
          max: undefined
          min: undefined
          userMax: undefined
          userMin: undefined

        @configs.yBounds ?=
          dataMax: undefined
          dataMin: undefined
          max: undefined
          min: undefined
          userMax: undefined
          userMin: undefined

        @configs.fullDetail ?= 0

      start: ->
        super()

      storeXBounds: (bounds) ->
        @configs.xBounds = bounds

      storeYBounds: (bounds) ->
        @configs.yBounds = bounds

      ###
      Build up the chart options specific to scatter chart
      The only complex thing here is the html-formatted tooltip.
      ###
      buildOptions: ->
        super()

        self = this

        $.extend true, @chartOptions,
          chart:
            type: if @configs.mode is @LINES_MODE then "line" else "scatter"
            zoomType: "xy"
            resetZoomButton:
              theme:
                display: "none"
          plotOptions:
            scatter:
              marker:
                states:
                  hover:
                    lineColor:'#000'
              point:
                events:
                  mouseOver: () ->
                    # Push elements to bottom to draw over others in series
                    ele = $(@.graphic.element)
                    root = ele.parent()
                    root.append ele

          group_by = ''
          $('#groupSelector').find('option').each (i,j) ->
            if $(j).is(':selected')
              groupBy = $(j).text()
          title:
            text: ""
          tooltip:
            formatter: ->
              if @series.name.regression?
                str  = @series.name.regression.tooltip
              else
                if self.configs.advancedTooltips
                  str  = "<div style='width:100%;text-align:center;color:#{@series.color};'> "
                  str += "#{@series.name.group}</div><br>"
                  str += "<table>"
                  str += "<tr><td>Group by: </td>" + "\t" + "<td>#{groupBy} </td> </tr>"

                  for field, fieldIndex in data.fields when @point.datapoint[fieldIndex] isnt null
                    dat = if (Number field.typeID) is data.types.TIME
                      (globals.dateFormatter @point.datapoint[fieldIndex])
                    else
                      @point.datapoint[fieldIndex]

                    str += "<tr><td>#{field.fieldName}</td>"
                    str += "<td><strong>#{dat}</strong></td></tr>"

                  str += "</table>"
                else
                  str  = "<div style='width:100%;text-align:center;color:#{@series.color};'> "
                  str += "#{@series.name.group}</div><br>"
                  str += "<table>"
                  str += "<tr><td>#{@series.xAxis.options.title.text}:</td><td><strong>#{@x}"
                  str += "</strong></td></tr>"
                  index = data.fields.map((y) -> y.fieldName).indexOf(@series.name.field)
                  str += "<tr><td>#{@series.name.field}:</td><td><strong>#{@y} \
                  #{fieldUnit(data.fields[index], false)}</strong></td></tr>"
                  str += "</table>"
            useHTML: true
            hideDelay: 0

          xAxis: [{
            type: 'linear'
            gridLineWidth: 1
            minorTickInterval: 'auto'
            }]
          yAxis:
            type: if globals.configs.logY is 1 then 'logarithmic' else 'linear'
            events:
              afterSetExtremes: (e) =>
                @storeXBounds @chart.xAxis[0].getExtremes()
                @storeYBounds @chart.yAxis[0].getExtremes()

                ###
                If we actually zoomed, we want to update so the data reduction
                can trigger. Otherwise this zoom was triggered by an update, so
                don't recurse!
                ###
                if @updateOnZoom then @delayedUpdate()
                else @updateOnZoom = true

      ###
      Build the dummy series for the legend.
      ###
      buildLegendSeries: ->
        count = -1
        for f, i in data.fields when i in data.normalFields
          count += 1
          options =
            legendIndex: i
            data: []
            color: '#000'
            showInLegend: i in globals.configs.fieldSelection
            name: f.fieldName

          switch
            when @configs.mode is @SYMBOLS_LINES_MODE
              options.marker =
                symbol: globals.symbols[count % globals.symbols.length]
              options.lineWidth = 2

            when @configs.mode is @SYMBOLS_MODE
              options.marker =
                symbol: globals.symbols[count % globals.symbols.length]
              options.lineWidth = 0

            when @configs.mode is @LINES_MODE
              options.marker =
                symbol: 'blank'
              options.dashStyle = globals.dashes[count % globals.dashes.length]
              options.lineWidth = 2

          options

      ###
      Call control drawing methods in order of apperance
      ###
      drawControls: ->
        super()
        @drawGroupControls(data.textFields)
        @drawXAxisControls()
        @drawYAxisControls('Y Axis', globals.configs.fieldSelection,
          data.normalFields.slice(1), false)
        @drawToolControls()
        @drawRegressionControls()
        @drawSaveControls()

      ###
      Update the chart by removing all current series and recreating them
      ###
      update: () ->
        # Remove all series and draw legend
        super()
        title =
          text: fieldTitle data.fields[@configs.xAxis]
        @chart.xAxis[0].setTitle title, false

        # Compute max bounds if there is no user zoom
        if not @isZoomLocked()

          @configs.yBounds.min = @configs.xBounds.min =  Number.MAX_VALUE
          @configs.yBounds.max = @configs.xBounds.max = -Number.MAX_VALUE

          for fieldIndex, symbolIndex in data.normalFields when fieldIndex in globals.configs.fieldSelection
            for group, groupIndex in data.groups when groupIndex in data.groupSelection
              @configs.yBounds.min = Math.min @configs.yBounds.min, (data.getMin fieldIndex, groupIndex)
              @configs.yBounds.max = Math.max @configs.yBounds.max, (data.getMax fieldIndex, groupIndex)

              @configs.xBounds.min = Math.min @configs.xBounds.min, (data.getMin @configs.xAxis, groupIndex)
              @configs.xBounds.max = Math.max @configs.xBounds.max, (data.getMax @configs.xAxis, groupIndex)

              if (@timeMode isnt undefined) and (@timeMode is @GEO_TIME_MODE)
                @configs.xBounds.min = (new Date(@configs.xBounds.min)).getUTCFullYear()
                @configs.xBounds.max = (new Date(@configs.xBounds.max)).getUTCFullYear()

        # Calculate grid spacing for data reduction
        width = $('#' + @canvas).innerWidth()
        height = $('#' + @canvas).innerHeight()

        @xGridSize = @yGridSize = @INITIAL_GRID_SIZE

        if width > height
          @yGridSize = Math.round (height / width * @INITIAL_GRID_SIZE)
        else
          @xGridSize = Math.round (width / height * @INITIAL_GRID_SIZE)

        # Draw series
        for fieldIndex, symbolIndex in data.normalFields when fieldIndex in globals.configs.fieldSelection
          for group, groupIndex in data.groups when groupIndex in data.groupSelection
            dat = if not @configs.fullDetail
              sel = data.xySelector(@configs.xAxis, fieldIndex, groupIndex)
              globals.dataReduce sel, @configs.xBounds, @configs.yBounds, @xGridSize, @yGridSize, @MAX_SERIES_SIZE
            else
              data.xySelector(@configs.xAxis, fieldIndex, groupIndex)

            if dat.length < 2 and @configs.mode is @LINES_MODE
              @configs.mode = @SYMBOLS_LINES_MODE
              query = "input[name='mode'][value='#{@configs.mode}']"
              $(query).prop('checked', true);
              quickFlash('Mode has been changed to symbols and lines because
                there were too few points to generate a line', 'warning')

            options =
              data: dat
              showInLegend: false
              color: globals.getColor(groupIndex)
              name:
                group: data.groups[groupIndex]
                field: data.fields[fieldIndex].fieldName
            switch
              when @configs.mode is @SYMBOLS_LINES_MODE
                options.marker =
                  symbol: globals.symbols[symbolIndex % globals.symbols.length]
                options.lineWidth = 2

              when @configs.mode is @SYMBOLS_MODE
                options.marker =
                  symbol: globals.symbols[symbolIndex % globals.symbols.length]
                options.lineWidth = 0

              when @configs.mode is @LINES_MODE
                options.marker =
                  symbol: 'blank'
                options.lineWidth = 2
                options.dashStyle = globals.dashes[symbolIndex % globals.dashes.length]

            @chart.addSeries options, false

        if @isZoomLocked()
          @updateOnZoom = false
          @setExtremes()
          $('#zoom-reset-btn').removeClass("disabled")
        else
          @resetExtremes
          $('#zoom-reset-btn').addClass("disabled")

        @chart.redraw()

        @storeXBounds @chart.xAxis[0].getExtremes()
        @storeYBounds @chart.yAxis[0].getExtremes()

        # Disable/enable all of the saved regressions as necessary
        for regression in @configs.savedRegressions
          # Filter out the ones that should be enabled.
          # - X indices must match.
          # - Compare the arrays without comparing them.
          # - Y axis must be present.
          if regression.fieldIndices[0] == @configs.xAxis \
          && "#{regression.fieldIndices[2]}" == "#{data.groupSelection}" \
          && globals.configs.fieldSelection.indexOf(regression.fieldIndices[1]) != -1
            # Add the regression to the chart
            @chart.addSeries(regression.series)
            # Enabled the class by removing the disabled class
            $('tr#row_' + regression.series.name.id).removeClass('regression_row_disabled')
          else
            # Prevent duplicate add classes
            if $('tr#row_' + regression.series.name.id).hasClass('regression_row_disabled') is false
              $('tr#row_' + regression.series.name.id).addClass('regression_row_disabled')

        # Display the table header if necessary
        if $('#regression-table-body > tr').length > 0
          $('tr#regression-table-header').show()
        else $('tr#regression-table-header').hide()

      ###
      Draws radio buttons for changing symbol/line mode.
      ###
      drawToolControls: (elapsedTime = true) ->
        # Configure the tool controls
        ictx = {}
        ictx.axes = ["Both", "X", "Y"]
        ictx.logSafe = data.logSafe
        ictx.elapsedTime = elapsedTime
        ictx.modes = [
          { mode: @SYMBOLS_LINES_MODE, text: "Symbols and Lines" }
          { mode: @LINES_MODE,         text: "Lines Only" }
          { mode: @SYMBOLS_MODE,       text: "Symbols Only" }
        ]

        # Draw the Tool controls
        octx = {}
        octx.id = 'scatter-ctrls'
        octx.title = 'Tools'
        octx.body = HandlebarsTemplates[hbCtrl('scatter')](ictx);
        tools = HandlebarsTemplates[hbCtrl('body')](octx);
        $('#vis-ctrls').append tools

        # Check off the right boxes
        if @configs.advancedTooltips
          $('#ckbx-tooltips').prop('checked', true)
        if @configs.fullDetail then $('#ckbx-fulldetail').prop('checked', true)
        if globals.configs.logY then $('#ckbx-log-y').prop('checked', true)
        $("input[name='mode'][value='#{@configs.mode}']").prop('checked', true)

        # Set initial state of zoom reset
        if not @isZoomLocked() then $('#zoom-reset-btn').addClass("disabled")
        else $('#zoom-reset-btn').addClass("enabled")

        $('#zoom-reset-btn').click (e) =>
          @resetExtremes($('#zoom-axis-list').val())

        $('#zoom-out-btn').click (e) =>
          @zoomOutExtremes($('#zoom-axis-list').val())

        $('input[name="mode"]').click (e) =>
          @configs.mode = Number e.target.value
          @start()

        $('#ckbx-tooltips').click (e) =>
          @configs.advancedTooltips = (@configs.advancedTooltips + 1) % 2
          @start()
          true

        $('#ckbx-fulldetail').click (e) =>
          @configs.fullDetail = (@configs.fullDetail + 1) % 2
          @delayedUpdate()
          true

        $('#ckbx-log-y').click (e) =>
          globals.configs.logY = (globals.configs.logY + 1) % 2
          @start()

        $('#elasped-time-btn').click (e) ->
          globals.generateElapsedTimeDialog()

        # Initialize and track the status of this control panel
        globals.configs.toolsOpen ?= false
        initCtrlPanel('scatter-ctrls', 'toolsOpen')

      ###
      A wrapper for making x-axis controls
      ###
      drawXAxisControls: (iniRadio = @configs.xAxis,
        allFields = data.normalFields) ->
        handler = (selection, selFields) =>
          @configs.xAxis = selection
          @resetExtremes()

        @drawAxisControls('x-axis', 'X Axis', null, allFields, true,
          iniRadio, handler)

        # Initialize and track the status of this control panel
        globals.configs.xAxisOpen ?= false
        initCtrlPanel('x-axis-ctrls', 'xAxisOpen')

      ###
      Checks if the user has requested a specific zoom
      ###
      isZoomLocked: ->
        not (undefined in [@configs.xBounds.userMin, @configs.xBounds.userMax])

      resetExtremes: (whichAxis = 'Both') =>
        if @chart isnt undefined
          if whichAxis in ['Both', 'X']
            @configs.xBounds.userMin = undefined
            @configs.xBounds.userMax = undefined
            @chart.xAxis[0].setExtremes()
          if whichAxis in ['Both', 'Y']
            @configs.yBounds.userMin = undefined
            @configs.yBounds.userMax = undefined
            @chart.yAxis[0].setExtremes()

      setExtremes: ->
        if @chart?
          if(@configs.xBounds.min? and @configs.yBounds.min?)
            @chart.xAxis[0].setExtremes(@configs.xBounds.min,
              @configs.xBounds.max, true)
            @chart.yAxis[0].setExtremes(@configs.yBounds.min,
              @configs.yBounds.max, true)
          else @resetExtremes()

      zoomOutExtremes: (whichAxis) ->
        xRange = @configs.xBounds.max - @configs.xBounds.min
        yRange = @configs.yBounds.max - @configs.yBounds.min

        if whichAxis in ['Both', 'X']
          @configs.xBounds.max += xRange * 0.1
          @configs.xBounds.min -= xRange * 0.1

        if whichAxis in ['Both', 'Y']
          if globals.configs.logY is 1
            @configs.yBounds.max *= 10.0
            @configs.yBounds.min /= 10.0
          else
            @configs.yBounds.max += yRange * 0.1
            @configs.yBounds.min -= yRange * 0.1

        @setExtremes()

      ###
      Saves the zoom level before cleanup
      ###
      serializationCleanup: ->
        if chart?
          @storeXBounds @chart.xAxis[0].getExtremes()
          @storeYBounds @chart.yAxis[0].getExtremes()

        super()

      ###
      Updates x axis for regression.
      ###
      updateXRegression:() ->
        $('#regressionXAxis').text("#{data.fields[@configs.xAxis].fieldName}")

      ###
      Updates y axis for regression.
      ###
      updateYRegression:() ->
        if $('#regressionYAxisSelector')?
          $('#regressionYAxisSelector').empty()
          for fieldIndex in globals.configs.fieldSelection
            $('#regressionYAxisSelector').append($("<option/>", {
              value: fieldIndex,
              text: data.fields[fieldIndex].fieldName
            }))

      ###
      Adds the regression tools to the control bar.
      ###
      drawRegressionControls: () ->
        # Configure the tool controls
        ictx = {}

        # Draw the Tool controls
        octx = {}
        octx.id = 'regression-ctrls'
        octx.title = 'Tools'
        octx.body = HandlebarsTemplates[hbCtrl('regression')](ictx);
        tools = HandlebarsTemplates[hbCtrl('body')](octx);
        $('#vis-ctrls').append tools


      ###
      Clips an array of data to include only bounded points
      ###
      clip: (arr) ->
        # Checks if a point is visible on screen
        clipped = (point, xBounds, yBounds) =>
          # Check x axis
          if point[@configs.xAxis] is null    or
          isNaN(point[@configs.xAxis])        or
          point[@configs.xAxis] < xBounds.min or
          point[@configs.xAxis] > xBounds.max
            return false

          # Check all y axes
          for yAxis in globals.configs.fieldSelection
            if (point[yAxis] is null   or isNaN(point[yAxis]) or
            point[yAxis] < yBounds.min or point[yAxis] > yBounds.max)
              return false

          return true

        # Do the actual clipping
        if @configs.xBounds.min? and @configs.xBounds.max? and
        @configs.yBounds.min?    and @configs.yBounds.max?
          p for p in arr when clipped(p, @configs.xBounds, @configs.yBounds)
        else
          arr

    if "Scatter" in data.relVis
      globals.scatter = new Scatter "scatter-canvas"
    else
      globals.scatter = new DisabledVis "scatter-canvas"
