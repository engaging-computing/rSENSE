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

    class window.Timeline extends Scatter
      ###
      Constructor
      Change default mode to lines only
      ###
      constructor: (@canvas) ->
        super @canvas

        @mode = @LINES_MODE
        @xAxis = data.timeFields[0]
        
        if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]

      ###
      Build options relevant to timeline
      ###
      buildOptions: ->
        super()

        self = this

        $.extend true, @chartOptions,
          title:
            text: ''
          tooltip:
            formatter: ->
              if @series.name.regression?
                str  = @series.name.regression.tooltip
              else
                if self.advancedTooltips
                  str  = "<div style='width:100%;text-align:center;color:#{@series.color};'>"
                  str += "#{@series.name.group}</div><br>"
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
                  str  = "<div style='width:100%;text-align:center;color:#{@series.color};'> "
                  str += "#{@series.name.group}</div><br>"
                  str += "<table>"
                  str += "<tr><td>#{@series.xAxis.options.title.text}:</td><td><strong> "
                  str += "#{globals.dateFormatter @x}</strong></td></tr>"
                  str += "<tr><td>#{@series.name.field}:</td><td><strong>#{@y}</strong></td></tr>"
                  str += "</table>"
            useHTML: true

        @chartOptions.xAxis =
          if data.timeType is data.NORM_TIME
            type: 'datetime'
          else #elif data.timeType is data.GEO_TIME
            labels:
              formatter: ->
                globals.geoDateFormatter @value

      ###
      Adds the regression tools to the control bar.
      ###
      drawRegressionControls: () ->
        super()
        #For now we are supporting only linear and quadratic on timelines
        for child, index in ($ "#regressionSelector").children() when index >= 2
          child.remove()

      ###
      Overwrite xAxis controls to only allow time fields
      ###
      drawXAxisControls: ->
        super (fieldIndex) -> fieldIndex in data.timeFields
        
      ###
      Clips an array of data to include only bounded points
      ###
      clip: (arr) ->
        super(arr)

    if "Timeline" in data.relVis
      globals.timeline = new Timeline 'timeline_canvas'
    else
      globals.timeline = new DisabledVis "timeline_canvas"
