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

    class window.DisabledVis extends BaseVis
      constructor: (@canvas) ->

      time_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_timeline"]}'>
          <br>
          <br>
          Either a timestamp or number field is missing,
          or there are not at least 3 data points.
          <br>
          Cannot display Timeline visualization
        </div>
        """
      scatter_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_scatter"]}'>
          <br>
          <br>
          Either two numeric fields were not found or there were not
          enough data
          <br>
          Cannot display Scatter Chart visualization
        </div>
        """
      histogram_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_histogram"]}'>
          <br>
          <br>
          Either no numeric fields were found or there were not enough data
          <br>
          Cannot display Histogram Visualization
        </div>
        """
      bar_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_bar"]}'>
          <br>
          <br>
          Either no numeric fields were found or there were not enough data
          <br>
          Cannot display Bar Chart visualization
        </div>
        """
      box_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_box"]}'>
          <br>
          <br>
          Either no numeric fields were found or there were not enough data
          <br>
          Cannot display Box Chart visualization
        </div>
        """
      map_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_map"]}'>
          <br>
          <br>
          No geographic data found
          <br>
          Cannot display Map visualization
        </div>
        """
      photos_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_photos"]}'>
          <br>
          <br>
          There are no photos to display
          <br>
          Cannot display Photos visualization
        </div>
        """
      pie_err =
        """
        <div class='novis_message'>
          <img src='#{window.icons["novis_pie"]}'>
          <br>
          <br>
          Either no numeric fields were found or there were not enough data
          <br>
          Cannot display Pie Chart Visualization
        </div>
        """

      start: ->
        $('#' + @canvas).show()
        @restoreTools = globals.configs.ctrlsOpen
        globals.configs.ctrlsOpen = false
        $('#vis-ctrl-container').hide()
        $('#ctrls-menu-btn').hide()

        switch @canvas
          when 'map-canvas'
            $('#' + @canvas).html("<div id='vis_disabled'>#{map_err}</div>")
          when "bar-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{bar_err}</div>")
          when "box-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{box_err}</div>")
          when "histogram-canvas"
            $('#' + @canvas).html "<div id='vis_disabled'>#{histogram_err}" +
              "</div>"
          when "timeline-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{time_err}</div>")
          when "scatter-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{scatter_err}</div>")
          when "photos-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{photos_err}</div>")
          when "pie-canvas"
            $('#' + @canvas).html("<div id='vis_disabled'>#{pie_err}</div>")

      clip: (arr) -> arr

      end: ->
        $('#' + @canvas).hide()
        globals.configs.ctrlsOpen = @restoreTools
        $('#vis-ctrl-container').show()
        $('#ctrls-menu-btn').show()
