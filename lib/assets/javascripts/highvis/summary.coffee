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
				if data.normalFields.length > 1
          @displayField = data.normalFields[1]
        else @displayField = data.normalFields[0]	
        
			start: ->
				($ '#' + @canvas).show()
				super()
				
			update: ->
				tempGroupIDValuePairs = for groupName, groupIndex in data.groups when groupIndex in globals.groupSelection
          switch @analysisType
            when @ANALYSISTYPE_TOTAL    then [groupIndex, (data.getTotal     @sortField, groupIndex)]
            when @ANALYSISTYPE_MAX      then [groupIndex, (data.getMax       @sortField, groupIndex)]
            when @ANALYSISTYPE_MIN      then [groupIndex, (data.getMin       @sortField, groupIndex)]
            when @ANALYSISTYPE_MEAN     then [groupIndex, (data.getMean      @sortField, groupIndex)]
            when @ANALYSISTYPE_MEDIAN   then [groupIndex, (data.getMedian    @sortField, groupIndex)]
            when @ANALYSISTYPE_COUNT    then [groupIndex, (data.getCount     @sortField, groupIndex)]
			
				($ '#' + @canvas).html('')
				html = """ 
					<div class="container">
						<div class="row" style="margin-top:15px;">
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Mean/Average</div>
									<div class='panel-body'>#{data.getMean @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Max</div>
									<div class='panel-body'>#{data.getMax @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Total</div>
									<div class='panel-body'>#{data.getTotal @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Median</div>
									<div class='panel-body'>#{data.getMedian @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Min</div>
									<div class='panel-body'>#{data.getMin @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
							<div class="col-md-4">
								<div class='panel panel-default'>
									<div class='panel-heading'>Data Point Count</div>
									<div class='panel-body'>#{data.getCount @displayField, data.groupingFieldIndex}</div>
								</div>
							</div>
						</div>
					</div>
				"""
				($ '#' + @canvas).append(html)
				super()

			end: ->
				($ '#' + @canvas).hide()

			###
			Draws y axis controls
			This includes a series of checkboxes or radio buttons for selecting
			the active y axis field(s).
			###
			drawYAxisControls: (radio = false) ->

				controls = '<div id="yAxisControl" class="vis_controls">'

				if radio
					controls += "<h3 class='clean_shrink'><a href='#'>Field:</a></h3>"
				else
					controls += "<h3 class='clean_shrink'><a href='#'>Y Axis:</a></h3>"

				controls += "<div class='outer_control_div'>"

				# Populate choices
				for fIndex in data.normalFields
					controls += "<div class='inner_control_div' >"

					if radio
						controls += """<div class='radio'><label><input class='y_axis_input' name='y_axis_group'
							type='radio' value='#{fIndex}'
							#{if (Number fIndex) is @displayField then "checked" else ""}>
							#{data.fields[fIndex].fieldName}</label></div>"""
					else
						controls += """<div class='checkbox'><label><input class='y_axis_input' type='checkbox'
							value='#{fIndex}' #{if (Number fIndex) in globals.fieldSelection then "checked" else ""}
							/>#{data.fields[fIndex].fieldName}</label></div>"""
					controls += "</div>"

				controls += '</div></div>'

				# Write HTML
				($ '#controldiv').append controls

				# Make y axis checkbox/radio handler
				if radio
					# Currently specific to histogram - TODO: decouple
					($ '.y_axis_input').click (e) =>
						@displayField = Number e.target.value
				else
					($ '.y_axis_input').click (e) =>
						index = Number e.target.value

						if index in globals.fieldSelection
							arrayRemove(globals.fieldSelection, index)
						else
							globals.fieldSelection.push(index)

				# Set up accordion
				globals.yAxisOpen ?= 0

				($ '#yAxisControl').accordion
					collapsible:true
					active:globals.yAxisOpen

				($ '#yAxisControl > h3').click ->
					globals.yAxisOpen = (globals.yAxisOpen + 1) % 2

			drawControls: ->
				super()
				@drawGroupControls(true)
				@drawYAxisControls(true)
				@drawSaveControls()
		
			globals.summary = new Summary "summary_canvas"

