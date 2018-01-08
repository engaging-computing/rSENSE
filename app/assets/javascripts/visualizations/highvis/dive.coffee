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

    class window.Dive extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)

      start: () ->
        globals.configs.ctrlsOpen = false
        super()
        link = document.createElement('link')
        link.rel = 'import'
        link.href = 'https://raw.githubusercontent.com/PAIR-code/facets/master/facets-dist/facets-jupyter.html'

        link.onload = ->
          dive = document.createElement('facets-dive')
          dive.crossOrigin = 'anonymous'
          divepts = $.extend(true, {}, data.dataPoints)
          divepts = Object.keys(divepts).map (key) -> divepts[key]
          fields = data.fields
          for dp in divepts
            for k, v of dp
              dp[fields[k].fieldName] = dp[k]
              delete dp[k]

          dive.data = divepts
          presets = {}
          for key of presets
            if presets.hasOwnProperty(key)
              dive[key] = presets[key]
          $("#dive-canvas").append dive    
          return

        document.head.appendChild link
        return

      update: () ->
        super()


      end: ->
        globals.configs.ctrlsOpen = true
        super()
            

    if "Dive" in data.relVis
      globals.dive = new Dive 'dive-canvas'
    else
      globals.dive = new DisabledVis 'dive-canvas'
      
