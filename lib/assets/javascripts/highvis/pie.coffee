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

        @selected_field = 3

      start: () ->
        super()
        
      update: () ->
        @rel_data = []
        @selected_field = @displayField

        for dp in data.dataPoints
          do =>
            @rel_data.push dp[@selected_field]

        sum = @rel_data.reduce (x, y) -> x + y

        if (sum > 95 and sum <= 100) or (sum > .95 and sum <= 1)
          @use_value = true
        else
          @use_value = false

        while @chart.series.length > 0
          @chart.series[@chart.series.length - 1].remove false

        if data.textFields.length > 2
          @select_name = data.textFields[2]
        else
          @select_name = 'Percent'
          
        console.log @select_name

        if @use_value is true
          @display_data = []

          row_index = 0

          for dp in @rel_data
            do =>
              if @select_name != 'Percent'
                @display_data.push [data.dataPoints[row_index][@select_name], dp]
                row_index++

        else
          @display_data = []
          #select name could be group by
          @display_data.push [data.dataPoints[0][@select_name], 1]

          for dp in data.dataPoints[1..]
            do =>
              if dp[@select_name] in @display_data
                for find_name in @display_data
                  do =>
                    if find_name[0] = dp[@select_name]
                      find_name[1] += 1
              else
                @display_data.push [dp[@select_name], 1]

          @normalize()

        options =
          showInLegend: false
          data: @display_data

        @chart.addSeries options, false
        @chart.redraw()

      normalize: ->
        sum = 0

        for dp in @display_data
          do =>
            sum += dp[1]

        for dp in @display_data
          do =>
            dp[1] = ( dp[1] / sum ) *100

      buildOptions: ->
        super()

        self = this
        @chartOptions

        $.extend true, @chartOptions,
          chart:
            type: "pie"
          title:
            text: "#{data.fields[@selected_field].fieldName}"
          tooltip:
            pointFormat: '{point.name}: <b>{point.percentage:.1f}%</b>'
          plotOptions:
            pie:
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                enabled: true
                format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                style:
                  color: 'black'
          series: [{
            type: 'pie'
            data: 
              [['Firefox', 50], ['Other', 50]]
            }]

      drawLabelControls: ->
        controls = '<div id="labelControl" class="vis_controls">'
        controls += "<h3 class='clean_shrink'><a href='#'>Label:</a></h3>"
        controls += "<div class='outer_control_div'>"


      drawControls: ->
        super()
        @drawYAxisControls true #horrible name for what im doing here
        @drawLabelControl()


    if "Pie" in data.relVis
      globals.pie = new Pie 'pie_canvas'
    else
      globals.pie = new DisabledVis 'pie_canvas'
