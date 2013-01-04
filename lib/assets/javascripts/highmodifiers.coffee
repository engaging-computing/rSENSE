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

# Restored saved data
if data.savedData?
    hydrate = new Hydrate()
    globals.extendObject data, (hydrate.parse data.savedData)
    delete data.savedData

data.types ?=
    TIME: 7
    TEXT: 3
    LOCATION: [4,5]

data.units ?=
    LOCATION:
        LATITUDE: 4
        LONGITUDE: 5

###
Selects data in an x,y object format of the given group.
###
data.xySelector = (xIndex, yIndex, groupIndex) ->

    rawData = @dataPoints.filter (dp) =>
        group = (String dp[@groupingFieldIndex]).toLowerCase() == @groups[groupIndex]
        notNull = (dp[xIndex] isnt null) and (dp[yIndex] isnt null)
        notNaN = (not isNaN(dp[xIndex])) and (not isNaN(dp[yIndex]))

        group and notNull and notNaN

    if (Number @fields[xIndex].typeID) is data.types.TIME
        mapFunc = (dp) ->
            obj =
                x: new Date(dp[xIndex])
                y: Number dp[yIndex]
                datapoint: dp
    else
        mapFunc = (dp) ->
            obj =
                x: Number dp[xIndex]
                y: Number dp[yIndex]
                datapoint: dp

    mapped = rawData.map mapFunc
    mapped.sort (a, b) -> (a.x - b.x)

    mapped

###
Selects an array of data from the given field index.
if 'nans' is true then datapoints with NaN values in the given field will be included.
'filterFunc' is a boolean filter that must be passed (true) for a datapoint to be included.
###
data.selector = (fieldIndex, groupIndex, nans = false) ->

    filterFunc = (dp) =>
        (String dp[@groupingFieldIndex]).toLowerCase() == @groups[groupIndex]

    newFilterFunc = if nans
        filterFunc
    else
        (dp) -> (filterFunc dp) and (not isNaN dp[fieldIndex]) and (dp[fieldIndex] isnt null)

    rawData = @dataPoints.filter newFilterFunc

    rawData.map (dp) -> dp[fieldIndex]

###
Gets the maximum (numeric) value for the given field index.
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getMax = (fieldIndex, groupIndex) ->
    rawData = @selector(fieldIndex, groupIndex)

    if rawData.length > 0
        rawData.reduce (a,b) -> Math.max((Number a), (Number b))
    else
        null

###
Gets the minimum (numeric) value for the given field index.
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getMin = (fieldIndex, groupIndex) ->
    rawData = @selector(fieldIndex, groupIndex)

    if rawData.length > 0
        rawData.reduce (a,b) -> Math.min((Number a), (Number b))
    else
        null

###
Gets the mean (numeric) value for the given field index.
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getMean = (fieldIndex, groupIndex) ->
    rawData = @selector(fieldIndex, groupIndex)

    if rawData.length > 0
        (rawData.reduce (a,b) -> (Number a) + (Number b)) / rawData.length
    else
        null

###
Gets the median (numeric) value for the given field index.
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getMedian = (fieldIndex, groupIndex) ->
    rawData = @selector(fieldIndex, groupIndex)
    rawData.sort()

    mid = Math.floor (rawData.length / 2)

    if rawData.length > 0
        if rawData.length % 2
            return Number rawData[mid]
        else
            return ((Number rawData[mid - 1]) + (Number rawData[mid])) / 2.0
    else
        null

###
Gets the number of points belonging to fieldIndex and groupIndex
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getCount = (fieldIndex, groupIndex) ->
    dataCount = @selector(fieldIndex, groupIndex).length

    return dataCount

###
Gets the sum of the points belonging to fieldIndex and groupIndex
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.getTotal = (fieldIndex, groupIndex) ->
    rawData = @selector(fieldIndex, groupIndex);

    if rawData.length > 0
        total = 0
        for value in rawData
            total = total + (Number value)
        return total;
    else
        null

###
Gets a list of unique, non-null, stringified vals from the given field index.
All included datapoints must pass the given filter (defaults to all datapoints).
###
data.setGroupIndex = (index) ->
    @groupingFieldIndex = index
    @groups = @makeGroups()

###
Gets a list of unique, non-null, stringified vals from the group field index.
###
data.makeGroups = ->

    result = {}

    for dp in @dataPoints
        if dp[@groupingFieldIndex] isnt null
            result[String(dp[@groupingFieldIndex]).toLowerCase()] = true

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
data.normalFields = for field, index in data.fields when (Number field.typeID) not in [data.types.TEXT, data.types.TIME, data.types.LOCATION]
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



#Check if data is log safe
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

    dateFormats = ["YYYY MM DD hh:mm:ss.SSS A Z",
                   "YYYY MMM DD hh:mm:ss.SSS A Z",
                   "MM DD YYYY hh:mm:ss.SSS A Z",
                   "MMM DD YYYY hh:mm:ss.SSS A Z",
                   
                   "YYYY MM DD hh:mm:ss.SSS Z",
                   "YYYY MMM DD hh:mm:ss.SSS Z",
                   "MM DD YYYY hh:mm:ss.SSS Z",
                   "MMM DD YYYY hh:mm:ss.SSS Z"]

    for dp in data.dataPoints
        for field, fIndex in data.fields
            if (typeof dp[fIndex] == "string")
                # Strip all quote characters
                dp[fIndex] = dp[fIndex].replace /"/g, ""
                dp[fIndex] = dp[fIndex].replace /'/g, ""
                dp[fIndex] = dp[fIndex].replace /-/g, " "

            switch Number field.typeID
                when data.types.TIME
                
                    if isNaN Number dp[fIndex]
                        dp[fIndex] = (moment dp[fIndex], dateFormats).valueOf()
                    else
                        dp[fIndex] = (moment (Number dp[fIndex])).valueOf()
                when data.types.TEXT
                    NaN
                else
                    dp[fIndex] = Number dp[fIndex]
    1

data.preprocessData()
#Field index of grouping field
data.groupingFieldIndex ?= 0
#Array of current groups
data.groups ?= data.makeGroups()