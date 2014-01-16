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

    class window.Table extends BaseVis
        constructor: (@canvas) -> 

        #Removes nulls from the table
        nullFormatter = (cellvalue, options, rowObject) ->
            cellvalue = "" if isNaN(cellvalue) or cellvalue is null
            cellvalue

        #Formats tables dates properly
        dateFormatter = (cellvalue, options, rowObject) ->
            globals.dateFormatter cellvalue

        #Resizes the table properly
        ($ '#control_hide_button').click ->
            #Calulate the new width from these parameters
            containerSize = ($ '#viscontainer').width()
            hiderSize     = ($ '#controlhider').outerWidth()
            controlSize   = ($ '#controldiv').width()

            #Check if you are opening or closing the controls
            controlSize = if ($ '#controldiv').width() <= 0
                globals.CONTROL_SIZE
            else
                0

            #Set the grid to the correct size so the animation is smooth
            newWidth = containerSize - (hiderSize + controlSize + 10)
            newHeight = ($ '#viscontainer').height() - ($ '#visTabList').outerHeight()
            if ($ "#data_table")?
                ($ '#table_canvas').height(newHeight - 5)
                ($ "#data_table").setGridWidth(newWidth).setGridHeight(newHeight - 75)

        start: ->
            #Make table visible? (or something)
            ($ '#' + @canvas).show()

            ($ "##{@canvas}").css 'padding-top', 2
            ($ "##{@canvas}").css 'padding-bottom', 2

            #Calls update
            super()

        #Gets called when the controls are clicked and at start
        update: ->

            #Updates controls by default
            ($ '#' + @canvas).html('')
            ($ '#' + @canvas).append '<table id="data_table" class="table table-striped"></table>'

            #Build the headers for the table
            headers = for field in data.fields
                fieldTitle(field)

            #Make valid id's for the colModel
            colIds = for header in headers
                header.replace(/\s+/g, '_').toLowerCase()

            #Make sure the sort type for each column is appropriate
            columns = for colId, colIndex in colIds
                if (data.fields[colIndex].typeID is data.types.TEXT)
                    { name: colId, id: colId, sortType:'text' }
                else if (data.fields[colIndex].typeID is data.types.TIME)
                    { name: colId, id: colId, sortType:'number', formatter: dateFormatter }
                else
                    { name: colId, id: colId, sortType:'number', formatter: nullFormatter }

            #Build the data for the table
            visibleGroups = for group, groupIndex in data.groups when groupIndex in globals.groupSelection
                group

            rows = []
            for dataPoint in data.dataPoints when (String dataPoint[data.groupingFieldIndex]).toLowerCase() in visibleGroups
                line = {}
                for dat, fieldIndex in dataPoint
                    line[colIds[fieldIndex]] = dat
                rows.push(line)

            #Set sort state to default none existed
            @sortName ?= '';
            @sortType ?= '';

            #Set default search to empty string
            @searchParams ?= {}

            #Add the nav bar
            ($ '#table_canvas').append '<div id="toolbar_bottom"></div>'

            #Prepare the table to grid parameters
            @table = jQuery("#data_table").jqGrid({
                colNames: headers,
                colModel: columns,
                datatype: 'local',
                height: ($ '#' + @canvas).height() - 71,
                width: ($ '#' + @canvas).width(),
                gridview: true,
                caption: "",
                data: rows,
                hidegrid: false,
                ignoreCase:true
                rowNum: 50,
                autowidth: true,
                viewrecords: true,
                loadui: 'block',
                pager: '#toolbar_bottom'
            })

            #Hide the combined datasets column
            combined_col = @table.jqGrid('getGridParam','colModel')[data.COMBINED_FIELD]
            @table.hideCol(combined_col.name)
            ($ '#data_table').setGridWidth(($ '#' + @canvas).width())

            #Add a refresh button and enable the search bar
            @table.jqGrid('navGrid','#toolbar_bottom',{del:false,add:false,edit:false,search:false});
            @table.jqGrid('filterToolbar', {stringResult: true, searchOnEnter: false, defaultSearch:'cn'});

            #Set the sort parameters
            @table.sortGrid(@sortName, true, @sortType);

            #Restore the search filters
            if @searchParams?
                for column in @searchParams
                    inputId = "gs_" + column.field
                    ($ '#' + inputId).val(column.data)

            @table[0].triggerToolbar()

            super()

        end: ->
          ($ '#' + @canvas).hide()

          if @table?

            #Save the sort state
            @sortName = @table.getGridParam('sortname');
            @sortType = @table.getGridParam('sortorder');

            #Save the table filters
            if @table.getGridParam('postData').filters?
                @searchParams = jQuery.parseJSON(@table.getGridParam('postData').filters).rules

        resize: (newWidth, newHeight, aniLength) ->
          foo = () ->
            #In the case that this was called by the hide button, this gets called a second time
            #needlessly, but doesn't effect the overall performance
            ($ '#table_canvas').height(newHeight - 5)
            ($ '#data_table').setGridWidth(newWidth).setGridHeight(newHeight - 75)

          setTimeout foo, aniLength

        drawControls: ->
            super()
            @drawGroupControls()
            @drawSaveControls()

        serializationCleanup: ->
          delete @table

    globals.table = new Table "table_canvas"
