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

        start: ->
            #Make table visible? (or something)
            ($ '#' + @canvas).show()

            ($ "##{@canvas}").css 'padding-top', 2
            ($ "##{@canvas}").css 'padding-bottom', 2

            #Calls update
            super()

        #Gets called when the controls are clicked and at start
        update: ->
          ($ '#' + @canvas).html('')
      
          #Updates controls by default       
          ($ '#' + @canvas).append '<table id="data_table" class="table table-default table-striped"></table>'
          
          ###           
          #Build the headers for the table
          headers = for field, fieldIndex in data.fields
            fieldTitle(field)
            
          #Build the colModel object
          columns = for field, fieldIndex in data.fields
            if (fieldIndex is data.COMBINED_FIELD)
              { name: fieldTitle(field), index: fieldIndex, search: true, resizable: false, hidden: true }
            else
              { name: fieldTitle(field), index: fieldIndex, search: true, resizable: false }
           
          @table = jQuery("#data_table").jqGrid({
            datatype: "local",
            height: ($ '#' + @canvas).height() - 45,
            width: ($ '#' + @canvas).width(),
 	          colNames: headers,
 	          caption: "Header Test"
 	          colModel: columns
 	          hidegrid: false;
 	          autowidth: true;
          })
          ###          
             
          #Build the data for the table
          visibleGroups = for group, groupIndex in data.groups when groupIndex in globals.groupSelection
            group
            
          rows = for dataPoint in data.dataPoints when (String dataPoint[data.groupingFieldIndex]).toLowerCase() in visibleGroups
              line = for dat, fieldIndex in dataPoint
                  if (fieldIndex is data.COMBINED_FIELD)
                      "<td style='display:none'>#{dat}</td>"
                  else
                      "<td>#{dat}</td>"
                    
                  "<tr>#{line.reduce (a,b)-> a+b}</tr>"
            
          ($ '#data_table').append '<tbody id="table_body"></tbody>' 
          ($ '#table_body').append row for row in rows 
          
          #Set sort state to default none existed
          @sortState ?= [[1, 'asc']]
          
          #Set default search to empty string
          @searchString ?= ''
                      
          #Restore previous search query if exists, else restore empty string
          if @searchString? and @searchString isnt ''
              $('#table_canvas').find('input').val(@searchString).keyup()

          super()

        end: ->
          ($ '#' + @canvas).hide()

          if @atable?
            
            #Save the sort state
            @sortState = @atable.fnSettings().aaSorting
	        
            #Save the table filter
            @searchString = ($ '#table_canvas').find('input').val()
            
        resize: (newWidth, newHeight, aniLength) ->
          foo = () ->
            jQuery("#data_table").setGridWidth(newWidth);
            
          setTimeout foo, aniLength

        drawControls: ->
            super()    
            @drawGroupControls()
            @drawSaveControls()

        serializationCleanup: ->
          delete @atable    

    globals.table = new Table "table_canvas"
