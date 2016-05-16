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

    class window.Histogram extends BaseHighVis
      constructor: (@canvas) ->
        super(@canvas)

      MAX_NUM_BINS:        1000
      binNumSug:              1

      # Wait for global objects to be constructed before getting bin size
      updatedTooltips:    false

      start: ->
        @configs.displayField = Math.min globals.configs.fieldSelection...
        @configs.binSize ?= @defaultBinSize()
        super()

      buildOptions: (animate = true) ->
        super(animate)

        self = this

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: 'column'
          legend:
            enabled: false
          title:
            text: ''
          tooltip:
            formatter: ->
              str  = "<table>"
              xField = @series.xAxis.options.title.text
              idx = data.fields.map((x) -> fieldTitle(x)).indexOf(xField)
              str += "<tr><td>#{xField}:</td> <td>#{@point.realValue}</td></tr>"
              str += "<tr><td>Bin:</td><td>#{@x}</td></tr>"
              str += "<tr><td># Occurrences:</td><td>#{@total}<td></tr>"
              if @y isnt 0
                str += "<tr><td><div style='color:#{@series.color};'> #{@series.name}:</div></td>"
                str += "<td>#{@y}</td></tr>"
              str += "</table>"
            useHTML: true
          plotOptions:
            column:
              stacking: 'normal'
              groupPadding: 0
              pointPadding: 0
            series:
              events:
                legendItemClick: (event) ->
                  false
          xAxis: [
            {alignTicks: false},
            lineWidth: 0
            categories: ['']
          ]

      ###
      Returns a rough default 'human-like' bin size selection
      ###
      defaultBinSize: ->
        min = Number.MAX_VALUE
        max = Number.MIN_VALUE

        dp = globals.getData(true, globals.configs.activeFilters)

        for groupIndex in data.groupSelection
          localMin = data.getMin(@configs.displayField, groupIndex, dp)
          if localMin?
            min = Math.min(min, localMin)

          localMax = data.getMax(@configs.displayField, groupIndex, dp)
          if localMax?
            max = Math.max(max, localMax)

        range = max - min

        # No data
        if max < min
          return 1

        curSize = 1
        bestSize = curSize
        bestNum  = range / curSize
        binNumTarget = Math.pow(10, @binNumSug)

        tryNewSize = (size) ->
          target = Math.abs(binNumTarget - (range / size))
          if target >= Math.abs(binNumTarget - bestNum)
            return false

          bestSize = size
          bestNum  = range / size
          return true

        loop
          if (range / curSize) < binNumTarget
            curSize /= 10
          else if (range / curSize) > binNumTarget
            curSize *= 10

          break if not tryNewSize(curSize)

        tryNewSize(curSize / 2)
        tryNewSize(curSize * 2)
        tryNewSize(curSize / 5)
        tryNewSize(curSize * 5)
        return bestSize

      update: ->
        super()
        # Name Axis
        @chart.yAxis[0].setTitle({text: "Quantity"}, false)
        @chart.xAxis[0].setTitle(
          {text: fieldTitle(data.fields[@configs.displayField])}, false)
        if data.groupSelection.length is 0 then return

        while @chart.series.length > data.normalFields.length
          @chart.series[@chart.series.length - 1].remove false

        @globalmin = Number.MAX_VALUE
        @globalmax = Number.MIN_VALUE

        dp = globals.getData(true, globals.configs.activeFilters)

        for groupIndex in data.groupSelection
          min = data.getMin(@configs.displayField, groupIndex, dp)
          min = Math.round(min / @configs.binSize) * @configs.binSize
          @globalmin = Math.min(@globalmin, min)

          max = data.getMax(@configs.displayField, groupIndex, dp)
          max = Math.round(max / @configs.binSize) * @configs.binSize
          @globalmax = Math.max(@globalmax, max)

        # Make 'fake' data to ensure proper bar spacing
        fakeDat = for i in [@globalmin...@globalmax] by @configs.binSize
          [i, 0]

        options =
          showInLegend: false
          data: fakeDat

        @chart.addSeries options, false

        # Generate all bin data
        binObjs = {}
        binMesh = {}
        dp = globals.getData(true, globals.configs.activeFilters)
        for groupIndex in data.groupSelection
          selectedData = data.selector(@configs.displayField, groupIndex, dp)

          binArr = for i in selectedData
            x = Math.round(i / @configs.binSize) * @configs.binSize
            unless binMesh[x]?
              binMesh[x] = []
            binMesh[x].push i
            x

          binObjs[groupIndex] = {}

          for bin in binArr
            binObjs[groupIndex][bin] ?= 0
            binObjs[groupIndex][bin]++

        # Convert bin data into series data
        i = 0
        binSizes = {}
        binTotals = {}

        (key for key of binObjs).map((y) -> ({x: Number(val), y: binObjs[y][val]} for val of binObjs[y])).map (a) ->
          a.map (b) ->
            binSizes[b['x']] ?= 0
            binSizes[b['x']] = Math.max(binSizes[b['x']], b['y'])
            binTotals[b['x']] ?= 0
            binTotals[b['x']] += b['y']
        max = (pv, cv, index, array) -> Math.max(pv, cv)
        min = (pv, cv, index, array) -> Math.min(pv, cv)
        largestBin = (binTotals[key] for key of binTotals).reduce max, 0
        smallestBin = (binTotals[key] for key of binTotals).reduce min, 0
        maxValueAnyGroupAnyBin = (binSizes[key] for key of binSizes).reduce max, 0

        if largestBin < 100 and maxValueAnyGroupAnyBin < 50
          for group of binObjs
            maxValueOneGroupAnyBin = \
            (binObjs[group][key] for key of binObjs[group]).reduce max, 0
            while i < maxValueOneGroupAnyBin
              binData = []
              for bin of binObjs[group]
                if binObjs[group][bin] > i
                  x = binMesh[bin].pop()
                  binData.push
                    x: Number(bin)
                    y: 1
                    total: binObjs[group][bin]
                    realValue: x
              binData.sort (a, b) -> Number(a['x']) - Number(b['x'])
              options =
                showInLegend: false
                color: globals.getColor(Number(group))
                name: data.groups[Number(group)]
                data: binData
              @chart.addSeries options, false
              i += 1
            i = 0
        else
          for groupIndex in data.groupSelection
            finalData = for number, occurences of binObjs[groupIndex]
              sum = 0

              # Get total for this bin
              for dc, groupData of binObjs
                if groupData[number]
                  sum += groupData[number]

              ret =
                x: (Number number)
                y: occurences
                total: sum

            options =
              showInLegend: false
              color: globals.getColor(groupIndex)
              name: data.groups[groupIndex]
              data: finalData

            @chart.addSeries options, false

        half = @configs.binSize / 2
        @chart.xAxis[0].setExtremes(@globalmin - half, @globalmax + half, true)

      buildLegendSeries: ->
        count = -1
        for f, i in data.fields when i in data.normalFields
          count += 1
          dummy =
            data: []
            color: '#000'
            visible: @configs.displayField is i
            name: f.fieldName
            xAxis: 1
            legendIndex: i

      drawToolControls: ->
        inctx =
          binSize: @configs.binSize
          
        if data.timeFields.length > 0 and data.timeType != data.GEO_TIME
          inctx.period = HandlebarsTemplates[hbCtrl('period')]
        else
          # Safeguard, in case the default vis has time data but the current dataset does not.
          globals.configs.isPeriod = false
          globals.configs.periodMode = 'off'

        outctx =
          id: 'tools-ctrls'
          title: 'Tools'
          body: HandlebarsTemplates[hbCtrl('histogram-tools')](inctx)

        tools = HandlebarsTemplates[hbCtrl('body')](outctx)
        $('#vis-ctrls').append(tools)
        
        # Set the correct options for period:
        if data.timeFields.length > 0 and data.timeType != data.GEO_TIME
          $('#period-list').val(globals.configs.periodMode)

        $('#period-list').change =>
          globals.configs.periodMode = $('#period-list').val()
          if $('#period-list').val() != 'off'
            globals.configs.isPeriod = true
          else
            globals.configs.isPeriod = false
          $( "#group-by" ).trigger( "change" )
          @start()

        # Adds material design
        $('#vis-ctrls').find(".mdl-checkbox").each (i,j) ->
          componentHandler.upgradeElement($(j)[0])

        $('#vis-ctrls').find(".mdl-radio").each (i,j) ->
          componentHandler.upgradeElement($(j)[0])

        # Initialize and track the status of this control panel
        globals.configs.toolsOpen ?= false
        initCtrlPanel('tools-ctrls', 'toolsOpen')

        # Set up slider
        init =
          value: @configs.binSize
          min: .5
          max: 2.2
          step: .1
        $('#bin-size-slider').attr(init)
        $('#bin-size-slider').on 'input change', (e) =>
          @binNumSug = 2.7 - Number(e.target.value)
          newBinSize = @defaultBinSize()
          unless fpEq(newBinSize, @configs.binSize)
            @configs.binSize = newBinSize
            $('#bin-size').val(@configs.binSize)
            @delayedUpdate()

        # Bin Size Box
        badNumberPopoverTimer = null
        $('#set-bin-size-btn').click =>
          $('#bin-size').popover('destroy')
          newBinSize = Number($('#bin-size').val())
          if isNaN(newBinSize) or newBinSize <= 0
            $('#bin-size').popover
              content: 'Please enter a valid number'
              placement: 'bottom'
              trigger: 'manual'
            $('#bin-size').popover('show')
            if badNumberPopoverTimer? then clearTimeout(badNumberPopoverTimer)
            badNumberPopoverTimer = setTimeout ->
              $('#bin-size').popover('destroy')
            , 3000
            return

          if ((@globalmax - @globalmin) / newBinSize) < @MAX_NUM_BINS
            @configs.binSize = newBinSize
            @update()
          else
            alert('Entered bin size would result in too many bins.')

        # Adds Material Design to slider
        $('#vis-ctrls').find(".mdl-slider").each (i,j) ->
          componentHandler.upgradeElement($(j)[0])

      drawControls: ->
        super()
        # Remove group by number fields, only for pie chart
        groups = $.extend(true, [], data.textFields)
        groups.splice(data.NUMBER_FIELDS_FIELD - 1, 1)
        @drawGroupControls(groups)

        handler = (selected, selFields) =>
          @yAxisRadioHandler(selected, selFields)
          @configs.binSize = @defaultBinSize()
          $('#bin-size').attr('value', @configs.binSize)

        @drawYAxisControls(globals.configs.fieldSelection,
          data.normalFields.slice(1), true, 'Fields',
          @configs.displayField, handler)
        @drawToolControls()
        @drawClippingControls()
        @drawSaveControls()

    if "Histogram" in data.relVis
      globals.histogram = new Histogram 'histogram-canvas'
    else
      globals.histogram = new DisabledVis 'histogram-canvas'
