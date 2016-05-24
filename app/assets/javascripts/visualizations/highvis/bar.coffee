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

    class window.Bar extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)
        xCoordsToBarIndex = []
        @xCoordsToErrorIndex = []
        @xCoordstoPointIndex = []

      start: ->
        @configs.analysisType ?= @ANALYSISTYPE_MEAN
        globals.configs.histogramDensity ?= false

        # Default Sort
        fs = globals.configs.fieldSelection
        @configs.sortField ?= if fs? then fs[0] else @SORT_DEFAULT

        super()

      buildOptions: (animate = true) ->
        super(animate)

        self = this

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: "column"
          title:
            text: ""
          tooltip:
            formatter: ->
              if @series.name == "histogram density"
                str  = "<div style='width:100%;text-align:center;"
                str += "color:#{@series.color};margin-bottom:5px'> "
                str += "#{@series.data[0].name}</div>"
                str += "<table><tr><td>#{@series.data[0].field}: "
                str += "</td><td><strong>#{@y} \
                #{@series.data[0].fieldUnit}</strong></td></tr>"
              else if @series.name == "error bars"
                index = 0
                for datapoint in @series.xData
                  break if datapoint == @x
                  index += 1
                str  = "<div style='width:100%;text-align:center;"
                if globals.configs.histogramDensity
                  str += "color:#{@series.data[index].borderColor};margin-bottom:5px'> "
                else
                  str += "color:#{@series.data[index].color};margin-bottom:5px'> "
                str += "#{@series.data[index].name}</div>"
                str += "<table>"
                str += "<tr><td>#{@series.data[index].field} "
                str += "(#{self.analysisTypeNames[self.configs.analysisType]}): "
                str += "</td><td><strong>#{@y} \
                #{@series.data[index].fieldUnit}</strong></td></tr>"
                str += "</table>"
              else
                index = 0
                for datapoint in @series.xData
                  break if datapoint == @x
                  index += 1
                str  = "<div style='width:100%;text-align:center;"
                if globals.configs.histogramDensity
                  str += "color:#{@series.data[index].borderColor};margin-bottom:5px'> "
                else
                  str += "color:#{@series.data[index].color};margin-bottom:5px'> "
                str += "#{@series.data[index].name}</div>"
                str += "<table>"
                str += "<tr><td>#{@series.data[index].field} "
                str += "(#{self.analysisTypeNames[self.configs.analysisType]}): "
                str += "</td><td><strong>#{@y} \
                #{@series.data[index].fieldUnit}</strong></td></tr>"
                str += "</table>"
            useHTML: true
          yAxis:
            type: if globals.configs.logY then 'logarithmic' else 'linear'
            plotLines: [{
              color: '#000000'
              width: 2
              value: 0
             }]
          xAxis:
            tickPositioner: ->
              positions = []
              tick = 0
              while tick < @dataMax and positions.length < globals.configs.fieldSelection.length
                positions.push(tick)
                tick += 4
              positions
            labels:
              enabled: true
              formatter: ->
                if @value % 4 == 0
                  fieldTitle(data.fields[globals.configs.fieldSelection[@value/4]])
                else
                  ""
          legend:
            enabled: $(window).width() > 700 && data.groups.length < 30
            

      update: ->
        super()

        fieldSelection = globals.configs.fieldSelection
        
        # Get the column data
        groupedData = {}
        for f in data.normalFields
          groupedData[f] = @getGroupedData(f)

        # Sort the sort-by field
        # The default sort is just the group order
        # Otherwise, make sortable key-pairs and sort by the sortField array
        sortedGroupIDs =
          if @configs.sortField is @SORT_DEFAULT
            i for n, i in data.groups when i in data.groupSelection
          else
            sortable = []
            sortable.push [k, v] for k, v of groupedData[@configs.sortField]
            sortable.sort (a,b) -> a[1] - b[1]
            Number k for [k, v] in sortable
                      
        interval = 3 / (data.groupSelection.length + 1)
        # Draw the bars
        datArray = []
        xCluster = 0
        pos = 1
        for fid in data.normalFields when fid in fieldSelection
          for gid in sortedGroupIDs when gid in data.groupSelection
            xCoord = (xCluster - 1.5) + pos * interval
            thisData = {
              x: xCoord
              y: groupedData[fid][gid]
              name: data.groups[gid] or data.noField()
              field: fieldTitle(data.fields[fid])
              fieldUnit: fieldUnit(data.fields[fid], false)
            }
            
            if globals.configs.histogramDensity
              thisData.color = 'rgba(255,255,255,0)'
              thisData.borderColor = globals.getColor(gid)
            else
              thisData.color = globals.getColor(gid)
            
            pos += 1
            datArray.push(thisData)
            
          xCluster += 4
          pos = 1
          
          
        series = {
          data: datArray
          showInLegend: false
          borderWidth: 4
          pointWidth: null
          pointPadding: 0
          groupPadding: 0
          states:
            hover:
              enabled: false
        }
        @chart.addSeries series, false
          
        # Draw error bars, if option is enabled
        if @configs.analysisType == @ANALYSISTYPE_MEAN_ERROR
          allErrors = []
          xCluster = 0
          pos = 1
          for fid in data.normalFields when fid in fieldSelection
            for gid in sortedGroupIDs when gid in data.groupSelection
              dp = globals.getData(true, globals.configs.activeFilters)
              barData = data.selector fid, gid, dp
              xCoord = (xCluster - 1.5) + pos * interval
              if barData.length == 1
                thisError = {}
              else
                mean = groupedData[fid][gid]
                innerStd = barData.map((x) -> (x - mean) ** 2).reduce((x, y) -> x + y)
                stdDev = Math.sqrt((1 / (barData.length - 1)) * innerStd)
                if !globals.configs.logY
                  # [mean - stdDev, mean + stdDev]
                  thisError = {
                    name: "Error for #{data.groups[gid]}" or data.noField()
                    x: xCoord
                    low: mean - stdDev
                    high: mean + stdDev
                  }
                else if mean > 0
                  thisError = {
                    name: "Error for #{data.groups[gid]}" or data.noField()
                    x: xCoord
                    low: mean
                    high: mean + stdDev
                  }
                else
                  thisError = {}
              
              pos += 1
              allErrors.push(thisError)
              
             xCluster += 4
             pos = 1

          series = {
            type: 'errorbar'
            name: 'error bars'
            data: allErrors
          }
          @chart.addSeries series

        # Draw points for histogram density, if option is on
        if globals.configs.histogramDensity
          console.time("drawpoints")
          console.time("getData")
          dp = globals.getData(true, globals.configs.activeFilters)
          console.timeEnd("getData")
          xCluster = 0
          pos = 1
          for fid in data.normalFields when fid in fieldSelection
            for gid in sortedGroupIDs when gid in data.groupSelection
              # Turn hex color into RGB so that we can add an alpha channel:
              rgb = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(globals.getColor(gid))
              r = parseInt(rgb[1], 16)
              g = parseInt(rgb[2], 16)
              b = parseInt(rgb[3], 16)
              a = .25
              xCoord = (xCluster - 1.5) + pos * interval
              #console.time("xySelector")
              dat = data.xySelector(0, fid, gid, dp)
              #console.timeEnd("xySelector")
              datArray = []
              #console.time("loop")
              for point in dat
                datArray.push({
                  x: xCoord
                  y: point.y
                  name: data.groups[gid] or data.noField()
                  color: 'rgba( '+ r + ', '+ g + ', ' + b + ', ' + a + ')'
                  field: fieldTitle(data.fields[fid])
                  fieldUnit: fieldUnit(data.fields[fid], false)
                })
              #console.timeEnd("loop")
              series = {
                type: 'scatter'
                name: 'histogram density'
                data: datArray
                showInLegend: false
                color: globals.getColor(gid)
                marker:
                  enabled: true
                  symbol: 'square'
                  fillColor: 'rgba( '+ r + ', '+ g + ', ' + b + ', ' + a + ')'
              }
              pos += 1
              @chart.addSeries series
              
            xCluster += 4
            pos = 1
                
          console.timeEnd("drawpoints")
        @chart.redraw()

      # Build dummy legend series
      buildLegendSeries: ->
        groupedData = {}
        for f in data.normalFields
          groupedData[f] = @getGroupedData(f)

        # Sort the sort-by field
        # The default sort is just the group order
        # Otherwise, make sortable key-pairs and sort by the sortField array
        sortedGroupIDs =
          if @configs.sortField is @SORT_DEFAULT
            i for n, i in data.groups when i in data.groupSelection
          else
            sortable = []
            sortable.push [k, v] for k, v of groupedData[@configs.sortField]
            sortable.sort (a,b) -> a[1] - b[1]
            Number k for [k, v] in sortable
            
        for gid in sortedGroupIDs when gid in data.groupSelection
          options =
            # dummy series needs to be scatter, otherwise it pushes
            # the other bars over.
            type: 'scatter'
            showInLegend: true
            color: globals.getColor(gid)
            data: []
            name: data.groups[gid] or data.noField()
            marker:
              symbol: 'square'
              radius: 6
            
          options

      drawControls: ->
        super()
        # Remove group by number fields, only for pie chart
        groups = $.extend(true, [], data.textFields)
        groups.splice(data.NUMBER_FIELDS_FIELD - 1, 1)
        # Remove Group By Time Period if there is no time data
        if data.hasTimeData is false or data.timeType == data.GEO_TIME
          groups.splice(data.TIME_PERIOD_FIELD - 2, 1)
        @drawGroupControls(groups)
        @drawYAxisControls(globals.configs.fieldSelection,
          data.normalFields.slice(1), false)
        @drawToolControls(true, true)
        @drawClippingControls()
        @drawSaveControls()
        $('[id^=ckbx-y-axis]').click (e) ->
          fs = globals.configs.fieldSelection
          if fs and fs.length == 1
            $('#sort-by').val(fs[0])

    if "Bar" in data.relVis
      globals.bar = new Bar 'bar-canvas'
    else
      globals.bar = new DisabledVis "bar-canvas"
