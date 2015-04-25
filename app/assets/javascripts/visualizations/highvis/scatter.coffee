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
        @updateOnZoom = 1

        @configs.mode ?= @SYMBOLS_MODE

        @configs.xAxis ?= data.normalFields[0]
        @configs.yAxis ?= globals.configs.fieldSelection

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
              group_by = $(j).text()
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
                  str += "<tr><td>Group by: </td>" + "\t" + "<td>#{group_by} </td> </tr>"

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
                If we actually zoomed, we want to update so the data reduction can trigger.
                Otherwise this zoom was triggered by an update, so don't recurse!
                ###
                if @updateOnZoom is 1
                  @delayedUpdate()
                else
                  @updateOnZoom = 1

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
        @drawGroupControls()
        @drawXAxisControls()
        @drawYAxisControls()
        @drawToolControls()
        @drawClippingControls()
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

        dp = globals.clipping.getData(true, globals.configs.clippingVises)

        # Compute max bounds if there is no user zoom
        if not @isZoomLocked()

          @configs.yBounds.min = @configs.xBounds.min =  Number.MAX_VALUE
          @configs.yBounds.max = @configs.xBounds.max = -Number.MAX_VALUE

          for fieldIndex, symbolIndex in data.normalFields when fieldIndex in globals.configs.fieldSelection
            for group, groupIndex in data.groups when groupIndex in data.groupSelection
              @configs.yBounds.min = Math.min @configs.yBounds.min, data.getMin(fieldIndex, groupIndex, dp)
              @configs.yBounds.max = Math.max @configs.yBounds.max, data.getMax(fieldIndex, groupIndex, dp)

              @configs.xBounds.min = Math.min @configs.xBounds.min, data.getMin(@configs.xAxis, groupIndex, dp)
              @configs.xBounds.max = Math.max @configs.xBounds.max, data.getMax(@configs.xAxis, groupIndex, dp)

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
            xy = data.xySelector(@configs.xAxis, fieldIndex, groupIndex, dp)
            sel =
              if @configs.fullDetail then xy
              else globals.dataReduce(xy, @configs.xBounds, @configs.yBounds, @xGridSize, @yGridSize, @MAX_SERIES_SIZE)

            options =
              data: sel
              showInLegend: false
              color: globals.configs.colors[groupIndex % globals.configs.colors.length]
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
          @updateOnZoom = 0
          @setExtremes()
          $('#zoomResetButton').removeClass("disabled")
        else
          @resetExtremes
          $('#zoomResetButton').addClass("disabled")

        @chart.redraw()

        @storeXBounds @chart.xAxis[0].getExtremes()
        @storeYBounds @chart.yAxis[0].getExtremes()

        # Disable/enable all of the saved regressions as necessary
        for regression in @configs.savedRegressions
          # Filter out the ones that should be enabled.
          # - X indices must match.
          # - Compare the arrays without comparing them.
          # - Y axis must be present.
          if regression.xAxis is @configs.xAxis \
          and "#{regression.groups}" is "#{data.groupSelection}" \
          and globals.configs.fieldSelection.indexOf(regression.yAxis) != -1
            # Create the hypothesis function
            func = if regression.type is globals.REGRESSION.SYMBOLIC
              new Function("x", regression.func)
            else
              new Function("x, P", regression.func)
            # Calculate the series
            series = if regression.type isnt globals.REGRESSION.SYMBOLIC
              # Convert parameters from strings to numbers
              params = for i in [0...regression.parameters.length]
                parseFloat(regression.parameters[i])
              globals.getRegressionSeries(func, params, \
              Number(regression.r2), regression.type, [@configs.xBounds.min, @configs.xBounds.max], \
              regression.name, regression.dashStyle, regression.id, regression.tooltip, false)[3]
            else
              globals.getRegressionSeries(func, regression.parameters, Number(regression.r2), \
              regression.type, [@configs.xBounds.min, @configs.xBounds.max], regression.name, \
              regression.dashStyle, regression.id, regression.tooltip, false)[3]
            # Add the regression to the chart
            @chart.addSeries(series)
            # Enabled the class by removing the disabled class
            $('tr#row_' + regression.id).removeClass('regression_row_disabled')
          else
            # Prevent duplicate add classes
            if $('tr#row_' + regression.id).hasClass('regression_row_disabled') is false
              $('tr#row_' + regression.id).addClass('regression_row_disabled')

        # Display the table header if necessary
        if $('#regression-table-body > tr').length > 0
          $('tr#regression-table-header').show()
        else $('tr#regression-table-header').hide()

        # Refresh the clipping accordion so it sizes correctly
        @clipDescriptor()
        $('#clipping_controls').accordion('refresh')

      ###
      Draws radio buttons for changing symbol/line mode.
      ###
      drawToolControls: (elaspedTimeButton = true) ->
        controls =  '<div id="toolControl" class="vis_controls">'

        controls += "<h3 class='clean_shrink'><a href='#'>Tools:</a></h3>"
        controls += "<div class='outer_control_div'>"

        controls += "<h4 class='clean_shrink'>Zoom</h4>"
        controls += '<div class="inner_control_div">'

        controls += "<select id='zoomSelector' class='form-control'>"

        axes = ['Both', 'X', 'Y']
        for axis in axes
          controls += "<option value='#{axis}'>#{axis}</option>"
        controls += "</select>"
        controls += "<div class='btn-group btn-group-justified'>"
        controls += "<div class='btn-group'><button id='zoomOutButton' \
          class='zoom_button btn btn-default'>Out</button></div>"
        controls += "<div class='btn-group'><button id='zoomResetButton' \
          class='zoom_button btn btn-default'>Fit</button></div>"
        controls += "</div>"

        controls += "<h4 class='clean_shrink'>Display Mode</h4>"

        for [mode, modeText] in [[@SYMBOLS_LINES_MODE, "Symbols and Lines"],
          [@LINES_MODE,         "Lines Only"],
          [@SYMBOLS_MODE,       "Symbols Only"]]
          controls += '<div class="inner_control_div">'
          controls += "<div class='radio'><label><input class='mode_radio' type='radio' "
          controls += "name='mode_selector' value='#{mode}' #{if @configs.mode is mode then 'checked' else ''}/>"
          controls += modeText + "</label></div></div>"

        controls += "<br>"
        controls += "<h4 class='clean_shrink'>Other</h4>"

        controls += '<div class="inner_control_div">'
        controls += "<div class='checkbox'><label><input class='tooltip_box' type='checkbox' "
        controls += "name='tooltip_selector' #{if @configs.advancedTooltips then 'checked' else ''}/>"
        controls += "Detailed Tooltips</label></div> "
        controls += "</div>"

        controls += '<div class="inner_control_div">'
        controls += "<div class='checkbox'><label><input class='full_detail_box' type='checkbox' "
        controls += "name='full_detail_selector' #{if @configs.fullDetail then 'checked' else ''}/>"
        controls += "Show All Data</label></div>"
        controls += "</div>"

        if data.logSafe is 1
          controls += '<div class="inner_control_div">'
          controls += "<div class='checkbox'><label><input class='logY_box' type='checkbox' "
          controls += "name='log_selector' #{if globals.configs.logY is 1 then 'checked' else ''}/> "
          controls += "Logarithmic Y Axis </label></div>"
          controls += "</div>"

        if elaspedTimeButton
          controls += "<div class='inner_control_div' style='text-align:center'>"
          controls += "<button id='elaspedTimeButton' class='save_button btn btn-default btn-sm'>"
          controls += "Generate Elapsed Time </button>"
          controls += "</div>"

        controls += "</div></div>"

        # Write HTML
        $('#controldiv').append controls

        $('#zoomResetButton').button()
        $('#zoomResetButton').click (e) =>
          @resetExtremes($('#zoomSelector').val())

        # Set initial state of zoom reset
        if not @isZoomLocked()
          $('#zoomResetButton').addClass("disabled")
        else
          $('#zoomResetButton').addClass("enabled")

        $('#zoomOutButton').button()
        $('#zoomOutButton').click (e) =>
          @zoomOutExtremes($('#zoomSelector').val())

        $('.mode_radio').click (e) =>
          @configs.mode = Number e.target.value
          @start()

        $('.tooltip_box').click (e) =>
          @configs.advancedTooltips = (@configs.advancedTooltips + 1) % 2
          @start()
          true

        $('.full_detail_box').click (e) =>
          @configs.fullDetail = (@configs.fullDetail + 1) % 2
          @delayedUpdate()
          true

        $('.logY_box').click (e) =>
          globals.configs.logY = (globals.configs.logY + 1) % 2
          @start()
        $('#groupSelector').change (e) =>
          @start()
        $('#elaspedTimeButton').button()
        $('#elaspedTimeButton').click (e) ->
          globals.generateElapsedTimeDialog()

        # Set up accordion
        globals.configs.toolsOpen ?= 0

        $('#toolControl').accordion
          collapsible:true
          active:globals.configs.toolsOpen

        $('#toolControl > h3').click ->
          globals.configs.toolsOpen = (globals.configs.toolsOpen + 1) % 2

      ###
      Draws x axis selection controls
      This includes a series of radio buttons.
      ###
      drawXAxisControls: (filter = (fieldIndex) -> (fieldIndex in data.normalFields)) ->
        # Don't draw if there's only one possible selection
        possible = for field, fieldIndex in data.fields when filter fieldIndex
          true
        if possible.length <= 1
          return

        controls =  '<div id="xAxisControl" class="vis_controls">'

        controls += "<h3 class='clean_shrink'><a href='#'>X Axis:</a></h3>"
        controls += "<div class='outer_control_div'>"

        # Populate choices (not text)
        for field, fieldIndex in data.fields when filter fieldIndex
          controls += '<div class="inner_control_div">'

          controls += "<div class='radio'><label><input class='xAxis_input' type='radio' name='xaxis' "
          controls += "value='#{fieldIndex}' #{if (Number fieldIndex) == @configs.xAxis then "checked" else ""}>"
          controls += "#{data.fields[fieldIndex].fieldName}</label></div>"
          controls += "</div>"

        controls += '</div></div>'

        # Write HTML
        $('#controldiv').append controls

        # Make xAxis radio handler
        $('.xAxis_input').change (e) =>
          selection = null
          $('.xAxis_input').each () ->
            if @checked
              selection = @value
          @configs.xAxis = Number selection

          @resetExtremes()
          @update()

        # Set up accordion
        globals.configs.xAxisOpen ?= 0

        $('#xAxisControl').accordion
          collapsible:true
          active:globals.configs.xAxisOpen

        $('#xAxisControl > h3').click ->
          globals.configs.xAxisOpen = (globals.configs.xAxisOpen + 1) % 2

      ###
      Save the Y-axis selection for clipping purposes
      ###
      drawYAxisControls: (radio = false) ->
        super(radio)
        @configs.yAxis = globals.configs.fieldSelection

      ###
      Checks if the user has requested a specific zoom
      ###
      isZoomLocked: ->
        not (undefined in [@configs.xBounds.userMin, @configs.xBounds.userMax])

      resetExtremes: (whichAxis) ->
        if @chart isnt undefined
          if whichAxis in ['Both', 'X']
            @chart.xAxis[0].setExtremes()
          if whichAxis in ['Both', 'Y']
            @chart.yAxis[0].setExtremes()

      setExtremes: ->
        if (@chart isnt undefined)
          if(@configs.xBounds.min? and @configs.yBounds.min?)
            @chart.xAxis[0].setExtremes(@configs.xBounds.min,@configs.xBounds.max,true)
            @chart.yAxis[0].setExtremes(@configs.yBounds.min,@configs.yBounds.max,true)
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
      Saves the current zoom level
      ###
      end: ->
        super()

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
        controls = """
          <div id="regressionControl" class="vis_controls">
          <h3 class='clean_shrink'><a href='#'>Analysis Tools:</a></h3>
          <div class='outer_control_div' style='text-align:center'>

          <table><tr>
          <td>X Axis: </td>
          <td id='regressionXAxis'>#{data.fields[@configs.xAxis].fieldName}</td></tr>

          <tr><td>Y Axis: </td>
          <td><select id='regressionYAxisSelector' class='form-control'>
          """

        for fieldIndex in globals.configs.fieldSelection
          controls += "<option value='#{fieldIndex}'>#{data.fields[fieldIndex].fieldName}</option>"

        controls +=
          """
          </select></td></tr>
          <tr><td>Type: </td>
          <td><select id="regressionSelector" class="form-control">
          """

        regressions = ['Linear', 'Quadratic', 'Cubic', 'Exponential', 'Logarithmic', 'Automatic']
        for regressionType in regressions
          controls += "<option value='#{regressions.indexOf(regressionType)}'>#{regressionType}</option>"

        controls +=
          """
          </select></td></tr>
          </table>
          <button id='regressionButton' class='save_button btn btn-default'>Draw Best Fit Line</button>
          <table id='regression-table'>
          <col width='55%' />
          <col width='35%' />
          <col width='10%' />
          <tr id='regression-table-header'><td><strong>f(x)<strong></td><td><strong>Type<strong></td></tr>
          <tbody id='regression-table-body'></tbody></table>
          </div></div>
          """

        # Write HTML
        $('#controldiv').append controls
        $("#regressionControl button").button()

        # Add all the saved regressions correctly
        for regression in @configs.savedRegressions
          # Filter out the ones that should be enabled.
          # - X indices must match.
          # - Compare the arrays without comparing them.
          # - Y axis must be present.
          if regression.xAxis == @configs.xAxis \
          and "#{regression.groups}" is "#{data.groupSelection}" \
          and globals.configs.fieldSelection.indexOf(regression.yAxis) != -1
            # Calculate the hypothesis function
            func = if regression.type is globals.REGRESSION.SYMBOLIC
              new Function("x", regression.func)
            else
              new Function("x, P", regression.func)
            # Calculate the series
            series = if regression.type isnt globals.REGRESSION.SYMBOLIC
              # Convert parameters from strings to numbers
              params = for i in [0...regression.parameters.length]
                parseFloat(regression.parameters[i])
              globals.getRegressionSeries(func, params, \
              Number(regression.r2), regression.type, [@configs.xBounds.min, @configs.xBounds.max], \
              regression.name, regression.dashStyle, regression.id, regression.tooltip, false)[3]
            else
              globals.getRegressionSeries(func, regression.parameters, Number(regression.r2), \
              regression.type, [@configs.xBounds.min, @configs.xBounds.max], regression.name, \
              regression.dashStyle, regression.id, regression.tooltip, false)[3]
            # Add the regression to the chart
            @chart.addSeries(series)
            @addRegressionToTable(regression, true)
          else
            @addRegressionToTable(regression, false)

        # Catches change in y axis
        $('.y_axis_input').click (e) =>
          @updateYRegression()

        # Catches change in x axis
        $('.xAxis_input').change (e) =>
          @updateXRegression()

        $("#regressionButton").click =>

          # Get the current selected y index, the regression type, and the current group indices
          yAxisIndex = Number($('#regressionYAxisSelector').val())
          regressionType = Number($('#regressionSelector').val())

          # Make the title for the tooltip
          xAxisName = data.fields[@configs.xAxis].fieldName
          yAxisName = $('#regressionYAxisSelector option:selected').text()
          name = "<strong>#{yAxisName}</strong> as a "
          funcDesc = if regressionType isnt globals.REGRESSION.SYMBOLIC
            "#{$('#regressionSelector option:selected').text().toLowerCase()} "
          else ''
          name += funcDesc
          name += "function of <strong>#{xAxisName}</strong>"

          #list of (x,y) points to be used in calculating regression
          xyData = data.multiGroupXYSelector(@configs.xAxis, yAxisIndex, data.groupSelection)
          xMax = window.globals.curVis.configs.xBounds.max
          xMin = window.globals.curVis.configs.xBounds.min
          points = ({x: point.x, y: point.y} for point in xyData)
          fn = (pv, cv, index, array) -> (pv and cv)
          # Create a unique identifier for the regression
          regressionId = "regression_#{@configs.xAxis}_#{yAxisIndex}_#{regressionType}_" + \
          data.groupSelection.toString()
          regressionId = regressionId.replace(',', '_') while regressionId.indexOf(',') isnt -1
          return unless (regression.id isnt regressionId for regression in @configs.savedRegressions).reduce(fn, true)
          
          # Get dash index
          dashIndex = data.normalFields.indexOf(yAxisIndex)
          dashStyle = globals.dashes[dashIndex % globals.dashes.length]

          [func, Ps, r2, newRegression, tooltip] = [null, null, null, null, null]
          if regressionType is globals.REGRESSION.SYMBOLIC
            [func, Ps, r2, newRegression, tooltip] = globals.getRegression(
              points,
              regressionType,
              [xMin, xMax],
              name,
              dashStyle,
              regressionId
            )
          else
            try
              [func, Ps, r2, newRegression, tooltip] = globals.getRegression(
                points,
                regressionType,
                [xMin, xMax],
                name,
                dashStyle,
                regressionId
              )
            catch error
              if regressionType is 3
                alert "Unable to calculate an #{regressions[regressionType]} regression for this data."
              else
                alert "Unable to calculate a #{regressions[regressionType]} regression for this data."
              return

          # Add the series
          @chart.addSeries(newRegression)

          # Set func variable to a string that can be used to recreate the desired function
          if typeof(func) is 'function'
            func = switch regressionType
              when globals.REGRESSION.LINEAR
                'return P[0] + (P[1] * x)'
              when globals.REGRESSION.QUADRATIC
                'return P[0] + (P[1] * x) + (P[2] * x * x)'
              when globals.REGRESSION.CUBIC
                'return P[0] + (x * P[1]) + (x * x * P[2]) + (x * x * x * P[3])'
              when globals.REGRESSION.EXPONENTIAL
                'return P[0] + Math.exp(P[1] * x + P[2])'
              when globals.REGRESSION.LOGARITHMIC
                'return P[0] + Math.log(P[1] * x + P[2])'
          else
            func = BinaryTree.codify(func.tree)

          # Prepare to save regression fields
          savedRegression =
            type: regressionType
            xAxis: @configs.xAxis
            yAxis: yAxisIndex
            groups: data.groupSelection
            parameters: Ps
            func: func
            id: regressionId
            r2: r2
            name: name
            dashStyle: dashStyle
            tooltip: tooltip
      
          # Save a regression
          @configs.savedRegressions.push(savedRegression)

          # Actually add the regression to the table
          @addRegressionToTable(savedRegression, true)
          # Draw the regression to the vis
          globals.curVis.update()
        # Set up accordion
        globals.configs.regressionOpen ?= 0

        $('#regressionControl').accordion
          collapsible:true
          active:globals.configs.regressionOpen
          heightStyle:"content"

        $('#regressionControl > h3').click ->
          globals.configs.regressionOpen = (globals.configs.regressionOpen + 1) % 2

      # Adds a regression row to our table, with styling for enabled or disabled
      addRegressionToTable: (savedReg, enabled) ->
        # Remove object from an array
        Array::filterOutValue = (v) -> x for x in @ when x != v

        # Here have a list of regressions
        regressions = ['Linear', 'Quad', 'Cubic', 'Exp', 'Log', 'Auto']

        # Add the entry used the passed regression
        regressionRow =
          """
          <tr id ='row_#{savedReg.id}' class='regression_row'>
          <td class='regression_rowdata truncate'>
          #{data.fields[savedReg.yAxis].fieldName}(#{data.fields[savedReg.xAxis].fieldName})</td>
          <td class='regression_rowdata'>
          #{regressions[savedReg.type]}</td>
          <td id='#{savedReg.id}' class='regression_remove'><i class='fa fa-times-circle'></i></td>
          </tr>
          """

        # Added info relating to this regression
        $('#regression-table-body').append(regressionRow)

        # Add the disabled style if necessary
        if !enabled
          $('tr#row_' + savedReg.id).addClass('regression_row_disabled')

        # Display the table header
        $('tr#regression-table-header').show()

        # Make each row a link to its view
        $('tr#row_' + savedReg.id).click =>
          # Reset the state of when you saved
          @configs.xAxis = savedReg.xAxis
          globals.configs.fieldSelection = [savedReg.yAxis]
          data.groupSelection = savedReg.groups

          $('.xAxis_input').each (i, input) ->
            if Number(input.value) == savedReg.xAxis
              input.checked = true

          @start()

        # Add a make the delete button remove the regression object
        $('td#' + savedReg.id).click =>
          # Remove regression view from the screen.
          $('td#' + savedReg.id).parent().remove()

          # Display the table header if necessary
          if $('#regression-table-body > tr').length > 0
            $('tr#regression-table-header').show()
          else $('tr#regression-table-header').hide()

          # Remove regression from the savedRegressions array.
          id = savedReg.id
          for regression in @configs.savedRegressions
            if (regression.id == id)
              @configs.savedRegressions =
                @configs.savedRegressions.filterOutValue(regression)
              break

          # Remove regression from the chart
          for series, i in @chart.series
            if (series.name.id == id)
              @chart.series[i].remove()
              break

        # Make the hovering highlight the correct regression
        $('tr#row_' + savedReg.id).mouseover =>

          # Remove regression from the chart
          id = savedReg.id
          for series, i in @chart.series
            if (series.name.id is id)
              @chart.series[i].setState('hover')
              @chart.tooltip.refresh(@chart.series[i].points[@chart.series[i].points.length - 1])
              break

        # When the mouse leaves, don't highlight anymore
        $('tr#row_' + savedReg.id).mouseout =>
          # Remove regression from the chart
          id = savedReg.id
          for series, i in @chart.series
            if (series.name.id == id)
              @chart.series[i].setState('')
              @chart.tooltip.hide()
              break

      ###
      Clips an array of data to include only bounded points
      ###
      clip: (arr) ->
        # Verify parameters
        unless @configs.xBounds.min? and @configs.xBounds.max? and
        @configs.yBounds.min? and @configs.yBounds.max?
          return arr

        # Checks if a point is visible on screen
        clipped = (point, xBounds, yBounds) =>

          # Check x axis
          if (point[@configs.xAxis] is null) or
          (isNaN point[@configs.xAxis]) or
          point[@configs.xAxis] < xBounds.min or
          point[@configs.xAxis] > xBounds.max
            return false

          # Check all y axes
          for yAxis in @configs.yAxis
            if ((point[yAxis] isnt null) and (not isNaN point[yAxis]) and
            point[yAxis] >= yBounds.min and point[yAxis] <= yBounds.max)
              return true

          return false

        # Do the actual clipping
        (p for p in arr when clipped(p, @configs.xBounds, @configs.yBounds))

      ###
      Updates a div describing the filtered scope of the visible data as
      affected by that vis
      ###
      clipDescriptor: ->
        t = 'Scatter:'
        xt = data.fields[@configs.xAxis].fieldName
        yt =
          if globals.configs.fieldSelection.length isnt 1 then 'Y-Values'
          else data.fields[globals.configs.fieldSelection[0]].fieldName

        x = @configs.xBounds
        y = @configs.yBounds

        xr = x.min + ' to ' + x.max
        yr = y.min + ' to ' + y.max
        d = '<b>' + t + '</b>'

        unless (x.min? and x.max? and y.min? and y.max?)
          d += '<div class="small">Scatter has no active filters.</div>'
          return $('#scatter_descriptor').html(d)

        d += '<table class="small">'
        d += "<tr><td>#{xt}</td><td>#{xr}</td></tr>"
        d += "<tr><td>#{yt}</td><td>#{yr}</td></tr>"
        d += '</table>'

        $('#scatter_descriptor').html(d)

    if "Scatter" in data.relVis
      globals.scatter = new Scatter "scatter_canvas"
    else
      globals.scatter = new DisabledVis "scatter_canvas"
