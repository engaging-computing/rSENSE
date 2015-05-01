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

    data.types ?=
      TIME: 1
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

    ###
    Selects data in an x,y object format of the given group.
    ###
    data.xySelector = (xIndex, yIndex, groupIndex) ->
      rawData = globals.CLIPPING.getData(@dataPoints).filter (dp) =>
        group = (String dp[globals.configs.groupById]).toLowerCase() == @groups[groupIndex]
        notNull = (dp[xIndex] isnt null) and (dp[yIndex] isnt null)
        notNaN = (not isNaN(dp[xIndex])) and (not isNaN(dp[yIndex]))

        group and notNull and notNaN

      mapFunc = (dp) ->
        obj =
          x: dp[xIndex]
          y: dp[yIndex]
          datapoint: dp

      mapped = rawData.map mapFunc
      mapped.sort (a, b) -> (a.x - b.x)

      mapped

    ###
    Selects data in an x,y object format of the given groups.
    ###
    data.multiGroupXYSelector = (xIndex, yIndex, groupIndices) ->
      allData =
        data.xySelector(xIndex, yIndex, group) for group in groupIndices

      merged = []
      merged = merged.concat.apply(merged, allData)

    ###
    Selects an array of data from the given field index.
    if 'nans' is true then datapoints with NaN values in the given field will be included.
    'filterFunc' is a boolean filter that must be passed (true) for a datapoint to be included.
    ###
    data.selector = (fieldIndex, groupIndex, nans = false) ->
      groupById = globals.configs.groupById

      filterFunc = (dp) =>
        (String dp[groupById]).toLowerCase() == @groups[groupIndex]

      newFilterFunc = if nans
        filterFunc
      else
        (dp) -> (filterFunc dp) and (not isNaN dp[fieldIndex]) and (dp[fieldIndex] isnt null)

      rawData = globals.CLIPPING.getData(@dataPoints).filter newFilterFunc

      rawData.map (dp) -> dp[fieldIndex]

    ###
    Selects an array of data from the given field index. Support being given an array of group indices.
    if 'nans' is true then datapoints with NaN values in the given field will be included.
    ###
    data.multiGroupSelector = (fieldIndex, groupIndices, nans = false) ->

      allData =
        data.selector(fieldIndex, group, nans) for group in groupIndices

      merged = []
      merged = merged.concat.apply(merged, allData)


    ###
    Gets the maximum (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMax = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      rawData = @multiGroupSelector(fieldIndex, groupIndices)

      if rawData.length > 0
        result = rawData.reduce (a,b) -> Math.max(a, b)
        data.precisionFilter(result)
      else
        null

    ###
    Gets the minimum (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMin = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      rawData = @multiGroupSelector(fieldIndex, groupIndices)

      if rawData.length > 0
        result = rawData.reduce (a,b) -> Math.min(a, b)
        data.precisionFilter(result)
      else
        null

    ###
    Gets the mean (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMean = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      rawData = @multiGroupSelector(fieldIndex, groupIndices)

      if rawData.length > 0
        result = (rawData.reduce (a,b) -> a + b) / rawData.length
        data.precisionFilter(result)
      else
        null

    ###
    Gets the median (numeric) value for the given field index.
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getMedian = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      rawData = @multiGroupSelector(fieldIndex, groupIndices)
      rawData = rawData.sort (a, b) ->
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
    data.getCount = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      dataCount = @multiGroupSelector(fieldIndex, groupIndices).length

      return dataCount

    ###
    Gets the sum of the points belonging to fieldIndex and groupIndex
    All included datapoints must pass the given filter (defaults to all datapoints).
    ###
    data.getTotal = (fieldIndex, groupIndices) ->
      if typeof groupIndices is 'number' then groupIndices = [groupIndices]
      rawData = @multiGroupSelector(fieldIndex, groupIndices)

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
      @dataPoints = @setIndexFromGroups(gIndex)
      globals.updateColorSlots()

    ###
    Sets the value of the Data Point (id) field to its index within the selected group.
    ###
    data.setIndexFromGroups = (gIndex) ->
      filterFunc = (dp) =>
        (String dp[gIndex]).toLowerCase() == @groups[groupIndex]

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

      for dp in @dataPoints
        if dp[gIndex] isnt null
          result[String(dp[gIndex]).toLowerCase()] = true

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
