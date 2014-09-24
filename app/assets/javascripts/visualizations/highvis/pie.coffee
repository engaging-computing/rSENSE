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

    class window.Pie extends BaseHighVis
      constructor: (@canvas) ->
        if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]

        @selectName ?=
          if data.textFields.length > 2
            data.textFields[2]
          else
            'Percent'

      start: () ->
        super()

      update: () ->
        @selectName = data.fields[data.groupingFieldIndex].fieldName
        @getGroupedData()
        while @chart.series.length > 0
          @chart.series[@chart.series.length - 1].remove false

        @displayColors = []
        for number in globals.groupSelection
          @displayColors.push(globals.colors[number])
        options =
          showInLegend: false
          data: @displayData
          colors: @displayColors
        @chart.setTitle { text: "#{@selectName} by #{data.fields[@displayField].fieldName}" }
        @chart.addSeries options, false

        @chart.redraw()

      getGroupedData: ->
        @displayData = data.dataPoints.reduce (prev, next) =>
          if typeof prev[next[data.groupingFieldIndex]] != "undefined"
            prev[next[data.groupingFieldIndex]] = prev[next[data.groupingFieldIndex]] + next[@displayField]
          else
            prev[next[data.groupingFieldIndex]] = next[@displayField]
          prev
        , {}
        @displayData = Object.keys(@displayData).reduce (prev, key) =>
          if data.groups.indexOf(key.toLowerCase()) in globals.groupSelection
            prev.push [key or "No #{@selectName}", @displayData[key]]
          prev
        , []

      buildOptions: ->
        super()

        self = this
        @chartOptions

        $.extend true, @chartOptions,
          chart:
            type: "pie"
          tooltip:
            pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
          plotOptions:
            pie:
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                enabled: true
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'

      drawControls: ->
        super()
        @drawGroupControls false, false, false
        @drawYAxisControls true, false # Naming here is less than ideal
        @drawSaveControls()

    if "Pie" in data.relVis
      globals.pie = new Pie 'pie_canvas'
    else
      globals.pie = new DisabledVis 'pie_canvas'
