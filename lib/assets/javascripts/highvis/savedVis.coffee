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
      
    window.globals ?= {}

    ###
    Ajax call to save the vis with the given title and description.
    Calls the appropriate callback upon completetion. A failed attempt
    will pass the callback an error string, a success will pass the callback
    a string with the new VID.
    ###
    globals.saveVis = (title, desc, succCallback, failCallback) ->
    
        modal = """
        <div id="loadModal" class="modal fade well">
          <div class="center">
            <img src="/assets/spinner.gif" />
          </div>
        </div>
        """
        ($ 'body').append modal
        ($ "#loadModal").modal
          backdrop: 'static'
          keyboard: 'false'
    
        svg = if globals.curVis.chart?
          globals.curVis.chart.getSVG()
        else
          undefined
          
        savedData = globals.serializeVis()

        ## construct default name
        sessionNames = for index, ses of data.metadata
          ses.name

        sessionNames = sessionNames.join ', '

        if sessionNames.length >= 30
          sessionNames = (sessionNames.slice 0, 27) + '...'

        name = 'Saved Vis - ' + data.projectName

        req = $.ajax
            type: 'POST'
            url: "/visualizations"
            dataType: 'json'
            data:
              visualization:
                project_id: Number data.projectID
                title: name
                data: savedData.data
                globals: savedData.globals
                svg: svg
            success: (msg) ->
              ($ "#loadModal").modal('hide')
              helpers.name_popup msg, "Visualization", "visualization"
            error: (jqxhr, status, error) ->
              alert "Could not connect to AWS"
              console.log [jqxhr, status, error]

    ###
    Ajax call to check if the user is logged in. Calls the appropriate
    given callback when completed.
    ###
    globals.verifyUser = (succCallback, failCallback)->

        req = $.ajax
            type: 'GET'
            url: "/users/verify"
            dataType: 'json'
            data: {}
            success: (msg, status, details) ->
              succCallback()
            error: (msg, status, details) ->
              failCallback()

    ###
    Serializes all vis data. Strips functions from the objects bfire serializing
    since they cannot be serialized.

    NOTE: Booleans cannot be serialized properly (Hydrate.js issue)
    ###
    globals.serializeVis = ->

        # set current vis to default
        current = (globals.curVis.canvas.match /([A-z]*)_canvas/)[1]
        current = current[0].toUpperCase() + current.slice 1
        data.defaultVis = current
        
        # Check for and note LT dates
        if data.timeType is data.NORM_TIME
          for dp, dIndex in data.dataPoints
            for fieldIndex in data.timeFields
              data.dataPoints[dIndex][fieldIndex] = "U #{dp[fieldIndex]}"

        hydrate = new Hydrate()

        stripFunctions = (obj) ->

            switch typeof obj
                when 'number'
                    obj
                when 'string'
                    obj
                when 'function'
                    undefined
                when 'object'

                    if obj is null
                        null
                    else
                        cpy = if $.isArray obj then [] else {}
                        for key, val of obj
                            stripped = stripFunctions val
                            if stripped isnt undefined
                                cpy[key] = stripped

                        cpy

        for visName in data.allVis
            vis  = eval "globals.#{visName.toLowerCase()}"
            vis.serializationCleanup()

        globalsCpy = stripFunctions globals
        dataCpy = stripFunctions data

        delete globalsCpy.curVis

        ret =
            globals: (hydrate.stringify globalsCpy)
            data: (hydrate.stringify dataCpy)

    ###
    Does a deep copy extend operation similar to $.extend
    ###
    globals.extendObject = (obj1, obj2) ->
        switch typeof obj2
            when 'boolean'
                obj2
            when 'number'
                obj2
            when 'string'
                obj2
            when 'function'
                obj2
            when 'object'

                if obj2 is null
                    obj2
                else
                    if $.isArray obj2
                        obj1 ?= []
                    else
                        obj1 ?= {}

                    for key, val of obj2 when key isnt '__hydrate_id'
                        obj1[key] = globals.extendObject obj1[key], obj2[key]
                    obj1
