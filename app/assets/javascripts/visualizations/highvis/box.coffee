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

      start: ->
        @configs.displayField = Math.min globals.configs.fieldSelection...
        super()

      buildOptions: (animate = true) ->
        super(animate)

        groups = []
        for g, gi in data.groups when gi in data.groupSelection
          groups.push(g)

        self = this

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: "boxplot"
          title:
            text: ""
          legend:
            enabled: false
          xAxis:
            categories: groups


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
          iqr = q3 - q1

          lowerBound = q1 - 1.5 * iqr
          upperBound = q3 + 1.5 * iqr

          min = data.getMin(@configs.displayField, groupIndex, dp)
          max = data.getMax(@configs.displayField, groupIndex, dp)

          lowerOutliers = true
          upperOutliers = true
          if min >= lowerBound
            lowerBound = min
            lowerOutliers = false
          if max <= upperBound
            upperBound = max
            upperOutliers = false

          boxes.push([lowerBound, q1, median, q3, upperBound])
          outliers = []

          if lowerOutliers or upperOutliers
            for point in data.selector(@configs.displayField, groupIndex, dp)
              if point < lowerBound or point > upperBound
                outliers.push([index + 0.15, point])
            allOutliers.push({gindex: groupIndex, points: outliers})
              
          index++

        gcolors = []
        groups = []
        for g, gi in data.groups when gi in data.groupSelection
          gcolors.push(globals.getColor(gi))
          groups.push(g)

        boxSeries = {
          data: boxes
          colorByPoint: true
          colors: gcolors
        }
        @chart.addSeries boxSeries, false

        for o in allOutliers
          outlierSeries = {
            type: 'scatter'
            data: o.points
            color: globals.getColor(o.gindex)
            marker:
              symbol: "circle"
          }
          @chart.addSeries outlierSeries, false

        @chart.xAxis[0].setCategories(groups, false)
        @chart.redraw()



      buildLegendSeries: ->
        count = -1
        for f, i in data.fields when i in data.normalFields
          count += 1
          dummy =
            data: []
            color: '#000'
            visible: @configs.displayField is i
            name: f.fieldName
            # xAxis: 1
            legendIndex: i

        
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
        #@drawToolControls()
        @drawClippingControls()
        @drawSaveControls()
        $('[data-toggle="tooltip"]').tooltip();
        

    if "Box" in data.relVis
      globals.box = new Box 'box-canvas'
    else
      globals.box = new DisabledVis "box-canvas"
