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
      
    class window.Scatter extends BaseHighVis
        ###
        Initialize constants for scatter display mode.
        ###
        constructor: (@canvas) ->
            @SYMBOLS_LINES_MODE = 3
            @LINES_MODE = 2
            @SYMBOLS_MODE = 1

            @MAX_SERIES_SIZE = 600
            @INITIAL_GRID_SIZE = 150

            @xGridSize = @yGridSize = @INITIAL_GRID_SIZE
                
            @mode = @SYMBOLS_MODE

            @xAxis = data.normalFields[0]

            @advancedTooltips = 0
                                          
            #Do the cool existential operator thing
            @savedRegressions ?= []

            @xBounds =
                dataMax: undefined
                dataMin: undefined
                max: undefined
                min: undefined
                userMax: undefined
                userMin: undefined

            @yBounds =
                dataMax: undefined
                dataMin: undefined
                max: undefined
                min: undefined
                userMax: undefined
                userMin: undefined

            @fullDetail = 0
            @updateOnZoom = 1

        storeXBounds: (bounds) ->
            @xBounds = bounds

        storeYBounds: (bounds) ->
            @yBounds = bounds
            
                
        ###
        Build up the chart options specific to scatter chart
            The only complex thing here is the html-formatted tooltip.
        ###
        buildOptions: ->
            super()

            self = this
            
            $.extend true, @chartOptions,
                chart:
                    type: if @mode is @LINES_MODE then "line" else "scatter"
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
                          ele = ($ @.graphic.element)
                          root = ele.parent()
                          root.append ele
                title:
                    text: ""
                tooltip:
                    formatter: ->
                        if @series.name.regression?
                          str  = @series.name.regression.tooltip
                        else
                          if self.advancedTooltips
                              str  = "<div style='width:100%;text-align:center;color:#{@series.color};'> #{@series.name.group}</div><br>"
                              str += "<table>"

                              for field, fieldIndex in data.fields when @point.datapoint[fieldIndex] isnt null
                                  dat = if (Number field.typeID) is data.types.TIME
                                      (globals.dateFormatter @point.datapoint[fieldIndex])
                                  else
                                      @point.datapoint[fieldIndex]
                                      
                                  str += "<tr><td>#{field.fieldName}</td>"
                                  str += "<td><strong>#{dat}</strong></td></tr>"
                                  
                              str += "</table>"
                          else
                              str  = "<div style='width:100%;text-align:center;color:#{@series.color};'> #{@series.name.group}</div><br>"
                              str += "<table>"
                              str += "<tr><td>#{@series.xAxis.options.title.text}:</td><td><strong>#{@x}</strong></td></tr>"
                              str += "<tr><td>#{@series.name.field}:</td><td><strong>#{@y}</strong></td></tr>"
                              str += "</table>"
                    useHTML: true
                    hideDelay: 0
                
                xAxis: [{
                    type: 'linear'
                    gridLineWidth: 1
                    minorTickInterval: 'auto'
                    }]
                yAxis:
                    type: if globals.logY is 1 then 'logarithmic' else 'linear'
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
            for field, fieldIndex in data.fields when fieldIndex in data.normalFields
                count += 1
                options =
                    legendIndex: fieldIndex
                    data: []
                    color: '#000'
                    showInLegend: if fieldIndex in globals.fieldSelection then true else false
                    name: field.fieldName

                switch
                    when @mode is @SYMBOLS_LINES_MODE
                        options.marker =
                            symbol: globals.symbols[count % globals.symbols.length]
                        options.lineWidth = 2
                
                    when @mode is @SYMBOLS_MODE
                        options.marker =
                            symbol: globals.symbols[count % globals.symbols.length]
                        options.lineWidth = 0

                    when @mode is @LINES_MODE
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
            @drawRegressionControls()
            @drawSaveControls()

        ###
        Update the chart by removing all current series and recreating them
        ###
        update: () ->
            #Remove all series and draw legend
            super()
            
            #Set axis title
            title =
              text: fieldTitle data.fields[@xAxis]
            @chart.xAxis[0].setTitle title, false

            #Compute max bounds if there is no user zoom
            if not @isZoomLocked()

                @yBounds.min = @xBounds.min =  Number.MAX_VALUE
                @yBounds.max = @xBounds.max = -Number.MAX_VALUE
            
                for fieldIndex, symbolIndex in data.normalFields when fieldIndex in globals.fieldSelection
                    for group, groupIndex in data.groups when groupIndex in globals.groupSelection
                        @yBounds.min = Math.min @yBounds.min, (data.getMin fieldIndex, groupIndex)
                        @yBounds.max = Math.max @yBounds.max, (data.getMax fieldIndex, groupIndex)

                        @xBounds.min = Math.min @xBounds.min, (data.getMin @xAxis, groupIndex)
                        @xBounds.max = Math.max @xBounds.max, (data.getMax @xAxis, groupIndex)
                        
                        if (@timeMode isnt undefined) and (@timeMode is @GEO_TIME_MODE)
                          @xBounds.min = (new Date(@xBounds.min)).getUTCFullYear()
                          @xBounds.max = (new Date(@xBounds.max)).getUTCFullYear()
            
            #Calculate grid spacing for data reduction
            width = ($ '#' + @canvas).width()
            height = ($ '#' + @canvas).height()

            @xGridSize = @yGridSize = @INITIAL_GRID_SIZE
            
            if width > height
                @yGridSize = Math.round (height / width * @INITIAL_GRID_SIZE)
            else
                @xGridSize = Math.round (width / height * @INITIAL_GRID_SIZE)

            #Draw series
            for fieldIndex, symbolIndex in data.normalFields when fieldIndex in globals.fieldSelection
                for group, groupIndex in data.groups when groupIndex in globals.groupSelection
                    dat = if not @fullDetail
                        sel = data.xySelector(@xAxis, fieldIndex, groupIndex)
                        globals.dataReduce sel, @xBounds, @yBounds, @xGridSize, @yGridSize, @MAX_SERIES_SIZE
                    else
                        data.xySelector(@xAxis, fieldIndex, groupIndex)
                    
                    options =
                        data: dat
                        showInLegend: false
                        color: globals.colors[groupIndex % globals.colors.length]
                        name:
                            group: data.groups[groupIndex]
                            field: data.fields[fieldIndex].fieldName

                    switch
                        when @mode is @SYMBOLS_LINES_MODE
                            options.marker =
                                symbol: globals.symbols[symbolIndex % globals.symbols.length]
                            options.lineWidth = 2

                        when @mode is @SYMBOLS_MODE
                            options.marker =
                                symbol: globals.symbols[symbolIndex % globals.symbols.length]
                            options.lineWidth = 0

                        when @mode is @LINES_MODE
                            options.marker =
                                symbol: 'blank'
                            options.lineWidth = 2
                            options.dashStyle = globals.dashes[symbolIndex % globals.dashes.length]

                    @chart.addSeries options, false
                    
            if @isZoomLocked()
              @updateOnZoom = 0
              @setExtremes()
              ($ '#zoomResetButton').removeClass("disabled")
            else
              @resetExtremes
              ($ '#zoomResetButton').addClass("disabled")
                        
            @chart.redraw()
            
            @storeXBounds @chart.xAxis[0].getExtremes()
            @storeYBounds @chart.yAxis[0].getExtremes()
            
            #Disable/enable all of the saved regressions as necessary
            for regression in @savedRegressions
              #Filter out the ones that should be enabled.
              if regression.field_indices[0] == @xAxis \ #X indices must match.
              && "#{regression.field_indices[2]}" == "#{globals.groupSelection}" \ #Compare the arrays without comparing them.
              && globals.fieldSelection.indexOf(regression.field_indices[1]) != -1 #Y axis must be present
                #Add the regression to the chart
                @chart.addSeries(regression.series)
                #Enabled the class by removing the disabled class
                ($ 'tr#row_' + regression.series.name.id).removeClass('regression_row_disabled')
              else
                #Prevent duplicate add classes
                if ($ 'tr#row_' + regression.series.name.id).hasClass('regression_row_disabled') is false
                  ($ 'tr#row_' + regression.series.name.id).addClass('regression_row_disabled')
            
            #Display the table header if necessary    
            if ($ '#regressionTableBody > tr').length > 0
              ($ 'tr#regressionTableHeader').show()
            else ($ 'tr#regressionTableHeader').hide()

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
            controls += "<button id='zoomOutButton' class='zoom_button btn btn-default'>Out</button>"
            controls += "<button id='zoomResetButton' class='zoom_button btn btn-default'>Fit</button>"

            controls += "<h4 class='clean_shrink'>Display Mode</h4>"

            for [mode, modeText] in [[@SYMBOLS_LINES_MODE, "Symbols and Lines"],
                                    [@LINES_MODE,         "Lines Only"],
                                    [@SYMBOLS_MODE,       "Symbols Only"]]
                controls += '<div class="inner_control_div">'
                controls += "<div class='radio'><label><input class='mode_radio' type='radio' name='mode_selector' value='#{mode}' #{if @mode is mode then 'checked' else ''}/>"
                controls += modeText + "</label></div></div>"

            controls += "<br>"
            controls += "<h4 class='clean_shrink'>Other</h4>"
                
            controls += '<div class="inner_control_div">'
            controls += "<div class='checkbox'><label><input class='tooltip_box' type='checkbox' name='tooltip_selector' #{if @advancedTooltips then 'checked' else ''}/> Advanced Tooltips</label></div> "
            controls += "</div>"

            controls += '<div class="inner_control_div">'
            controls += "<div class='checkbox'><label><input class='full_detail_box' type='checkbox' name='full_detail_selector' #{if @fullDetail then 'checked' else ''}/> Full Detail </label></div>"
            controls += "</div>"

            if data.logSafe is 1
                controls += '<div class="inner_control_div">'
                controls += "<div class='checkbox'><label><input class='logY_box' type='checkbox' name='log_selector' #{if globals.logY is 1 then 'checked' else ''}/> Logarithmic Y Axis </label></div>"
                controls += "</div>"

            if elaspedTimeButton
                controls += "<div class='inner_control_div' style='text-align:center'>"
                controls += "<button id='elaspedTimeButton' class='save_button btn btn-default'>Generate Elapsed Time </button>"
                controls += "</div>"
                
            controls+= "</div></div>"
            
            # Write HTML
            ($ '#controldiv').append controls

            ($ '#zoomResetButton').button()
            ($ '#zoomResetButton').click (e) =>
              @resetExtremes(($ '#zoomSelector').val())
              
            # Set initial state of zoom reset
            if not @isZoomLocked()
              ($ '#zoomResetButton').addClass("disabled")
            else
              ($ '#zoomResetButton').addClass("enabled")
            
            ($ '#zoomOutButton').button()
            ($ '#zoomOutButton').click (e) =>
              @zoomOutExtremes(($ '#zoomSelector').val())

            ($ '.mode_radio').click (e) =>
                @mode = Number e.target.value
                @start()

            ($ '.tooltip_box').click (e) =>
                @advancedTooltips = (@advancedTooltips + 1) % 2
                true

            ($ '.full_detail_box').click (e) =>
                @fullDetail = (@fullDetail + 1) % 2
                @delayedUpdate()
                true
                
            ($ '.logY_box').click (e) =>
                globals.logY = (globals.logY + 1) % 2
                @start()

            ($ '#elaspedTimeButton').button()
            ($ '#elaspedTimeButton').click (e) =>
                globals.generateElapsedTimeDialog()

            #Set up accordion
            globals.toolsOpen ?= 0

            ($ '#toolControl').accordion
                collapsible:true
                active:globals.toolsOpen

            ($ '#toolControl > h3').click ->
                globals.toolsOpen = (globals.toolsOpen + 1) % 2

        ###
        Draws x axis selection controls
            This includes a series of radio buttons.
        ###
        drawXAxisControls: (filter = (fieldIndex) -> (fieldIndex in data.normalFields)) ->
            #Don't draw if there's only one possible selection
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

                controls += "<div class='radio'><label><input class='xAxis_input' type='radio' name='xaxis' value='#{fieldIndex}' #{if (Number fieldIndex) == @xAxis then "checked" else ""}>"
                controls += "#{data.fields[fieldIndex].fieldName}</label></div>"
                controls += "</div>"

            controls += '</div></div>'

            # Write HTML
            ($ '#controldiv').append controls

            # Make xAxis radio handler
            ($ '.xAxis_input').change (e) =>
                selection = null
                ($ '.xAxis_input').each ()->
                    if @checked
                        selection = @value
                @xAxis = Number selection

                #@delayedUpdate()
                @resetExtremes()
                @update()

            #Set up accordion
            globals.xAxisOpen ?= 0

            ($ '#xAxisControl').accordion
                collapsible:true
                active:globals.xAxisOpen

            ($ '#xAxisControl > h3').click ->
                globals.xAxisOpen = (globals.xAxisOpen + 1) % 2

        ###
        Checks if the user has requested a specific zoom
        ###
        isZoomLocked: ->
            not (undefined in [@xBounds.userMin, @xBounds.userMax])

        resetExtremes: (whichAxis) ->
            if @chart isnt undefined    
                if whichAxis in ['Both', 'X']     
                    @chart.xAxis[0].setExtremes()
                if whichAxis in ['Both', 'Y']
                    @chart.yAxis[0].setExtremes()
                
        setExtremes: ->
            if (@chart isnt undefined)
              if(@xBounds.min? and @yBounds.min?)
                @chart.xAxis[0].setExtremes(@xBounds.min,@xBounds.max,true)
                @chart.yAxis[0].setExtremes(@yBounds.min,@yBounds.max,true)
              else @resetExtremes()
                
        zoomOutExtremes: (whichAxis) ->
          
            xRange = @xBounds.max - @xBounds.min
            yRange = @yBounds.max - @yBounds.min
          
            if whichAxis in ['Both', 'X']
                @xBounds.max += xRange * 0.1
                @xBounds.min -= xRange * 0.1
          
            if whichAxis in ['Both', 'Y']
                if globals.logY is 1
                    @yBounds.max *= 10.0
                    @yBounds.min /= 10.0
                else
                    @yBounds.max += yRange * 0.1
                    @yBounds.min -= yRange * 0.1
          
            @setExtremes()

        ###
        Saves the current zoom level
        ###
        end: ->
        
          if chart?
            @storeXBounds @chart.xAxis[0].getExtremes()
            @storeYBounds @chart.yAxis[0].getExtremes()
         
          super()
            
        ###
        Saves the zoom level before cleanup
        ###
        serializationCleanup: ->
            super()
            
        ###
        Updates x axis for regression.
        ###
        updateXRegression:() ->
          $('#regressionXAxis').text("#{data.fields[@xAxis].fieldName}")
          
        ###
        Updates y axis for regression.
        ###
        updateYRegression:() ->
          if $('#regressionYAxisSelector')?
            $('#regressionYAxisSelector').empty()
            for fieldIndex in globals.fieldSelection
              $('#regressionYAxisSelector').append($("<option/>", {
                value: fieldIndex,
                text: data.fields[fieldIndex].fieldName
              }));

        ###
        Adds the regression tools to the control bar.
        ###
        drawRegressionControls: () ->

            controls = 
              """
              <div id="regressionControl" class="vis_controls">
              <h3 class='clean_shrink'><a href='#'>Analysis Tools:</a></h3>
              <div class='outer_control_div' style='text-align:center'>

              <table><tr>
              <td style='text-align:left'>X Axis: </td>
              <td id='regressionXAxis' style='text-align:left'>#{data.fields[@xAxis].fieldName}</td></tr>
              
              <tr><td style='text-align:left'>Y Axis: </td>
              <td><select id='regressionYAxisSelector' class='form-control'>
              """

            for fieldIndex in globals.fieldSelection
              controls += "<option value='#{fieldIndex}'>#{data.fields[fieldIndex].fieldName}</option>"

            controls +=
              """
              </select></td></tr>
              <tr><td style='text-align:left'>Type: </td>
              <td><select id="regressionSelector" class="form-control">
              """

            regressions = ['Linear', 'Quadratic', 'Cubic', 'Exponential', 'Logarithmic']
            for regression_type in regressions
              controls += "<option value='#{regressions.indexOf(regression_type)}'>#{regression_type}</option>"

            controls += 
              """
              </select></td></tr>           
              </table>
              <button id='regressionButton' class='save_button btn btn-default'>Draw Best Fit Line</button>
              <table id='regressionTable' class='regression_table fixed' >
              <col width='55%' />
              <col width='35%' />
              <col width='10%' />
              <tr id='regressionTableHeader'><td><strong>f(x)<strong></td><td><strong>Type<strong></td></tr>
              <tbody id='regressionTableBody'></tbody></table>
              </div></div>
              """

            #Write HTML
            ($ '#controldiv').append controls
            ($ "#regressionControl button").button()
            
            #Add all the saved regressions correctly
            for regression in @savedRegressions
              #Filter out the ones that should be enabled.
              if regression.field_indices[0] == @xAxis \ #X indices must match.
              && "#{regression.field_indices[2]}" == "#{globals.groupSelection}" \ #Compare the arrays without comparing them.
              && globals.fieldSelection.indexOf(regression.field_indices[1]) != -1 #Y axis must be present
                @chart.addSeries(regression.series)
                @addRegressionToTable(regression, true)
              else
                @addRegressionToTable(regression, false)
            
            #Catches change in y axis
            ($ '.y_axis_input').click (e) =>
              @updateYRegression()
            
            #Catches change in x axis  
            ($ '.xAxis_input').change (e) =>
              @updateXRegression()
                   
            ($ "#regressionButton").click =>      

              #Make the title for the tooltip
              x_axis_name = data.fields[@xAxis].fieldName
              y_axis_name = ($ '#regressionYAxisSelector option:selected').text()
              name = "<strong>#{y_axis_name}</strong> as a #{($ '#regressionSelector option:selected').text().toLowerCase()} "
              name += "function of <strong>#{x_axis_name}</strong>"
              
              #Get the current selected y index, the regression type, and the current group index
              y_axis_index = Number(($ '#regressionYAxisSelector').val())
              regression_type = Number(($ '#regressionSelector').val())
              group_index = globals.groupSelection

              #Get the x and y data as a clippable object
              full_data = data.multiGroupXYSelector(@xAxis, y_axis_index, group_index)
              #console.log("Pre clip")

              #Clip the x and y data so they only include the visible points
              full_data = globals.clip(full_data, @xBounds, @yBounds)
              #console.log("Full data post clip", full_data)

              #Separate the x and y data
              x_data = 
                point.x for point in full_data                   
              y_data = 
                point.y for point in full_data
              
              #Get dash index
              dash_index = data.normalFields.indexOf(y_axis_index)
              dash_style = globals.dashes[dash_index % globals.dashes.length]
              
              regressionMade = true
              try
                #Get the new regression              
                new_regression = globals.getRegression(
                  x_data,
                  y_data, 
                  regression_type,
                  @xBounds,
                  name,
                  dash_style
                  )
              catch error
                regressionMade = false
                if regression_type is 3
                  alert "Unable to calculate an #{regressions[regression_type]} regression for this data."
                else 
                  alert "Unable to calculate a #{regressions[regression_type]} regression for this data."

              if regressionMade
                #Get a unique identifier (last highest count plus one)
                regression_identifier = '';
                count = 0;
                for regression in @savedRegressions
                  if regression.type == regression_type \
                  and regression.field_indices[1] == y_axis_index \
                  and count <= regression.type_count
                    count = regression.type_count + 1;

                if count
                  regression_identifier = '(' + (count + 1) + ')'
                
                #Add the series
                new_regression.name.id = 'regression_' + y_axis_index + '_' + regression_type + '_' + count
                @chart.addSeries(new_regression)

                #Prepare to save regression fields
                saved_regression =
                  type:
                    regression_type
                  type_count:
                    count
                  field_indices:
                    [@xAxis, y_axis_index, group_index]
                  field_names:
                    [x_axis_name, y_axis_name]
                  series:
                    new_regression
                  regression_id:
                    regression_identifier
                  bounds:
                    [@xBounds, @yBounds]

                #Save a regression
                @savedRegressions.push(saved_regression)

                #Actually add the regression to the table
                @addRegressionToTable(saved_regression, true)

            #Set up accordion
            globals.regressionOpen ?= 0

            ($ '#regressionControl').accordion
                collapsible:true
                active:globals.regressionOpen
                heightStyle:"content"

            ($ '#regressionControl > h3').click ->
                globals.regressionOpen = (globals.regressionOpen + 1) % 2
                
        #Adds a regression row to our table, with styling for enabled or disabled
        addRegressionToTable: (saved_reg, enabled) ->
               
          #Remove object from an array
          Array::filterOutValue = (v) -> x for x in @ when x != v
        
          #Here have a list of regressions
          regressions = ['Linear', 'Quad', 'Cubic', 'Exp', 'Log']
        
          #Add the entry used the passed regression
          regression_row =
            """
            <tr id = 'row_#{saved_reg.series.name.id}' class='regression_row'>
            <td class='regression_rowdata truncate'>#{saved_reg.field_names[1]}(#{saved_reg.field_names[0]})</td>
            <td class='regression_rowdata'>#{regressions[saved_reg.type]}#{saved_reg.regression_id}</td>
            <td id='#{saved_reg.series.name.id}' class='delete regression_remove'><i class='fa fa-times-circle'></i></td>
            </tr>
            """
            
          #Added a info relating to this regression
          ($ '#regressionTableBody').append(regression_row)
          
          #Add the disabled style if necessary
          if !enabled
            ($ 'tr#row_' + saved_reg.series.name.id).addClass('regression_row_disabled')
          
          #Display the table header
          ($ 'tr#regressionTableHeader').show()
          
          #Make each row a link to its view
          ($ 'tr#row_' + saved_reg.series.name.id).click =>
            #Reset the state of when you saved
            @xAxis = saved_reg.field_indices[0]
            globals.fieldSelection = [saved_reg.field_indices[1]]
            globals.groupSelection = saved_reg.field_indices[2]          

            @xBounds = saved_reg.bounds[0]
            @yBounds = saved_reg.bounds[1]
            
            ($ '.xAxis_input').each (i, input)=>
              if Number(input.value) == saved_reg.field_indices[0]
                input.checked = true

            @update()
          
          #Add a make the delete button remove the regression object
          ($ 'td#' + saved_reg.series.name.id).click =>
            
            #Remove regression view from the screen.
            ($ 'td#' + saved_reg.series.name.id).parent().remove()
            
            #Display the table header if necessary    
            if ($ '#regressionTableBody > tr').length > 0
              ($ 'tr#regressionTableHeader').show()
            else ($ 'tr#regressionTableHeader').hide()
            
            #Remove regression from the savedRegressions array.
            id = saved_reg.series.name.id 
            for regression in @savedRegressions
              if (regression.series.name.id == id)
                @savedRegressions = @savedRegressions.filterOutValue(regression)
                break

            #Remove regression from the chart
            for series, i in @chart.series
              if (series.name.id == id)
                @chart.series[i].remove()
                break
                
          #Make the hovering highlight the correct regression
          ($ 'tr#row_' + saved_reg.series.name.id).mouseover =>
          
            #Remove regression from the chart
            id = saved_reg.series.name.id 
            for series, i in @chart.series
              if (series.name.id == id)
                @chart.series[i].setState('hover')
                @chart.tooltip.refresh(@chart.series[i].points[@chart.series[i].points.length - 1])
                break
          
          #When the mouse leaves, don't highlight anymore
          ($ 'tr#row_' + saved_reg.series.name.id).mouseout =>
          
            #Remove regression from the chart
            id = saved_reg.series.name.id 
            for series, i in @chart.series
              if (series.name.id == id)
                @chart.series[i].setState()
                @chart.tooltip.hide()
                break
          
    if "Scatter" in data.relVis
        globals.scatter = new Scatter "scatter_canvas"
    else
        globals.scatter = new DisabledVis "scatter_canvas"
