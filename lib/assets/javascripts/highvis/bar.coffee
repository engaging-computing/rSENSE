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
    autoSorted = 0
    
    class window.Bar extends BaseHighVis
      constructor: (@canvas) ->
        if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]
        
      ANALYSISTYPE_TOTAL:     0
      ANALYSISTYPE_MAX:       1
      ANALYSISTYPE_MIN:       2
      ANALYSISTYPE_MEAN:      3
      ANALYSISTYPE_MEDIAN:    4
      ANALYSISTYPE_COUNT:     5

      analysisTypeNames: ["Total","Max","Min","Mean","Median","Row Count"]

      analysisType:   0
      sortField:      null

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
              str += "<tr><td>#{@x} (#{self.analysisTypeNames[self.analysisType]}):"
              str += "</td><td><strong>#{@y}</strong></td></tr>"
              str += "</table>"
            useHTML: true
          yAxis:
            type: if globals.logY is 1 then 'logarithmic' else 'linear'

      update: ->
        super()
        visibleCategories = for selection in data.normalFields when selection in globals.fieldSelection
          fieldTitle data.fields[selection]
          
        # Restrict analysis type to only row count if the y field is "Data Point"
        if (globals.fieldSelection[0] is data.DATA_POINT_ID_FIELD and globals.fieldSelection.length is 1)
          for option, row in ($ '#analysis_types').children()
            if row isnt @ANALYSISTYPE_COUNT
              $(option).hide()
            else
              $(option).find('> > >').prop("checked", true)
          @analysisType = @ANALYSISTYPE_COUNT
        else ($ '#analysis_types').children().show()

        @chart.xAxis[0].setCategories visibleCategories, false
        @chart.yAxis[0].sort
        while @chart.series.length > data.normalFields.length
          @chart.series[@chart.series.length - 1].remove false

        ### --- ###
        tempGroupIDValuePairs = for groupName, groupIndex in data.groups when groupIndex in globals.groupSelection
          switch @analysisType
            when @ANALYSISTYPE_TOTAL    then [groupIndex, (data.getTotal     @sortField, groupIndex)]
            when @ANALYSISTYPE_MAX      then [groupIndex, (data.getMax       @sortField, groupIndex)]
            when @ANALYSISTYPE_MIN      then [groupIndex, (data.getMin       @sortField, groupIndex)]
            when @ANALYSISTYPE_MEAN     then [groupIndex, (data.getMean      @sortField, groupIndex)]
            when @ANALYSISTYPE_MEDIAN   then [groupIndex, (data.getMedian    @sortField, groupIndex)]
            when @ANALYSISTYPE_COUNT    then [groupIndex, (data.getCount     @sortField, groupIndex)]
        sorter = 0
        if !autoSorted
          temp = 0
          ($ '#ui-accordion-yAxisControl-panel-0').find($ '.inner_control_div').find('.y_axis_input').each (i,j) ->
            if (($ j).is(':checked') and temp == 0) #and temp  #.find('checkbox').is(':checked')
              temp = 1
              sorter = ($ j).attr('value')
              @sortField = ($ j).attr('value')
          if !autoSorted
            ($ '#ui-accordion-toolControl-panel-0').find('.inner_control_div').find('option').each (i,j) ->
              ($ j).removeAttr('selected')
            ($ '#ui-accordion-toolControl-panel-0').find('.inner_control_div').find('option').each (i,j) ->
              if ($ j).attr('value') == sorter
                ($ j).attr('selected',true)
            if( !autoSorted )
              autoSorted = 1
              ($ '.sortField').change()
        
        if @sortField != null
          fieldSortedGroupIDValuePairs = tempGroupIDValuePairs.sort (a,b) ->
            a[ 1] - b[1]

          fieldSortedGroupIDs = for [groupID, groupValue] in fieldSortedGroupIDValuePairs
            groupID
        else
          fieldSortedGroupIDs = for groupName, groupID in data.groups
            groupID
        ### --- ###

        for groupIndex, order in fieldSortedGroupIDs when groupIndex in globals.groupSelection

          options =
            showInLegend: false
            color: globals.colors[groupIndex % globals.colors.length]
            name: data.groups[groupIndex]
            index: order

          options.data = for fieldIndex in data.normalFields when fieldIndex in globals.fieldSelection
            switch @analysisType
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
          fieldIndex in data.normalFields and fieldIndex in globals.fieldSelection)

          count += 1
          dummy =
            legendIndex: fieldIndex
            data: []
            color: '#000'
            name: fieldTitle field
            type: 'area'
            xAxis: 1

      drawToolControls: ->

        controls =  '<div id="toolControl" class="vis_controls">'

        controls += "<h3 class='clean_shrink'><a href='#'>Tools:</a></h3>"
        controls += "<div class='outer_control_div'>"

        controls += "<div class='inner_control_div'>"
        controls += 'Sort by: <select class="sortField form-control">'

        tempFields = for fieldID in data.normalFields
          [fieldID, data.fields[fieldID].fieldName]

        tempFields = [].concat [[null, 'Group Name']], tempFields

        for [fieldID, fieldName] in tempFields
          selected = if @sortField is fieldID then 'selected' else ''
          controls += "<option value='#{fieldID}' #{selected}>#{fieldName}</option>"

        controls += '</select></div><br>'

        controls += "<h4 class='clean_shrink'>Analysis Type</h4><div id='analysis_types'>"

        for typestring, type in @analysisTypeNames

          controls += "<div class='inner_control_div'>"

          controls += "<div class='radio'><label><input type='radio' class='analysisType' "
          controls += "name='analysisTypeSelector' value='"
          controls += "#{type}' #{if type is @analysisType then 'checked' else ''}> "
          controls += "#{typestring} </label></div>"

          controls += '</div>'

        controls += "</div><h4 class='clean_shrink'>Other</h4>"

        if data.logSafe is 1
          controls += '<div class="inner_control_div">'
          controls += "<div class='checkbox'><label><input class='logY_box' type='checkbox' "
          controls += "name='tooltip_selector' #{if globals.logY is 1 then 'checked' else ''}/> "
          controls += "Logarithmic Y Axis</label></div>"
          controls += "</div>"

        controls += '</div></div>'

        ### --- ###
        # Write HTML
        ($ '#controldiv').append controls

        ($ '.analysisType').change (e) =>
          @analysisType = Number e.target.value
          temp = 0
          ($ '#ui-accordion-yAxisControl-panel-0').find($ '.inner_control_div').find('.y_axis_input').each (i,j) ->
            if (($ j).is(':checked') and !temp ) #.find('checkbox').is(':checked')
              temp = 1
              sorter = ($ j).attr('value')
              @sortField = ($ j).attr('value')
          @delayedUpdate()
        
        ($ '.sortField').change (e) =>
          @sortField = Number e.target.value
          @delayedUpdate()
        ($ '.logY_box').click (e) =>
          globals.logY = (globals.logY + 1) % 2
          @start()
        
        sorter = 0
        ($ '#ui-accordion-yAxisControl-panel-0').find($ '.inner_control_div').find($ '.y_axis_input').click (e) =>
          temp = 0
          count = 0
          ($ '#ui-accordion-yAxisControl-panel-0').find($ '.inner_control_div').find('.y_axis_input').each (i,j) ->
            if (($ j).is(':checked') and temp == 0 ) #and temp  #.find('checkbox').is(':checked')
              temp = 1
              count += 1
              sorter = ($ j).attr('value')
          if count == 1
            autoSorted = 0
          @sortField = sorter
        ($ '#ui-accordion-toolControl-panel-0').find('.inner_control_div').find('.sortField:option').each (i,j) ->
          ($ j).removeAttr('selected')
        ($ '#ui-accordion-toolControl-panel-0').find('.inner_control_div').find('.sortField:option').each (i,j) ->
          if ($ j).attr('value') == sorter
            ($ j).attr('selected',true)
            if( !autoSorted )
              autoSorted = 1
              ($ '.sortField').change()
            
        # Set up accordion
        globals.toolsOpen ?= 0

        ($ '#toolControl').accordion
          collapsible:true
          active:globals.toolsOpen

        ($ '#toolControl > h3').click ->
          globals.toolsOpen = (globals.toolsOpen + 1) % 2
          
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
