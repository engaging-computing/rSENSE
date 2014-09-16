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

    class window.Summary extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)

        if data.normalFields.length > 1
          @configs.displayField = data.normalFields[1]
        else @configs.displayField = data.normalFields[0]

      start: ->
        ($ '#' + @canvas).show()
        super()

      update: ->
        analysis = for groupName, groupIndex in data.groups when groupIndex is globals.configs.selectedGroup
          analysis =
            'total':  (data.getTotal       @configs.displayField, groupIndex)
            'min':    (data.getMin         @configs.displayField, groupIndex)
            'max':    (data.getMax         @configs.displayField, groupIndex)
            'median': (data.getMedian      @configs.displayField, groupIndex)
            'count':  (data.getCount       @configs.displayField, groupIndex)
            'mean':   (data.getMean        @configs.displayField, groupIndex)
          analysis
        ($ '#' + @canvas).html('')
        field = data.fields[@configs.displayField]
        noData = "No #{field.fieldName} Data"
        units = if field.unitName then "(#{field.unitName})" else ''
        html = """
                <div class="row" style="margin-top:15px;">
                  <div class="col-md-12 center"><h2>#{field.fieldName} #{units}</h2></div>
                </div>
                <hr/>
                <div class="row">
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Mean</div>
                      <div class='panel-body'>#{if analysis[0].mean? then analysis[0].mean else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Max</div>
                      <div class='panel-body'>#{if analysis[0].max? then analysis[0].max else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Total</div>
                      <div class='panel-body'>#{if analysis[0].total? then analysis[0].total else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Median</div>
                      <div class='panel-body'>#{if analysis[0].median? then analysis[0].median else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Min</div>
                      <div class='panel-body'>#{if analysis[0].min? then analysis[0].min else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Data Point Count</div>
                      <div class='panel-body'>#{if analysis[0].count? then analysis[0].count else noData}</div>
                    </div>
                  </div>
                </div>
                """
        ($ '#' + @canvas).append(html)
        super()

      end: ->
        ($ '#' + @canvas).hide()

      drawControls: ->
        super()
        @drawGroupControls(true, true)
        @drawYAxisControls(true)

      globals.summary = new Summary "summary_canvas"
