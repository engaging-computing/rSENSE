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

    class window.Overview extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)

      start: () ->
        globals.configs.ctrlsOpen = false
        super()
        link = document.createElement('link')
        link.rel = 'import'
        link.href = 'https://raw.githubusercontent.com/PAIR-code/facets/master/facets-dist/facets-jupyter.html'

        link.onload = ->
          overview = document.createElement('facets-overview')
          overview.crossOrigin = 'anonymous'
          overviewpts = $.extend(true, {}, data.dataPoints)
          overviewpts = Object.keys(overviewpts).map (key) -> overviewpts[key]
          fields = data.fields
          rmFields = ["Data Point", "Data Set Name (id)", "Combined Data Sets",
           "Number Fields", "Contributors", "Time Period"]
          rmIdx = []
          for field in fields
            idx = $.inArray(field.fieldName, rmFields)
            if idx != -1
              rmIdx.push idx
          for dp in overviewpts
            for k, v of dp
              if $.inArray(+k, rmIdx) != -1
                delete dp[k]
                continue
              dp[fields[k].fieldName] = dp[k]
              delete dp[k]

          proto = overview.getStatsProto([{data: overviewpts}])
          overview.protoInput = proto
          $("#overview-canvas").append overview    
          return

        document.head.appendChild link
        return

      update: () ->
        super()


      end: ->
        globals.configs.ctrlsOpen = true
        super()
            

    if "Overview" in data.relVis
      globals.overview = new Overview 'overview-canvas'
    else
      globals.overview = new DisabledVis 'overview-canvas'
      
