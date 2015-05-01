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

      buildOptions: ->
        super()

        self = this

        @chartOptions
        $.extend true, @chartOptions,
          chart:
            type: 'column'
          legend:
            enabled: false
          title:
            text: ''
          tooltipXAxis = @configs.displayField
          tooltip:
            formatter: ->
              str  = "<table>"
              str += "<tr><td>#{data.fields[tooltipXAxis].fieldName}:</td><td>#{@x} \
              #{fieldUnit(data.fields[tooltipXAxis], false)}<td></tr>"
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

        for groupIndex in data.groupSelection
          localMin = data.getMin @configs.displayField, groupIndex
          if localMin isnt null
            min = Math.min(min, localMin)

          localMax = data.getMax @configs.displayField, groupIndex
          if localMax isnt null
            max = Math.max(max, localMax)

        range = max - min

        # No data
        if max < min
          return 1

        console.log min, max

        curSize = 1

        bestSize = curSize
        bestNum  = range / curSize

        binNumTarget = Math.pow(10, @binNumSug)

        tryNewSize = (size) =>
          target = Math.abs(binNumTarget - (range / size))
          if target > Math.abs(binNumTarget - bestNum)
            return false

          bestSize = size
          bestNum  = range / size
          return true

        loop
          if (range / curSize) < binNumTarget
            curSize /= 10
          else if (range / curSize) > binNumTarget
            curSize *= 10

          break if not tryNewSize curSize

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
        tooltipXAxis = @configs.displayField
        if data.groupSelection.length is 0 then return

        while @chart.series.length > data.normalFields.length
          @chart.series[@chart.series.length - 1].remove false

        @globalmin = Number.MAX_VALUE
        @globalmax = Number.MIN_VALUE

        for groupIndex in data.groupSelection
          min = data.getMin @configs.displayField, groupIndex
          min = Math.round(min / @configs.binSize) * @configs.binSize
          @globalmin = Math.min @globalmin, min

          max = data.getMax @configs.displayField, groupIndex
          max = Math.round(max / @configs.binSize) * @configs.binSize
          @globalmax = Math.max @globalmax, max

        # Make 'fake' data to ensure proper bar spacing ###
        fakeDat = for i in [@globalmin...@globalmax] by @configs.binSize
          [i, 0]

        options =
          showInLegend: false
          data: fakeDat

        @chart.addSeries options, false

        # Generate all bin data
        binObjs = {}
        for groupIndex in data.groupSelection
          selectedData = data.selector @configs.displayField, groupIndex

          binArr = for i in selectedData
            Math.round(i / @configs.binSize) * @configs.binSize

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
                  binData.push {x: Number(bin), y: 1, total: binObjs[group][bin]}
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

        outctx =
          id: 'tools-ctrls'
          title: 'Tools'
          body: HandlebarsTemplates[hbCtrl('histogram-tools')](inctx)

        tools = HandlebarsTemplates[hbCtrl('body')](outctx)
        $('#vis-ctrls').append(tools)

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
        $('#bin-size').change (e) =>
          newBinSize = Number(e.target.value)
          if isNaN(newBinSize) or newBinSize <= 0
            $('#bin-size').errorFlash()
            return

          if ((@globalmax - @globalmin) / newBinSize) < @MAX_NUM_BINS
            @configs.binSize = newBinSize
            @update()
          else
            alert('Entered bin size would result in too many bins.')

      drawControls: ->
        super()
        @drawGroupControls(data.textFields)

        handler = (selected, selFields) =>
          @yAxisRadioHandler(selected, selFields)
          @configs.binSize = @defaultBinSize()
          $('#bin-size').attr('value', @configs.binSize)

        @drawYAxisControls(globals.configs.fieldSelection,
          data.normalFields.slice(1), true, 'Fields',
          @configs.displayField, handler)
        @drawToolControls()
        @drawSaveControls()

    if "Histogram" in data.relVis
      globals.histogram = new Histogram 'histogram-canvas'
    else
      globals.histogram = new DisabledVis 'histogram-canvas'
