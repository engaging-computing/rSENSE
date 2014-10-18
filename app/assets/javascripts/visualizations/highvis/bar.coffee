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

    class window.Bar extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)

        if data.normalFields.length > 1
          @configs.displayField = data.normalFields[1]
        else @configs.displayField = data.normalFields[0]

      # Used to restore previous analysis type (when user switches to data point
      # the analysis gets force set to row count, and this should be undone).
      restoreAnalysisType:  false
      savedAnalysisType:    0

      start: ->
        @configs.analysisType ?= @ANALYSISTYPE_TOTAL
        super()

      buildOptions: ->
        super()

        self = this

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: "column"
          title:
            text: ""
          legend:
            enabled: false
          tooltip:
            formatter: ->
              str  = "<div style='width:100%;text-align:center;color:#{@series.color};"
              str += "margin-bottom:5px'> #{@point.name}</div>"
              str += "<table>"
              str += "<tr><td>#{@x} (#{self.analysisTypeNames[self.configs.analysisType]}):"
              str += "</td><td><strong>#{@y}</strong></td></tr>"
              str += "</table>"
            useHTML: true
          yAxis:
            type: if globals.configs.logY is 1 then 'logarithmic' else 'linear'

      update: ->
        super()

        # Default Sort
        @configs.sortField ?=
          if globals.configs.fieldSelection?
            globals.configs.fieldSelection[0]
          else @SORT_DEFAULT

        # Restrict analysis type to only row count if the y field is "Data Point"
        if (globals.configs.fieldSelection[0] is data.DATA_POINT_ID_FIELD and
        globals.configs.fieldSelection.length is 1)
          for option, row in ($ '#analysis_types').children()
            if row isnt @ANALYSISTYPE_COUNT then $(option).hide()

          @savedAnalysisType = @configs.analysisType
          @restoreAnalysisType = true
          @configs.analysisType = @ANALYSISTYPE_COUNT
        else
          if @restoreAnalysisType
            @configs.analysisType = @savedAnalysisType
            @restoreAnalysisType = false
          ($ '#analysis_types').children().show()

        $('#sortField option[value=' + @configs.sortField + ']').prop('selected', true)
        $('input:radio[name=analysisTypeSelector][value=' + @configs.analysisType + ']').prop('checked', true)

        visibleCategories = for selection in data.normalFields when selection in globals.configs.fieldSelection
          fieldTitle data.fields[selection]

        @chart.xAxis[0].setCategories visibleCategories, false
        @chart.yAxis[0].sort
        while @chart.series.length > data.normalFields.length
          @chart.series[@chart.series.length - 1].remove false

        ### --- ###
        tempGroupIDValuePairs = @getGroupedData()
        
        if @configs.sortField != @SORT_DEFAULT
          fieldSortedGroupIDValuePairs = tempGroupIDValuePairs.sort (a,b) ->
            a[1] - b[1]

          fieldSortedGroupIDs = for [groupID, groupValue] in fieldSortedGroupIDValuePairs
            groupID
        else
          fieldSortedGroupIDs = for groupName, groupID in data.groups
            groupID
        ### --- ###

        for groupIndex, order in fieldSortedGroupIDs when groupIndex in data.groupSelection

          options =
            showInLegend: false
            color: globals.configs.colors[groupIndex % globals.configs.colors.length]
            name: data.groups[groupIndex]
            index: order

          options.data = for fieldIndex in data.normalFields when fieldIndex in globals.configs.fieldSelection
            switch @configs.analysisType
              when @ANALYSISTYPE_TOTAL
                ret =
                  y:      data.getTotal fieldIndex, groupIndex
                  name:   data.groups[groupIndex]

              when @ANALYSISTYPE_MAX
                ret =
                  y:      data.getMax fieldIndex, groupIndex
                  name:   data.groups[groupIndex]
              when @ANALYSISTYPE_MIN
                ret =
                  y:      data.getMin fieldIndex, groupIndex
                  name:   data.groups[groupIndex]
              when @ANALYSISTYPE_MEAN
                ret =
                  y:      data.getMean fieldIndex, groupIndex
                  name:   data.groups[groupIndex]
              when @ANALYSISTYPE_MEDIAN
                ret =
                  y:      data.getMedian fieldIndex, groupIndex
                  name:   data.groups[groupIndex]
              when @ANALYSISTYPE_COUNT
                ret =
                  y:      data.getCount fieldIndex, groupIndex
                  name:   data.groups[groupIndex]

          @chart.addSeries options, false
        @chart.redraw()

      buildLegendSeries: ->
        count = -1
        for field, fieldIndex in data.fields when (
          fieldIndex in data.normalFields and fieldIndex in globals.configs.fieldSelection)

          count += 1
          dummy =
            legendIndex: fieldIndex
            data: []
            color: '#000'
            name: fieldTitle field
            type: 'area'
            xAxis: 1

      
      drawYAxisControls: ->
        super()

      drawControls: ->
        super()
        @drawGroupControls()
        @drawYAxisControls()
        @drawToolControls()
        @drawSaveControls()


    if "Bar" in data.relVis
      globals.bar = new Bar 'bar_canvas'
    else
      globals.bar = new DisabledVis "bar_canvas"
