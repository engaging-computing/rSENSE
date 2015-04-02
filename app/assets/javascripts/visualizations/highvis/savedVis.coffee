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
  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]

    window.globals ?= {}

    ###
    Ajax call to save the vis with the given title and description.
    Calls the appropriate callback upon completetion. A failed attempt
    will pass the callback an error string, a success will pass the callback
    a string with the new VID.
    ###
    createVis = (name) ->
      modal = """
              <div id="loadModal" class="modal fade well">
                <div class="center">
                  <img src="/assets/spinner.gif" />
                </div>
              </div>
              """
      ($ '#viscontainer').append modal
      ($ "#loadModal").modal
        backdrop: 'static'
        keyboard: 'false'

      svg = if globals.curVis.chart?
        globals.curVis.chart.getSVG()
      else
        undefined

      savedData = globals.serializeVis()

      $.ajax
        type: 'POST'
        url: '/visualizations'
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
          window.location = msg.url
        error: (jqxhr, status, msg) ->
          response = $.parseJSON msg['responseText']
          error_message = response.errors.join "</p><p>"

          ($ '.container.mainContent').find('p').before """
          <div class="alert alert-danger fade in">
            <button type="button" class="close" data-dismiss="alert"
              aria-hidden="true">×</button>
            <h4>Error Saving Visualization:</h4>
            <p>#{error_message}</p>
            <p>
              <button type="button" class="btn btn-danger error_bind"
                data-retry-text"Retrying...">Retry</button>
              <button type="button" class="btn btn-default error_dismiss">
                Or Dismiss</button>
            </p>
          </div>"""

          # Dismiss
          ($ '.error_dismiss').click ->
            ($ '.alert').alert 'close'

          # Retry
          ($ '.error_bind').click ->
            createVis(name)

    ###
    Creates a new vis upon name submission
    ###
    globals.saveVis = (title, desc, succCallback, failCallback) ->
      name = 'Saved Vis - ' + data.projectName
      helpers.name_popup(name, 'visualization', '#viscontainer',
        createVis, null)

    ###
    Ajax call to check if the user is logged in. Calls the appropriate
    given callback when completed.
    ###
    globals.userPermissions = ->
      $.ajax
        type: 'GET'
        url: "/sessions/permissions"
        dataType: 'script'
        data:
          project_id: data.projectID

    ###
    Serializes all vis data. Strips functions from the objects before
    serializing since they cannot be serialized.
    ###
    globals.serializeVis = (includeData = true) ->
      # Set current vis to default
      current = (globals.curVis.canvas.match /([A-z]*)-canvas/)[1]
      current = current[0].toUpperCase() + current.slice 1
      data.defaultVis = current

      # Set fieldSelection if curVis has radio button for y-axis
      # This ensures that @configs.display defaults correctly
      if globals.curVis.configs.displayField
        globals.configs.fieldSelection = [globals.curVis.configs.displayField]

      # Check for and note LT dates
      if data.timeType is data.NORM_TIME
        for dp, dIndex in data.dataPoints
          for fieldIndex in data.timeFields
            data.dataPoints[dIndex][fieldIndex] = "U #{dp[fieldIndex]}"

      savedConfig = {}

      # Grab the global configs
      savedConfig['globals'] = globals.configs

      # Grab the vis specific configs
      for visName in data.allVis
        vis  = eval "globals.#{visName.toLowerCase()}"
        if vis?
          vis.serializationCleanup()
          savedConfig[visName] = vis.configs

      # Default vises don't save data
      dataCpy = {}
      if includeData then $.extend(dataCpy, data)

      ret =
        globals: (JSON.stringify savedConfig)
        data: (JSON.stringify dataCpy)

    ###
    Ajax call to update the project's default vis with the current settings.
    ###
    globals.defaultVis = ->
      savedData = globals.serializeVis(false)
      $.ajax
        type: 'PUT'
        url: '/projects/' + data.projectID
        dataType: 'JSON'
        data:
          project:
            globals: savedData.globals
            default_vis: data.defaultVis
        success: ->
          quickFlash('Project defaults updated successfully', 'success')
        error: ->
          quickFlash('Failed to update project defaults', 'error')
