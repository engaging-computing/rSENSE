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

    class window.Bar extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)

      start: ->
        @configs.analysisType ?= @ANALYSISTYPE_TOTAL

        # Default Sort
        fs = globals.configs.fieldSelection
        @configs.sortField ?= if fs? then fs[0] else @SORT_DEFAULT

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
          tooltip:
            formatter: ->
              str  = "<div style='width:100%;text-align:center;"
              str += "color:#{@series.color};margin-bottom:5px'> "
              str += "#{@series.name}</div>"
              str += "<table>"
              str += "<tr><td>#{data.fields[globals.configs.fieldSelection[@x]].fieldName} "
              str += "(#{self.analysisTypeNames[self.configs.analysisType]}):"
              str += "</td><td><strong>#{@y} \
              #{fieldUnit(data.fields[globals.configs.fieldSelection[@x]], false)}</strong></td></tr>"
              str += "</table>"
            useHTML: true
          yAxis:
            type: if globals.configs.logY is 1 then 'logarithmic' else 'linear'
          xAxis:
            type: 'category'

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

        # Draw the series
        for gid in sortedGroupIDs when gid in data.groupSelection
          options =
            color: globals.configs.colors[gid % globals.configs.colors.length]
            name:  data.groups[gid] or data.noField()

          options.data = for fid in data.normalFields when fid in fieldSelection
            [fieldTitle(data.fields[fid]), groupedData[fid][gid]]

          @chart.addSeries options, false
        @chart.redraw()

      buildLegendSeries: ->
        []

      drawControls: ->
        super()
        @drawGroupControls()
        @drawYAxisControls()
        @drawToolControls(true, true)
        @drawSaveControls()

    if "Bar" in data.relVis
      globals.bar = new Bar 'bar_canvas'
    else
      globals.bar = new DisabledVis "bar_canvas"
