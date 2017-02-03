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

    class window.Box extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)

        @configs.meanLine ?= false
        @configs.horizontalBoxes ?= false
        @configs.whiskerMode ?= 'iqr'

      start: ->
        @configs.displayField = Math.min globals.configs.fieldSelection...
        super()

      buildOptions: (animate = true) ->
        super(animate)

        self = this

        plotLines = [{
              color: '#000000'
              width: 2
              value: 0
             }]

        if @configs.meanLine
          dp = globals.getData(true, globals.configs.activeFilters)
          mean = data.getMean(@configs.displayField, data.groupSelection, dp)
          plotLines.push({
            color: 'red'
            width: 2
            value: mean
            zIndex: 10 # draw on top
            id: 'meanLine'
            label:
              text: 'Mean: ' + mean
              style:
                color: 'gray'
          })

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: "boxplot"
            inverted: @configs.horizontalBoxes
          title:
            text: ""
          tooltip:
            formatter: ->
              if @series.options.type == "scatter"
                #formatter for outlier points
                str  = "<div style='width:100%;text-align:center;"
                str += "color:#{@series.color};'> "
                str += "#{@series.name}</div>"
                str += "<div style='width:100%;text-align:center;;margin-bottom:5px'>"
                str += "Outlier</div>"
                str += "<table><tr><td>#{@series.options.field}: "
                str += "</td><td><strong>#{@y} \
                #{@series.options.fieldUnit}</strong></td></tr>"
                str += "</table>"
              else
                #formatter for boxes
                topWhiskerLabel = "Q3 + 1.5 * IQR"
                bottomWhiskerLabel = "Q1 - 1.5 * IQR"
                if self.configs.whiskerMode == "std-dev"
                  topWhiskerLabel = "Mean + 1 Std Dev"
                  bottomWhiskerLabel = "Mean - 1 Std Dev"
                else if self.configs.whiskerMode == "max-min"
                  topWhiskerLabel = "Maximum"
                  bottomWhiskerLabel = "Minimum"
                if not @point.lowerOutliers
                  bottomWhiskerLabel = "Minimum"
                if not @point.upperOutliers
                  topWhiskerLabel = "Maximum"
                str  = "<div style='width:100%;text-align:center;"
                str += "color:#{@point.color};margin-bottom:5px'> "
                str += "#{@point.name}</div>"
                str += "<table>"
                str += "<tr><td>#{topWhiskerLabel}: <strong>#{@point.high}</strong></td></tr>"
                str += "<tr><td>Upper Quartile: <strong>#{@point.q3}</strong></td></tr>"
                str += "<tr><td>Median: <strong>#{@point.median}</strong></td></tr>"
                str += "<tr><td>Lower Quartile: <strong>#{@point.q1}</strong></td></tr>"
                str += "<tr><td>#{bottomWhiskerLabel}: <strong>#{@point.low}</strong></td></tr>"
                str += "</table>"
            useHTML: true
          legend:
            enabled: $(window).width() > 700 && data.groups.length < 30
          xAxis:
            labels:
              enabled: false
          yAxis:
            plotLines: plotLines


      update: ->
        super()

        dp = globals.getData(true, globals.configs.activeFilters)
        boxes = []
        index = 0
        allOutliers = []

        for groupIndex in data.groupSelection.sort()
          median = data.getMedian(@configs.displayField, groupIndex, dp)
          q1 = data.getQ1(@configs.displayField, groupIndex, dp)
          q3 = data.getQ3(@configs.displayField, groupIndex, dp)
          min = data.getMin(@configs.displayField, groupIndex, dp)
          max = data.getMax(@configs.displayField, groupIndex, dp)
          iqr = q3 - q1

          lowerBound = q1 - 1.5 * iqr
          upperBound = q3 + 1.5 * iqr

          if @configs.whiskerMode == "std-dev"
            stdDev = data.getStandardDeviation(@configs.displayField, groupIndex, dp)
            mean = data.getMean(@configs.displayField, groupIndex, dp)
            lowerBound = mean - stdDev
            upperBound = mean + stdDev
            
            if lowerBound > q1
              lowerBound = q1
            if upperBound < q3
              upperBound = q3

          else if @configs.whiskerMode == "max-min"
            lowerBound = min
            upperBound = max

          lowerOutliers = true
          upperOutliers = true
          if min >= lowerBound
            lowerBound = min
            lowerOutliers = false
          if max <= upperBound
            upperBound = max
            upperOutliers = false

          thisBox = {
            x: index
            low: lowerBound
            q1: q1
            median: median
            q3: q3
            high: upperBound
            color: globals.getColor(groupIndex)
            name: data.groups[groupIndex] or data.noField()
            lowerOutliers: lowerOutliers
            upperOutliers: upperOutliers
          }

          boxes.push(thisBox)
          outliers = []

          if lowerOutliers or upperOutliers
            for point in data.selector(@configs.displayField, groupIndex, dp)
              if point < lowerBound or point > upperBound
                outliers.push([index, point])
            allOutliers.push({gindex: groupIndex, points: outliers})
              
          index++

        gcolors = []
        groups = []
        for g, gi in data.groups when gi in data.groupSelection
          gcolors.push(globals.getColor(gi))
          groups.push(g)

        if(boxes.length > 0)
          pointWidth = null
          if boxes.length < 3
            pointWidth = 250 # limit the size of boxes when only a few a present

          boxSeries = {
            data: boxes
            type: "boxplot"
            showInLegend: false
            pointWidth: pointWidth
            lineWidth: 3
          }
          @chart.addSeries boxSeries, false

        for o in allOutliers
          outlierSeries = {
            name: data.groups[o.gindex] or data.noField()
            type: 'scatter'
            data: o.points
            color: globals.getColor(o.gindex)
            marker:
              symbol: "circle"
            showInLegend: false
            field: fieldTitle(data.fields[@configs.displayField])
            fieldUnit: fieldUnit(data.fields[@configs.displayField], false)
          }
          @chart.addSeries outlierSeries, false

        if @configs.meanLine
          # Update the mean line
          @chart.yAxis[0].removePlotLine("meanLine")
          mean = data.getMean(@configs.displayField, data.groupSelection, dp)
          @chart.yAxis[0].addPlotLine({
            color: 'red'
            width: 2
            value: mean
            zIndex: 10 # draw on top
            id: 'meanLine'
            label:
              text: 'Mean: ' + mean
              style:
                color: 'gray'
          })

        @chart.redraw()



      buildLegendSeries: ->
        for groupIndex in data.groupSelection.sort()
          options =
            # dummy series needs to be scatter, otherwise it pushes
            # the other boxes over.
            type: 'scatter'
            showInLegend: true
            color: globals.getColor(groupIndex)
            data: []
            name: data.groups[groupIndex] or data.noField()
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
          data.normalFields.slice(1), true, 'Fields',
          @configs.displayField, @yAxisRadioHandler)
        @drawToolControls()
        @drawClippingControls()
        @drawSaveControls()
        $('[data-toggle="tooltip"]').tooltip();

      drawToolControls: ->
        inctx = {}

        if data.hasTimeData and data.timeType != data.GEO_TIME
          inctx.period = HandlebarsTemplates[hbCtrl('period')]

        inctx.meanLine =
          id: 'mean-line'
          logId: 'draw-mean-line'
          label: 'Draw Line at Mean'

        inctx.horizontalBoxes =
          id: 'horizontal-boxes'
          logId: 'display-horizontal-boxes'
          label: 'Display Boxes Horizontally'

        outctx =
          id: 'tools-ctrls'
          title: 'Tools'
          body: HandlebarsTemplates[hbCtrl('box-tools')](inctx)

        tools = HandlebarsTemplates[hbCtrl('body')](outctx)
        $('#vis-ctrls').append tools

        # Add material design
        $('#vis-ctrls').find(".mdl-checkbox").each (i,j) ->
          componentHandler.upgradeElement($(j)[0]);

        $('#vis-ctrls').find(".mdl-radio").each (i,j) ->
          componentHandler.upgradeElement($(j)[0]);

        globals.configs.toolsOpen ?= false
        initCtrlPanel('tools-ctrls', 'toolsOpen')

        # Set the correct options for period:
        $('#period-list').val(globals.configs.periodMode)

        $('#period-list').change =>
          globals.configs.periodMode = $('#period-list').val()
          if $('#period-list').val() != 'off'
            globals.configs.isPeriod = true
          else
            globals.configs.isPeriod = false
          $( "#group-by" ).trigger( "change" )
          @start()

        # Set the correct option for whisker mode
        $("label[name='whisker'][value='#{@configs.whiskerMode}']")[0].MaterialRadio.check()

        $('input[name="whisker"]').click (e) =>
          @configs.whiskerMode = e.target.value
          @start()

        if @configs.meanLine then $('#ckbx-lbl-mean-line')[0].MaterialCheckbox.check()
        if @configs.horizontalBoxes then $('#ckbx-lbl-horizontal-boxes')[0].MaterialCheckbox.check()

        $('#ckbx-mean-line').click (e) =>
          @configs.meanLine = (@configs.meanLine + 1) % 2
          @start()
          true

        $('#ckbx-horizontal-boxes').click (e) =>
          @configs.horizontalBoxes = (@configs.horizontalBoxes + 1) % 2
          @start()
          true

    if "Box" in data.relVis
      globals.box = new Box 'box-canvas'
    else
      globals.box = new DisabledVis "box-canvas"
