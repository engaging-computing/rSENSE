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
    # Use this to save vis state
    window.globals ?= {}
    globals.configs ?= {}
    globals.clippingVises = ['map', 'timeline', 'scatter', 'table']
    globals.configs.activeFilters ?= []
    globals.configs.clippingMode ?= false

    globals.configs.isPeriod ?= false # Controls how series are constructed in update().
    globals.configs.periodMode ?= 'off' # Changes when a period option is selected.


    # Restore saved data
    if data.savedData?
      # Don't extend the globals yet
      savedGlobals = data.savedGlobals

      savedData = JSON.parse(data.savedData)
      $.extend(data, savedData)

      # Restore globals string
      data.savedGlobals = savedGlobals

      # Check for motion reference and remove
      index = ($.inArray 'Motion', data.allVis)
      if index isnt -1
        data.allVis.splice index, 1

      delete data.savedData

    data.DATA_POINT_ID_FIELD = 0
    data.DATASET_NAME_FIELD = 1
    data.COMBINED_FIELD = 2
    data.NUMBER_FIELDS_FIELD = 3
    data.CONTRIBUTOR_FIELD = 4
    data.TIME_PERIOD_FIELD = 5

    data.types ?=
      TIME: 1
      NUMBER: 2
      TEXT: 3
      LOCATION: [4,5]

    data.units ?=
      LOCATION:
        LATITUDE: 4
        LONGITUDE: 5

    data.GEO_TIME  ?= 1
    data.NORM_TIME ?= 0
    data.timeType  ?= data.NORM_TIME

    data.DEFAULT_PRECISION = 4
    data.precision ?= data.DEFAULT_PRECISION

    # This should not be here.... i'll find a place for it some other time
    # Calculate which range a date falls in, both for group-by period
    # and to fix a bug causing points to be connected wrong
    globals.getCurrentPeriod = (date) ->
      month = ["January", "February", "March", "April", "May","June", "July",
        "August", "September", "October", "November", "December"]
    
      switch
        when globals.configs.periodMode is 'yearly'
          '' + date.getFullYear()
        when globals.configs.periodMode is 'monthly'
          month[date.getMonth()] + ' ' + date.getFullYear()
        when globals.configs.periodMode is 'weekly'
          # since every month has day numbers falling on different days of the week,
          # the weekly period calculation is a little different. Need to iteratively
          # calculate the week number.
          tempDate = new Date(date.getFullYear(), date.getMonth(), 1)
          weekNumber = 1
          dayNumber = 1
          incrementWeekNext = false
          while tempDate.getDate() != date.getDate()
            if incrementWeekNext is true
              incrementWeekNext = false
              weekNumber += 1
            if tempDate.getDay() == 6
              incrementWeekNext = true
            dayNumber += 1
            tempDate.setDate(dayNumber)
          weekNumber += 1 if incrementWeekNext is true

          'week ' + weekNumber + ' in ' + month[date.getMonth()] + ' ' + date.getFullYear()
        when globals.configs.periodMode is 'daily'
          '' + date.getMonth + '/' + date.getDate() + '/' + date.getFullYear()
        when globals.configs.periodMode is 'hourly'
          'hour ' + date.getHours() + ' on ' + date.getMonth() +  '/' + date.getDate() + '/' + date.getFullYear()
        else
          'Enable Period in Tools'

    ###
    Selects data with potential filters
    ###
    globals.getData = (clip = false, filters = []) ->
      # Select all the data
      dp = data.dataPoints
      if globals.configs.disabledPoints.length > 0
        dp = dp.filter (p) ->
          obj = {pointId: p[0], dataSetId: globals.getDataSetId(p[1])}
          pass = true
          for point in globals.configs.disabledPoints
            if JSON.stringify(point) == JSON.stringify(obj)
              pass = false
              break
          return pass

      unless clip and globals.configs.clippingMode then return dp

      # Ensure filters is a list
      if typeof(filters) is 'function' then filters = [filters]

      # Take the intersection of all the filters
      for filter in filters
        unless dp.filter? then break
        switch filter.op
          when 'bb', 'bt'
            func = eval('globals.' + filter.op)(filter.min, filter.max,
              filter.lvalue, filter.uvalue, filter.field)
          else
            func = eval('globals.' + filter.op)(filter.value, filter.field)
        dp = dp.filter(func)

      return dp

    ###
    Returns the Data Set ID given the data set name from the
    datapoint object, of the form: "[dataset name]([dataset id])".
    Does some fancy Regex magic in case the user includes numbers
    inside of parentheses in the data set name.
    ###
    globals.getDataSetId = (dsetName) ->
      matches = dsetName.match(/\([0-9]*\)/g)
      return /\(([0-9]*)\)/i.exec(matches[matches.length - 1])[1]

    ###
    Selects data in an x,y object format of the given group.
    ###
    data.xySelector = (xIndex, yIndex, groupIndex, dp) ->
      rawData = dp.filter (p) =>
        group = (String p[globals.configs.groupById]) == @groups[groupIndex]
        notNull = (p[xIndex] isnt null) and (p[yIndex] isnt null)
        notNaN = (not isNaN(p[xIndex])) and (not isNaN(p[yIndex]))

        group and notNull and notNaN

      mapFunc = (p) ->
        obj =
          x: p[xIndex]
          y: p[yIndex]
          datapoint: p

      mapped = rawData.map mapFunc
      mapped.sort (a, b) -> (a.x - b.x)
      return mapped

    ###
    Selects data in an x,y object format of the given groups.
    ###
    data.multiGroupXYSelector = (xIndex, yIndex, groupIndices, dp) ->
      allData =
        data.xySelector(xIndex, yIndex, group, dp) for group in groupIndices

      merged = []
      merged = merged.concat.apply(merged, allData)

    ###
    Selects an array of data from the given field index.
    if 'nans' is true then datapoints with NaN values in the given field will be included.
    'filterFunc' is a boolean filter that must be passed (true) for a datapoint to be included.
    ###
    data.selector = (fieldIndex, groupIndex, dp, nans = false) ->
      groupById = globals.configs.groupById

      filterFunc = (p) =>
        (String p[groupById]) == @groups[groupIndex]

      newFilterFunc = if nans
        filterFunc
      else
        (p) -> filterFunc(p) and (not isNaN p[fieldIndex]) and (p[fieldIndex] isnt null)

      rawData = dp.filter(newFilterFunc)
      rawData.map (p) -> p[fieldIndex]

    ###
    Selects an array of data from the given field index. Support being given an array of group indices.
    if 'nans' is true then datapoints with NaN values in the given field will be included.
    ###
    data.multiGroupSelector = (fieldIndex, groupIndices, dp, nans = false) ->
      allData =
        data.selector(fieldIndex, group, dp, nans) for group in groupIndices

      merged = []
      merged = merged.concat.apply(merged, allData)

    ###
    Gets the maximum (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMax = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = dp.map (p) -> p[fieldIndex]

      if rawData.length > 0
        result = rawData.reduce (a,b) -> Math.max(a, b)
        data.precisionFilter(result)
      else
        null

    ###
    Gets the minimum (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMin = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        rawData = dp.map (p) -> p[fieldIndex]

      if rawData.length > 0
        result = rawData.reduce (a,b) -> Math.min(a, b)
        data.precisionFilter(result)
      else
        null

    ###
    Gets the mean (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMean = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        rawData = dp.map (p) -> p[fieldIndex]

      if rawData.length > 0
        result = (rawData.reduce (a,b) -> a + b) / rawData.length
        data.precisionFilter(result)
      else
        null

    ###
    Gets the standard deviation (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###

    data.getStandardDeviation = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        rawData = dp.map (p) -> p[fieldIndex]

      if rawData.length > 0
        mean = (rawData.reduce (a,b) -> a + b) / rawData.length
        variance = (rawData.reduce(((a,b) -> a + Math.pow(b - mean, 2)), 0)) / rawData.length
        stddev = Math.sqrt(variance)
        data.precisionFilter(stddev)
      else
        null

    ###
    Gets the median (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMedian = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        rawData = dp.map (p) -> p[fieldIndex]

      rawData.sort (a, b) ->
        if a < b then -1 else 1
      mid = Math.floor (rawData.length / 2)

      if rawData.length > 0
        if rawData.length % 2
          return data.precisionFilter(rawData[mid])
        else
          return data.precisionFilter((rawData[mid - 1] + rawData[mid]) / 2.0)
      else
        null

    ###
    Gets the number of points belonging to fieldIndex and groupIndex
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getCount = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        dataCount = @multiGroupSelector(fieldIndex, groupIndices, dp).length
      else
        dataCount = (dp.map (p) -> p[fieldIndex]).length

      return dataCount

    ###
    Gets the sum of the points belonging to fieldIndex and groupIndex
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getTotal = (fieldIndex, groupIndices, dp) ->
      if groupIndices?
        if typeof groupIndices is 'number' then groupIndices = [groupIndices]
        rawData = @multiGroupSelector(fieldIndex, groupIndices, dp)
      else
        rawData = dp.map (p) -> p[fieldIndex]

      if rawData.length > 0
        total = 0
        for value in rawData
          total = total + value
        return data.precisionFilter(total)
      else
        null

    ###
    Gets a list of unique, non-null, stringified vals from the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.setGroupIndex = (gIndex) ->
      @groups = @makeGroups(gIndex)
      globals.updateColorSlots()

    ###
    Sets the value of the Data Point (id) field to its index within the selected group.
    Deprecated function.
    TODO: Delete this once we are sure we no longer need it.
    ###
    data.setIndexFromGroups = (gIndex) ->
      filterFunc = (dp) =>
        (String dp[gIndex]) == @groups[groupIndex]

      rawData = for group, groupIndex in @groups
        selectedPoints = @dataPoints.filter filterFunc

        for dp, dpIndex in selectedPoints
          dp[data.DATA_POINT_ID_FIELD] = dpIndex + 1
          dp

      merged = []
      merged = merged.concat.apply(merged, rawData)

    ###
    Gets a list of unique, non-null, stringified vals from the group field index.
    ###
    data.makeGroups = (gIndex) ->
      result = {}

      # If group by number fields, get the number fields
      if gIndex == data.NUMBER_FIELDS_FIELD
        groups = []
        for f in data.normalFields
          if data.fields[f].fieldID != -1
            groups.push(data.fields[f].fieldName)
      else

      if gIndex == data.TIME_PERIOD_FIELD #and globals.configs.isPeriod
        timestampIndex = data.timeFields[0]
        groups = []

        # Look through all timestamps to find the different time periods to use for groups
        for point in data.dataPoints
          timestamp = point[timestampIndex]
          if timestamp is null
            point[data.TIME_PERIOD_FIELD] = "No Time Data"
          else
            period = globals.getCurrentPeriod(new Date(timestamp))
            point[data.TIME_PERIOD_FIELD] = period

      for dp in @dataPoints
        if dp[gIndex] isnt null
          result[String(dp[gIndex])] = true

      groups = for keys of result
        keys

      groups.sort()

    ###
    Gets a list of text field indicies
    ###
    data.textFields = for field, index in data.fields when (Number field.typeID) is data.types.TEXT
      Number index

    ###
    Gets a list of time field indicies
    ###
    data.timeFields = for field, index in data.fields when (Number field.typeID) is data.types.TIME
      Number index

    ###
    Gets a list of non-text, non-time field indicies
    ###
    data.normalFields = for field, index in data.fields when (
      (Number field.typeID) not in [data.types.TEXT, data.types.TIME].concat data.types.LOCATION)
      Number index

    ###
    Gets a list of non-text field indicies
    ###
    data.numericFields = for field, index in data.fields when (Number field.typeID) not in [data.types.TEXT]
      Number index

    ###
    Gets a list of geolocation field indicies
    ###
    data.geoFields = for field, index in data.fields when (Number field.typeID) in data.types.LOCATION
      Number index

    ###
    Check if data is log safe
    ###
    data.logSafe ?= do ->
      for dataPoint in data.dataPoints
        for field, fieldIndex in data.fields when fieldIndex in data.normalFields
          if (Number dataPoint[fieldIndex] <= 0) and (dataPoint[fieldIndex] isnt null)
            return 0
      1

    ###
    Check various type-related issues
    ###
    data.preprocessData = ->
      for dp in data.dataPoints
        for field, fIndex in data.fields
          if (typeof dp[fIndex] == "string")
            # Strip all quote characters
            dp[fIndex] = dp[fIndex].replace /"/g, ""
            dp[fIndex] = dp[fIndex].replace /'/g, ""
            dp[fIndex] = dp[fIndex].trim()

          switch Number field.typeID
            when data.types.TIME
              dp[fIndex] = helpers.parseTimestamp dp[fIndex]

              if dp[fIndex] instanceof Array and isNaN(dp[fIndex][0])
                data.timeType = data.GEO_TIME

            when data.types.TEXT
              if dp[fIndex] == null
                dp[fIndex] = ""
              else
                NaN
            else
              if (isNaN (Number dp[fIndex])) or (dp[fIndex] == "") or (dp[fIndex] == null)
                dp[fIndex] = null
              else
                dp[fIndex] = Number dp[fIndex]

      for dp, dIndex in data.dataPoints
        for fieldIndex in data.timeFields when dp[fieldIndex] instanceof Array
          data.dataPoints[dIndex][fieldIndex] = dp[fieldIndex][data.timeType]
      1


    # Preprocess
    data.preprocessData()

    ###
    Rounds to precision set by data.precision (defaults to 4 decimal places)
    ###
    data.precisionFilter = (value, index, arr) ->
      precision = Math.pow(10, data.precision)
      Math.round(value * precision) / precision

    data.noField = () ->
      "No #{data.fields[globals.configs.groupById].fieldName}"
