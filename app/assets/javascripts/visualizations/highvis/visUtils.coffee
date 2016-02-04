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
    window.globals ?= {}

    ###
    Initializes and tracks the open / collapsed status of a control panel
      id    The id of the control panel
      gvar  The key of the tracking variable in globals.configs
    ###
    window.initCtrlPanel = (id, gvar) ->
      # Determines whether it should start hidden
      if globals.configs[gvar]
        $("##{id} > .vis-ctrl-body").show()
        $("##{id}").find('.vis-ctrl-icon > i').attr('class',
          'fa fa-chevron-down')

      # Tracks if open / collapsed
      $("##{id} > .vis-ctrl-header").click ->
        globals.configs[gvar] = !globals.configs[gvar]

        # Toggle collapsed/open
        $(@).siblings('.vis-ctrl-body').slideToggle()
        icon = $(@).find('.vis-ctrl-icon > i')
        icon.toggleClass('fa-chevron-left').toggleClass('fa-chevron-down')

    ###
    Returns the full path to a handlebars vis template
      template     Name of the handlebars vis template
    ###
    window.hbVis = (template) ->
      return 'visualizations/' + template

    ###
    Returns the full path to a handlebars control template
      template     Name of the handlebars control template
    ###
    window.hbCtrl = (template) ->
      return 'visualizations/controls/' + template

    ###
    Makes a title with appropriate units for a field
    ###
    window.fieldTitle = (field, parens = true) ->
      unless field?
        return

      if field.unitName? and field.unitName isnt ""
        if parens
          return "#{field.fieldName} (#{field.unitName})"
        else
          return "#{field.fieldName} #{field.unitName}"

      return field.fieldName

    ###
    Returns the units for a field
    ###
    window.fieldUnit = (field, parens = true) ->
      if field? and field.unitName?
        if parens is true then "(#{field.unitName})" else "#{field.unitName}"

    ###
    Removes 'item' from the array 'arr'
    Returns the modified (or unmodified) arr.
    ###
    window.arrayRemove = (arr, item) ->
      index = arr.indexOf(item)
      if index isnt -1
        arr.splice(index, 1)
      arr

    ###
    Tests to see if a and b are within thresh
    of the smaller value.
    ###
    window.fpEq = (a, b, thresh = 0.0001) ->
      diff = Math.abs(a - b)
      e = Math.abs(Math.min(a, b)) * thresh
      return diff < e

    ###
    Date formatter
    ###
    globals.dateFormatter = (dat) ->

      if dat is "null" or dat is null
        return ""

      if isNaN dat
        return "Invalid Date"

      if data.timeType is data.GEO_TIME
        return globals.geoDateFormatter(dat)

      dat = new Date(Number dat)

      monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul","Aug", "Sep", "Oct", "Nov", "Dec"]

      minDigits = (num, str) ->
        str = String str
        while str.length < num
          str = '0' + str
        str

      str = ""
      str += dat.getDate()              + " "
      str += monthNames[dat.getMonth()] + " "
      str += dat.getFullYear()          + " "

      str += (minDigits 2, dat.getHours())   + ":"
      str += (minDigits 2, dat.getMinutes()) + ":"
      str += (minDigits 2, dat.getSeconds()) + "."
      str += (minDigits 3, dat.getMilliseconds()) + " "
      str += jstz.determine().name()

    ###
    Date formatter for geological scale dates
    ###
    globals.geoDateFormatter = (dat) ->
      if dat is 0
        "BCE / CE"
      else if dat > 0
        "#{dat} CE"
      else
        "#{Math.abs dat} BCE"

    ###
    Cross platform accessor/mutator for element inner text
    ###
    window.innerTextCompat = (self, value = null) ->
      if document.getElementsByTagName("body")[0].innerText?
        if value is null
          return self.innerText
        else
          self.innerText = value
      else
        if value is null
          return self.textContent
        else
          self.textContent = value

    ###
    This function adds a parameterizable radial marker to Highchart's list of
    marker styles.
    ###
    addRadialMarkerStyle = (name, points, phase, magnitudes = [1]) ->

      extension = {}

      extension[name] = (x, y, w, h) ->

        svg = Array()

        verticies = Array()

        offset = phase * 2 * Math.PI

        modpoints = points * magnitudes.length

        for i in [0..modpoints]

          tx = (Math.sin 2 * Math.PI * i / modpoints + offset) * magnitudes[i % magnitudes.length]
          ty = (Math.cos 2 * Math.PI * i / modpoints + offset) * magnitudes[i % magnitudes.length]

          tx = tx / 2 + 0.5
          ty = ty / 2 + 0.5

          verticies.push [tx * w + x, ty * h + y]

        svg.push "M"
        svg.push verticies[0][0]
        svg.push verticies[0][1]
        svg.push "L"

        for [vx, vy] in verticies

          svg.push vx
          svg.push vy

        svg.push "Z"

        svg

      Highcharts.extend Highcharts.Renderer.prototype.symbols, extension

    ###
    Colors taken from Google Charts defaults:
      http://there4development.com/blog/2012/05/02/google-chart-color-list/
    ###
    globals.colors =
      ['#3366CC','#DC3912','#FF9900','#109618','#990099',
       '#3B3EAC','#0099C6','#DD4477','#66AA00','#B82E2E',
       '#316395','#994499','#22AA99','#AAAA11','#6633CC',
       '#E67300','#8B0707','#329262','#5574A6','#3B3EAC']

    globals.configs ?= {}
    globals.configs.colors = []

    ###
    Make sure there are at least enough color slots per group
    TODO fix underlying representation of colors (have an object of overrides)
    ###
    globals.updateColorSlots = ->
      while (globals.configs.colors.length < data.groups.length)
        globals.configs.colors.push(false)

    ###
    Associate a color with an index
    ###
    globals.setColor = (index, color) ->
      globals.configs.colors[index] = color

    ###
    Retreive a color associated with an index
    ###
    globals.getColor = (index) ->
      if !globals.configs.colors[index]
        return globals.colors[index % globals.colors.length]

      return globals.configs.colors[index]

    ###
    Generate a list of dashes
    ###
    globals.dashes = []

    globals.dashes.push 'Solid'
    globals.dashes.push 'ShortDot'
    globals.dashes.push 'ShortDash'
    globals.dashes.push 'Dot'

    globals.dashes.push 'ShortDashShortDot'
    globals.dashes.push 'DashDotDot'
    globals.dashes.push 'LongDashDotDotDot'

    globals.dashes.push 'LongDashDash'

    ###
    Generate a list of symbols and symbol rendering routines and then add them
    in an order that is clear and easy to read.
    ###

    fanMagList           = [1, 1, 15 / 16, 7 / 8, 3 / 4, 1 / 4, 1 / 4, 3 / 4, 7 / 8, 15 / 16, 1]
    pieMagList           = [1,1,1,1,1,1,1,1,1,1,1,1,1,0]
    halfmoonMagList      = [1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0]
    starMagList          = [Math.sqrt(2), 2 / 3]
    diamondMagList       = [Math.sqrt(2)]

    symbolList           = ['circle', 'square', 'up-tri', '5-star', 'diamond',  'down-tri', '4-fan',
      '6-star', 'left-tri', '3-fan', '2-pie', 'right-tri', '2-fan', 'up-halfmoon', 'down-halfmoon',
      'left-halfmoon', 'right-halfmoon', '3-pie', '4-pie', '5-pie']

    ###
    Add all the custom symbols for the symbolList.
    ###

    # Make the blank icon
    addRadialMarkerStyle "blank", 1, 0, [0]

    # Make default diamond as large as a square
    addRadialMarkerStyle "diamond", 4, 0, diamondMagList

    # Make the 5 and 6 pointed stars
    for i in [5,6]
      addRadialMarkerStyle "#{i}-star", i, 0.5, starMagList

    # Make the various 2, 3, and 4 pointed fans
    for i in [2,3,4]
      addRadialMarkerStyle "#{i}-fan", i, 0, fanMagList

    # Make the triangles of different orientation
    for [phase, direction] in [[0, "down"],[1 / 4, "right"],[2 / 4, "up"],[3 / 4, "left"]]
      addRadialMarkerStyle "#{direction}-tri", 3, phase, [Math.sqrt(2)]

    # Make the 2, 3, 4, and 5 sliced pies
    for i in [2,3,4,5]
      addRadialMarkerStyle "#{i}-pie", i, 0, pieMagList

    #Make the multi-direction halfmoons
    for [phase, direction] in[[0, "right"],[1 / 4, "up"],[2 / 4, "left"],[3 / 4, "down"]]
      addRadialMarkerStyle "#{direction}-halfmoon", 1, phase, halfmoonMagList

    ###
    Store the list
    ###
    globals.symbols = symbolList

    ###
    Generates an elapsed time field with given name from given
    time field.
    ###
    data.generateElapsedTime = (name, sourceField) ->
      timeMins = []

      for group in data.groups
        timeMins.push Number.MAX_VALUE

      for datapoint in data.dataPoints
        group = data.groups.indexOf (String datapoint[globals.configs.groupById])
        time = datapoint[sourceField].valueOf()
        timeMins[group] = Math.min timeMins[group], datapoint[sourceField]

      for datapoint in data.dataPoints
        group = data.groups.indexOf (String datapoint[globals.configs.groupById])
        curTime = datapoint[sourceField].valueOf()
        datapoint.push (curTime - timeMins[group]) / 1000.0

      data.fields.push
        fieldID: -1
        fieldName: name
        typeID: 2
        unitName: "s"

      data.numericFields.push (data.fields.length - 1)
      data.normalFields.push (data.fields.length - 1)

      if globals.scatter instanceof DisabledVis
        delete globals.scatter
        globals.scatter = new Scatter "scatter-canvas"
        # TODO deal with header restoration

      globals.scatter.xAxis = data.normalFields[data.normalFields.length - 1]
      $("#vistablist li[aria-controls='scatter-canvas'] a").click()

    ###
    Generates an appropriate elapsed time field.
    ###
    globals.generateElapsedTime = ->
      name  = 'Elapsed Time [from '
      name += data.fields[data.timeFields[0]].fieldName + ']'
      data.generateElapsedTime name, data.timeFields[0]
      globals.curVis.start()
      $('#elapsed-time-btn').addClass('disabled')
      quickFlash('Elapsed time generated successfully', 'success')


    globals.identity = (i) -> i

###
Override default highcarts zoom behavior
###
Highcharts.Axis.prototype.zoom = (newMin, newMax) ->
  this.displayBtn = newMin isnt undefined or newMax isnt undefined
  this.setExtremes(newMin, newMax, true, undefined, {trigger: 'zoom'})
  return true
