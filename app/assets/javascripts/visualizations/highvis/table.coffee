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

    class window.Table extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)
        @TOOLBAR_HEIGHT_OFFSET = 70

        fieldList = (i for f, i in data.fields when i isnt data.COMBINED_FIELD)
        @configs.tableFields ?= fieldList[0..7]

        # Set sort state to default none existed
        @configs.sortName ?= ''
        @configs.sortType ?= ''

        # Set default search to empty string
        @configs.searchParams ?= {}

      # Removes nulls from the table and colors the groupByRow
      rowFormatter = (cellvalue, options, rowObject) ->
        cellvalue = "" if $.type(cellvalue) is 'number' and isNaN(cellvalue) or cellvalue is null

        colorIndex = data.groups.indexOf(String(cellvalue).toLowerCase()) % globals.configs.colors.length
        if (colorIndex isnt -1)
          return "<font color='#{globals.configs.colors[colorIndex]}'>#{cellvalue}<font>"

        cellvalue

      # Formats tables dates properly
      dateFormatter = (cellvalue, options, rowObject) ->
        globals.dateFormatter cellvalue

      start: ->
        # Make table visible? (or something)
        $('#' + @canvas).show()

        # Calls update
        super()

      # Gets called when the controls are clicked and at start
      update: ->
        # Updates controls by default
        $('#' + @canvas).html('')
        $('#' + @canvas).append '<table id="data_table" class="table table-striped"></table>'

        # Build the headers for the table
        headers = for field in data.fields
          fieldTitle(field)

        # Make valid id's for the colModel
        colIds = for header, index in headers
          id = header.replace(/\s+/g, '_').toLowerCase()
          if index is globals.configs.groupById
            @configs.groupingId = id
          else id

        # Build the data for the table
        visibleGroups = for group, groupIndex in data.groups when groupIndex in data.groupSelection
          group

        rows = []
        for dataPoint in globals.CLIPPING.getData(data.dataPoints) \
        when (String dataPoint[globals.configs.groupById]).toLowerCase() in visibleGroups
          line = {}
          for dat, fieldIndex in dataPoint
            line[colIds[fieldIndex]] = dat
          rows.push(line)

        # Make sure the sort type for each column is appropriate, and save the time column
        timeCol = ""
        columns = for colId, colIndex in colIds
          if (data.fields[colIndex].typeID is data.types.TEXT)
            {
              name:           colId
              id:             colId
              sorttype:       'text'
              formatter:      rowFormatter
              searchoptions:  { sopt:['cn','nc','bw','bn','ew','en','in','ni'] }
            }
          else if (data.fields[colIndex].typeID is data.types.TIME)
            timeCol = colId
            {
              name:           colId
              id:             colId
              sorttype:       'text'
              formatter:      dateFormatter
              searchoptions:  { sopt:['cn','nc','bw','bn','ew','en','in','ni'] }
            }
          else
            {
              name:           colId
              id:             colId
              sorttype:       'number'
              formatter:      rowFormatter
              searchoptions:  { sopt:['eq','ne','lt','le','gt','ge'] }
            }

        # Add the nav bar
        $('#table_canvas').append '<div id="toolbar_bottom"></div>'

        # Build the grid
        @table = jQuery("#data_table").jqGrid({
          colNames: headers
          colModel: columns
          datatype: 'local'
          height: $('#' + @canvas).height() - @TOOLBAR_HEIGHT_OFFSET
          width: $('#' + @canvas).width()
          gridview: true
          caption: ""
          data: rows
          hidegrid: false
          ignoreCase: true
          rowNum: 50
          autowidth: true
          viewrecords: true
          loadui: 'block'
          pager: '#toolbar_bottom'
          gridComplete: @saveSort
        })

        # Show only the checked columns
        for f, fIndex in data.fields
          col = @table.jqGrid('getGridParam','colModel')[fIndex]
          if $.inArray(fIndex, @configs.tableFields) is -1
            @table.hideCol(col.name)
          else
            @table.showCol(col.name)

        $('#data_table').setGridWidth($('#' + @canvas).width())

        # Add a refresh button and enable the search bar
        params =
          del:    false
          add:    false
          edit:   false
          search: false
        @table.jqGrid('navGrid','#toolbar_bottom', params)

        params =
          stringResult:    true
          searchOnEnter:   false
          searchOperators: true
          operandTitle:    'Select Search Operation'
          resetIcon:       '<i class="fa fa-times-circle"></i>'
        @table.jqGrid('filterToolbar', params)

        # Set the time column formatters
        timePair = {}
        timePair[timeCol] = dateFormatter
        setFilterFormatters(timePair)

        # Set the sort parameters
        @table.sortGrid(@configs.sortName, true, @configs.sortType)

        regexEscape = (str) ->
          return str.replace(new RegExp('[.\\\\+*?\\[\\^\\]$(){}=!<>|:\\-]', 'g'), '\\$&')

        # Restore the search filters
        if @configs.searchParams?
          for column in @configs.searchParams
            # Restore the search input string
            inputId = regexEscape('gs_' + column.field)
            $('#' + inputId).val(column.data)

            # Restore the search filter type and operator symbol
            operator = $('#' + inputId).closest('tr').find('.soptclass')
            $(operator).attr('soper', column.op)
            operands = { "eq": "==", "ne": "!",  "lt": "<",  "le": "<=", \
                         "gt": ">",  "ge": ">=", "bw": "^",  "bn": "!^", \
                         "in": "=",  "ni": "!=", "ew": "|",  "en": "!@", \
                         "cn": "~",  "nc": "!~", "nu": "#",  "nn": "!#" }
            $(operator).text(operands[column.op])

        @table[0].triggerToolbar()

        super()

      resize: (newWidth, newHeight, aniLength) ->
        # In the case that this was called by the hide button, this gets called a second time
        # needlessly, but doesn't effect the overall performance
        $('#data_table').setGridWidth(newWidth)

      drawControls: ->
        super()
        @drawGroupControls()
        fields = (i for f, i in data.fields when i isnt data.COMBINED_FIELD)
        @drawYAxisControls('Visible Fields', @configs.tableFields,
          (i for f, i in data.fields when i isnt data.COMBINED_FIELD), false)
        @drawSaveControls()

      saveSort: =>
        if @table?
          # Save the sort state
          @configs.sortName = @table.getGridParam('sortname')
          @configs.sortType = @table.getGridParam('sortorder')

          # Save the table filters
          if @table.getGridParam('postData').filters?
            @configs.searchParams = jQuery.parseJSON(@table.getGridParam('postData').filters).rules

      ###
      JQGrid time formatting (to implement search post formatting)
      http://stackoverflow.com/questions/5822302/how-to-do-local-search-on-formatted-column-value-in-jqgrid
      Credits to Oleg and adam-p
      Converted to coffee script by Jeremy Poulin

        Causes local filtering to use custom formatters for specific columns.
        formatters is a dictionary of the form:
        { "column_name_1_needing_formatting": "column1FormattingFunctionName",
          "column_name_2_needing_formatting": "column2FormattingFunctionName" }
        Note that subsequent calls will *replace* all formatters set by previous calls.
      ###
      setFilterFormatters = (formatters) ->
        columnUsesCustomFormatter = (column_name) ->
          for col of formatters
            if (col == column_name)
              return true
          return false

        accessor_regex = /jQuery\.jgrid\.getAccessor\(this\,'(.+)'\)/

        oldFrom = $.jgrid.from
        $.jgrid.from = (source, initialQuery) ->

          result = oldFrom(source, initialQuery)
          result._getStr = (s) ->
            column_formatter = "String"

            column_match = s.match(accessor_regex, '$1')
            if (column_match && columnUsesCustomFormatter(column_match[1]))
              column_formatter = formatters[column_match[1]]

            phrase = []
            if (this._trim)
              phrase.push("jQuery.trim(")
            phrase.push(column_formatter + "(" + s + ")")
            if (this._trim)
              phrase.push(")")
            if (!this._usecase)
              phrase.push(".toLowerCase()")
            return phrase.join("")

          return result

      clip: (arr) -> arr

    globals.table = new Table "table_canvas"
