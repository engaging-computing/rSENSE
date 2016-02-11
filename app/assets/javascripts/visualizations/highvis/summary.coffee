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

    class window.Summary extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)

      start: ->
        @configs.displayField = Math.min(globals.configs.fieldSelection...)
        super()

      update: ->
        dp = globals.getData(true, globals.configs.activeFilters)
        groupSel = data.groupSelection
        analysis =
          'total':   data.getTotal(@configs.displayField, groupSel, dp)
          'min':       data.getMin(@configs.displayField, groupSel, dp)
          'max':       data.getMax(@configs.displayField, groupSel, dp)
          'median': data.getMedian(@configs.displayField, groupSel, dp)
          'count':   data.getCount(@configs.displayField, groupSel, dp)
          'mean':     data.getMean(@configs.displayField, groupSel, dp)

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
                      <div class='panel-body'>#{if analysis.mean? then analysis.mean else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Max</div>
                      <div class='panel-body'>#{if analysis.max? then analysis.max else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Total</div>
                      <div class='panel-body'>#{if analysis.total? then analysis.total else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Median</div>
                      <div class='panel-body'>#{if analysis.median? then analysis.median else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Min</div>
                      <div class='panel-body'>#{if analysis.min? then analysis.min else noData}</div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class='panel panel-default'>
                      <div class='panel-heading'>Data Point Count</div>
                      <div class='panel-body'>#{if analysis.count? then analysis.count else noData}</div>
                    </div>
                  </div>
                </div>
                """
        ($ '#' + @canvas).append(html)
        super()

      end: ->
        super()

      drawControls: ->
        super()
        # Remove group by number fields, only for pie chart
        groups = $.extend(true, [], data.textFields)
        groups.splice(data.NUMBER_FIELDS_FIELD - 1, 1)
        @drawGroupControls(groups)
        @drawYAxisControls(globals.configs.fieldSelection,
          data.normalFields.slice(1), true, 'Fields', @configs.displayField,
          @yAxisRadioHandler)
        @drawClippingControls()
        @drawSaveControls()

      globals.summary = new Summary "summary-canvas"
