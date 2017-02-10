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

      start: ->
        @configs.analysisType ?= @ANALYSISTYPE_TOTAL
        @configs.histogramDensity ?= false
        
        # Default Sort
        fs = globals.configs.fieldSelection
        @configs.sortField ?= if fs? then fs[0] else @SORT_DEFAULT
        @configs.sortFieldId ?=
          if @configs.sortField == @SORT_DEFAULT
            -2
          else
            data.fields[@configs.sortField].fieldID
        
        if @configs.sortFieldId == -2 then @configs.sortField = @SORT_DEFAULT
        else if @configs.sortFieldId == -1 then @configs.sortField = 0
        else
          fieldIds = for field in data.fields
            field.fieldID
          @configs.sortField = fieldIds.indexOf(@configs.sortFieldId)


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
              # Formatter for point tooltips
              if @series.name == "histogram density"
                str  = "<div style='width:100%;text-align:center;"
                str += "color:#{@point.groupColor};margin-bottom:5px'> "
                str += "#{@point.name}</div>"
                str += "<table><tr><td>#{@point.field}: "
                str += "</td><td><strong>#{@y} \
                #{@point.fieldUnit}</strong></td></tr>"
                str += "</table>"
              # Formatter for bar tooltips
              else if @series.type == "column"
                str  = "<div style='width:100%;text-align:center;"
                if self.configs.histogramDensity
                  str += "color:#{@point.borderColor};margin-bottom:5px'> "
                else
                  str += "color:#{@point.color};margin-bottom:5px'> "
                str += "<b><u>Group : #{@point.name}</u></b></div>"
                str += "<table>"
                str += "<tr><td style='text-align: right'>Analysis Type :&nbsp</td>"
                str += "<td>#{self.analysisTypeNames[self.configs.analysisType]}</td></tr>"
                str += "<tr><td style='text-align: right'>#{@point.field} :&nbsp</td>"
                str += "<td>#{@y}</td></tr>"
                str += "<tr><td style='text-align: right'>Standard Deviation :&nbsp</td>"
                str += "<td>± #{@point.stdDev}</td></tr>"
                #{@point.fieldUnit}</strong></td></tr>"
                str += "</table>"
              # Formatter for error bar tooltips
              else
                str  = "<div style='width:100%;text-align:center;"
                if self.configs.histogramDensity
                  str += "color:#{@point.borderColor};margin-bottom:5px'> "
                else
                  str += "color:#{@point.color};margin-bottom:5px'> "
                str += "<b><u>Error Bar for Group : #{@point.name}</u></b><br>"
                str += "<b>Bounds Represent Data ± 1 StdDev</b><br></div>"
                str += "<table>"
                str += "<tr><td style='text-align: right'>Upper Bound :&nbsp</td>"
                str += "<td>#{@y}</td></tr>"
                str += "<tr><td style='text-align: right'>Lower Bound :&nbsp</td>"
                str += "<td>#{@y - 2 * @point.stdDev}</td></tr>"
                #{@point.fieldUnit}</strong></td></tr>"
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
            tickWidth: 0
            tickPositioner: ->
              # Only place tick marks under the center point of each field cluster
              positions = []
              tick = 0
              while tick <= @dataMax and positions.length < globals.configs.fieldSelection.length
                positions.push(tick)
                tick += 4
              positions
            labels:
              formatter: ->
                # The bars are always placed in numerical order by ID, so the labels must be as well
                fieldsInOrder = for fid in data.normalFields when fid in globals.configs.fieldSelection
                  fid
                # Only label certain tick marks, and only if there is more than one field selected.
                if @value % 4 == 0 and globals.configs.fieldSelection.length != 1
                  fieldTitle(data.fields[fieldsInOrder[@value / 4]])
                else
                  ""
          legend:
            enabled: $(window).width() > 700 && data.groups.length < 30
            

      update: ->
        super()

        fieldSelection = globals.configs.fieldSelection

        @configs.sortFieldId =
          if @configs.sortField == @SORT_DEFAULT then -2 else data.fields[@configs.sortField].fieldID
        
        # Get the column data
        groupedData = {}
        for f in data.normalFields
          groupedData[f] = @getGroupedData(f)

        # Sort the sort-by field
        # The default sort is just the group order
        # Otherwise, make sortable key-pairs and sort by the sortField array
        sortedGroupIDs =
          if @configs.sortField is @SORT_DEFAULT
            sortable = []
            sortable.push [k, v]  for v, k in data.groups when k in data.groupSelection
            sortable.sort (a,b) -> a[1].toLowerCase().localeCompare(b[1].toLowerCase())
            Number k for [k, v] in sortable
          else
            sortable = []
            sortable.push [k, v] for k, v of groupedData[@configs.sortField]
            sortable.sort (a,b) -> a[1] - b[1]
            Number k for [k, v] in sortable
        
        # interval, xCluster, and pos are used to place bars into clusters based
        # on which field the bar is for. Bars are evenly spaced inside a range
        # of 3 units. Each cluster is 4 units apart.
        interval = 3 / (data.groupSelection.length + 1)
        xCluster = 0
        pos = 1
        # Draw the bars
        # Bar charts are graphed at explicit x-coordinates instead of
        # implicit (and easier) categories to support the histogram density feature
        datArray = []
        dp = globals.getData(true, globals.configs.activeFilters)
        for fid in data.normalFields when fid in fieldSelection
          for gid in sortedGroupIDs when gid in data.groupSelection
            xCoord = (xCluster - 1.5) + pos * interval
            stdDev = data.getStandardDeviation(fid, gid, dp)
            thisData = {
              x: xCoord
              y: groupedData[fid][gid]
              stdDev: stdDev
              name: data.groups[gid] or data.noField()
              # field and fieldUnit are used by the tooltip
              field: fieldTitle(data.fields[fid])
              fieldUnit: fieldUnit(data.fields[fid], false)
            }
            
            if @configs.histogramDensity
              thisData.color = 'rgba(255,255,255,0)'
              thisData.borderColor = globals.getColor(gid)
            else
              thisData.color = globals.getColor(gid)
            
            pos += 1
            datArray.push(thisData)
            
          xCluster += 4
          pos = 1

        # In order to set a max width to bars, we need to dynamically calculate the pointPadding
        # If there are less than six bars, make the bars as wide as they would be if there were
        #   six bars
        # NOTE: If/when we upgrade to highcharts v4.1.8 or later, this should be implemented with
        #   the maxPointWidth parameter instead

        numberOfBars = datArray.length
        ptPadding = 0.05
        if numberOfBars < 6
          ptPadding = 0.5 - (0.075 * numberOfBars)
          
        series = {
          data: datArray
          showInLegend: false # Dummy Legend used instead (see buildLegendSeries())
          borderWidth: if @configs.histogramDensity then 4 else 0
          pointWidth: null
          pointPadding: ptPadding
          minPointLength: 2 # Allows tooltips to at least show up on ~0 values
                            # 2 is the height of the line y=0, so values =0 will not appear as > 0
          groupPadding: 0
          states:
            hover:
              enabled: not @configs.histogramDensity # hover makes bars invisible in histogramDensity mode
        }
        @chart.addSeries series, false

        # Draw "error bars", if option is enabled
        # Error bars represent +/- 1 standard deviation
        if @configs.analysisType == @ANALYSISTYPE_MEAN_ERROR
          allErrors = []
          xCluster = 0
          pos = 1
          dp = globals.getData(true, globals.configs.activeFilters)
          for fid in data.normalFields when fid in fieldSelection
            for gid in sortedGroupIDs when gid in data.groupSelection
              stdDev = data.getStandardDeviation(fid, gid, dp)
              barData = data.selector fid, gid, dp
              xCoord = (xCluster - 1.5) + pos * interval
              name = data.groups[gid] or data.noField()
              if barData.length == 0
                barData.push(0) # Null values short circuit this function; fill with zero
              if barData.length == 1
                # Error bar must be present or it causes issues with other bars
                thisError = {
                  name: "#{name}"
                  x: xCoord
                  stdDev: stdDev
                  low: barData[0]
                  high: barData[0]
                  field: fieldTitle(data.fields[fid])
                  fieldUnit: fieldUnit(data.fields[fid], false)
                }
              else
                mean = groupedData[fid][gid]
                if !globals.configs.logY
                  thisError = {
                    name: "#{name}"
                    x: xCoord
                    stdDev: stdDev
                    low: mean - stdDev
                    high: mean + stdDev
                    field: fieldTitle(data.fields[fid])
                    fieldUnit: fieldUnit(data.fields[fid], false)
                  }
                else if mean > 0
                  thisError = {
                    name: "{name}"
                    x: xCoord
                    stdDev: stdDev
                    low: mean
                    high: mean + stdDev
                    field: fieldTitle(data.fields[fid])
                    fieldUnit: fieldUnit(data.fields[fid], false)
                  }
                else
                  thisError = {}
              
              pos += 1
              allErrors.push(thisError)

            xCluster += 4
            pos = 1

          series = {
            type: 'errorbar'
            data: allErrors
          }
          @chart.addSeries series

        # Draw points for histogram density, if option is on
        if @configs.histogramDensity
          dp = globals.getData(true, globals.configs.activeFilters)
          datArray = []
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
              dat = data.xySelector(0, fid, gid, dp)
              for point in dat
                datArray.push({
                  x: xCoord
                  y: point.y
                  name: data.groups[gid] or data.noField()
                  color: "rgba(#{r}, #{g}, #{b}, #{a})"
                  groupColor: globals.getColor(gid)
                  field: fieldTitle(data.fields[fid])
                  fieldUnit: fieldUnit(data.fields[fid], false)
                })
              pos += 1
              
            xCluster += 4
            pos = 1
            
          series = {
            type: 'scatter'
            name: 'histogram density'
            data: datArray
            showInLegend: false
            color: 'rgba(255, 255, 255, 0)'
            marker:
              enabled: true
              symbol: 'square'
          }
          
          @chart.addSeries series
          
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
            sortable = []
            sortable.push [k, v]  for v, k in data.groups when k in data.groupSelection
            sortable.sort (a,b) -> a[1].toLowerCase().localeCompare(b[1].toLowerCase())
            Number k for [k, v] in sortable
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
        $('[data-toggle="tooltip"]').tooltip();

    if "Bar" in data.relVis
      globals.bar = new Bar 'bar-canvas'
    else
      globals.bar = new DisabledVis "bar-canvas"
