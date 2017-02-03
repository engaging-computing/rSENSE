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

    class window.Pie extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)

        @configs.selectName ?=
          if data.textFields.length > 2 then data.textFields[2]
          else 'Percent'

      start: () ->
        @configs.displayField = Math.min globals.configs.fieldSelection...
        @configs.analysisType ?= @ANALYSISTYPE_TOTAL
        super()

      update: () ->
        super()

        @configs.selectName = data.fields[globals.configs.groupById].fieldName

        if globals.configs.groupById == 3
          groupedData = @getFieldData(@configs.displayField)
        else
          groupedData = @getGroupedData(@configs.displayField)

        displayData = for gid, val of groupedData
          ret =
            y: if val < 0 then 0 else val            # for calculations
            val: val                                 # for display
            name: data.groups[gid] or data.noField()

        # Sort array in ascending order so that the colors on the Pie Chart show up in the correct order.
        data.groupSelection = data.groupSelection.sort (a, b) ->
          return a - b;

        displayColors = []
        for number in data.groupSelection
          displayColors.push(globals.getColor(number))

        options =
          data: displayData
          colors: displayColors
        if globals.configs.groupById == data.NUMBER_FIELDS_FIELD
          @chart.setTitle { text: "#{@configs.selectName}" }
        else
          @chart.setTitle { text: "#{data.fields[@configs.displayField].fieldName} grouped by #{@configs.selectName}" }
        @chart.addSeries options, false

        @chart.redraw()

      buildLegendSeries: ->
        []

      buildOptions: (animate = true) ->
        super(animate)

        self = this
        @chartOptions

        $.extend true, @chartOptions,
          chart:
            type: "pie"
          tooltip:
            formatter: ->
              str  = "<div style='width:100%;text-align:center;color:#{@series.color};"
              str += "margin-bottom:5px'> #{@point.name}</div>"
              str += "<table>"
              if globals.configs.groupById == data.NUMBER_FIELDS_FIELD
                str += "<tr><td>#{self.analysisTypeNames[self.configs.analysisType]}: "
              else
                str += "<tr><td>#{data.fields[self.configs.displayField].fieldName}
                   (#{self.analysisTypeNames[self.configs.analysisType]}): "
              str += "</td><td><strong>#{@point.val} \
              #{fieldUnit(data.fields[self.configs.displayField], false)}</strong></td></tr>"
              str += "</table>"
            useHTML: true
          plotOptions:
            pie:
              showInLegend: ($(window).width() < 1000 && data.groups.length < 30) && !($(window).width() < 400)
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                floating: false
                enabled: ($(window).width() >= 1000)
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'

      drawControls: ->
        super()
        groups = $.extend(true, [], data.textFields)
        # Remove Group By Time Period if there is no time data
        if data.hasTimeData is false or data.timeType == data.GEO_TIME
          groups.splice(data.TIME_PERIOD_FIELD - 1, 1)
        @drawGroupControls(groups)
        if globals.configs.groupById != data.NUMBER_FIELDS_FIELD
          @drawYAxisControls(globals.configs.fieldSelection,
            data.normalFields.slice(1), true, 'Fields', @configs.displayField,
            @yAxisRadioHandler)
        # If there are no number fields, then restrict pie chart to just row count analysis
        analysisTypeExcludes = [@ANALYSISTYPE_TOTAL, @ANALYSISTYPE_MAX, @ANALYSISTYPE_MIN,
          @ANALYSISTYPE_MEAN, @ANALYSISTYPE_MEAN_ERROR, @ANALYSISTYPE_MEDIAN]
        @configs.analysisType = @ANALYSISTYPE_COUNT
        for field in data.fields
          if field.typeID == data.types.NUMBER && field.fieldID != -1 # if one of the fields is userdefined and numeric
            analysisTypeExcludes = [@ANALYSISTYPE_MEAN_ERROR]
            @configs.analysisType = @ANALYSISTYPE_TOTAL
            break
        @drawToolControls(false, false, analysisTypeExcludes)
        @drawClippingControls()
        @drawSaveControls()
        $('[data-toggle="tooltip"]').tooltip();

    if "Pie" in data.relVis
      globals.pie = new Pie 'pie-canvas'
    else
      globals.pie = new DisabledVis 'pie-canvas'
      
