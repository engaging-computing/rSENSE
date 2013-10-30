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
  
    class CanvasProjectionOverlay extends google.maps.OverlayView
      constructor: ->
      onAdd: ->
      draw: ->
      onRemove: ->
      projectPixels: (latlng) ->
        @getProjection().fromLatLngToContainerPixel(latlng)
      
    class window.Map extends BaseVis
        constructor: (@canvas) ->
            @HEATMAP_NONE = -2
            @HEATMAP_MARKERS = -1

            @visibleMarkers = 1
            @visibleLines = 1
            @visibleClusters = if data.dataPoints.length > 100 then 1 else 0
            @heatmapSelection = @HEATMAP_NONE

            # Inited in start
            #@heatmapRadius = 1

        serializationCleanup: ->
            delete @gmap
            delete @projOverlay
            delete @heatPoints
            delete @markers
            delete @heatmap
            delete @clusterer
            delete @oms
            if @timeLines?
              delete @timeLines
        
        start: ->
            ($ '#' + @canvas).show()

            # Remove old handlers if they exist
            if @markers?
                for group in @markers
                    for marker in group
                        google.maps.event.clearInstanceListeners marker
            
            @markers = []
            for group in data.groups
                @markers.push []

            @heatmaps = {}
            @heatPoints = {}
            @heatPoints[@HEATMAP_NONE] = []
            @heatPoints[@HEATMAP_MARKERS] = []
            for index in data.normalFields
                @heatPoints[index] = []
                
            if data.timeFields.length > 0
              @timeLines = []
              for group in data.groups
                @timeLines.push []

            for index of @heatPoints
                for group in data.groups
                    @heatPoints[index].push []
            ################PLUGIN INIT###############
            # Gmaps
            latlngbounds = new google.maps.LatLngBounds()

            mapOptions =
                center: new google.maps.LatLng(0,0)
                zoom: 0
                mapTypeId: google.maps.MapTypeId.ROADMAP
                scaleControl: true

            @gmap = new google.maps.Map(document.getElementById(@canvas), mapOptions)
            info = new google.maps.InfoWindow()
              
            # Projection Helper
            @projOverlay = new CanvasProjectionOverlay()
            @projOverlay.setMap @gmap
            
            # Overlapping marker spiderfier
            initOMS()
            @oms = new OverlappingMarkerSpiderfier @gmap,
              keepSpiderfied: true  
            @oms.addListener 'click', (marker, ev) =>
              info.setContent marker.desc
              info.open @gmap, marker
            @oms.addListener 'unspiderfy', () =>
              info.close()
              
            # clusterer
            clusterStyles = []
            clusterStyles.push
              url: "/assets/cluster1.png"
              height: 35
              width:  35
              textColor: '#FFF'
              textSize: 10
            clusterStyles.push
              url: "/assets/cluster2.png"
              height: 35
              width:  35
              textColor: '#FFF'
              textSize: 11
            clusterStyles.push
              url: "/assets/cluster3.png"
              height: 35
              width:  35
              textColor: '#FFF'
              textSize: 12
            clusterStyles.push
              url: "/assets/cluster4.png"
              height: 35
              width:  35
              textColor: '#FFF'
              textSize: 12
            
            @clusterer = new MarkerClusterer @gmap, [],
              maxZoom: if @visibleClusters then 17 else -1
              gridSize: 35
              ignoreHidden: true
              styles: clusterStyles
            ################################################
            
            for dataPoint in data.dataPoints
                lat = lon = null
                do =>
                    # Grab geospatial
                    for field, fieldIndex in data.fields
                        
                        if (Number field.typeID) in data.types.LOCATION
                          if (Number field.typeID) is data.units.LOCATION.LATITUDE
                              lat = dataPoint[fieldIndex]
                          else if (Number field.typeID) is data.units.LOCATION.LONGITUDE
                              lon = dataPoint[fieldIndex]

                    if (lat is null) or (lon is null)
                        return

                    groupIndex = data.groups.indexOf dataPoint[data.groupingFieldIndex].toLowerCase()
                    color = globals.colors[groupIndex % globals.colors.length]

                    latlng = new google.maps.LatLng(lat, lon)
                    
                    # put aside line info if nessisary
                    if @timeLines? and dataPoint[data.timeFields[0]] isnt null and not(isNaN dataPoint[data.timeFields[0]])
                      @timeLines[groupIndex].push
                        time: dataPoint[data.timeFields[0]]
                        latlng: latlng

                    # Build info window content
                    label  = "<div style='font-size:9pt;overflow-x:none;'>"
                    label += "<div style='width:100%;text-align:center;color:#{color};'> #{dataPoint[data.groupingFieldIndex]}</div>"#<br>"
                    label += "<table>"

                    for field, fieldIndex in data.fields when dataPoint[fieldIndex] isnt null
                        dat = if (Number field.typeID) is data.types.TIME
                            (globals.dateFormatter dataPoint[fieldIndex])
                        else
                            dataPoint[fieldIndex]

                        label += "<tr><td>#{field.fieldName}</td>"
                        label += "<td><strong>#{dat}</strong></td></tr>"

                    label += "</table></div>"
                        
                    if groupIndex in globals.groupSelection
                        latlngbounds.extend latlng

                    pinSym =
                      fillColor: color
                      fillOpacity: 1
                      path: google.maps.SymbolPath.CIRCLE
                      strokeColor: "#000"
                      strokeWeight: 2
                      scale: 7
                      
                    newMarker = new google.maps.Marker
                      position: latlng
                      icon: pinSym
                      desc: label
                      visible: ((groupIndex in globals.groupSelection) and @visibleMarkers is 1)
                      
                    @oms.addMarker newMarker
                    
                    @markers[groupIndex].push newMarker

                    for index in data.normalFields when dataPoint[index] isnt null
                        @heatPoints[index][groupIndex].push
                            weight: dataPoint[index]
                            location: latlng

                    @heatPoints[@HEATMAP_MARKERS][groupIndex].push latlng

            # add markers into the clusterer
            @clusterer.addMarkers [].concat.apply([], @markers)

            # Produce time lines if available
            if @timeLines?
              for lineArr, index in @timeLines
                @timeLines[index].sort (a, b) -> (a.time - b.time)
                @timeLines[index] = @timeLines[index].map (a) -> a.latlng
                @timeLines[index] = new google.maps.Polyline
                  path: @timeLines[index]
                  geodesic: true
                  strokeColor: globals.colors[index]
                  strokeOpacity: 1.0
                  strokeWeight: 2
                  visible: ((index in globals.groupSelection) and @visibleLines is 1)
                  
                @timeLines[index].setMap(@gmap)

            # Deal with zoom
            if @zoomLevel?
              @gmap.setZoom @zoomLevel
              
            # Figure default heatmap
            if not @heatmapRadius?
              @heatmapRadius = 1
              dist = @getDiag(latlngbounds)
              pixelDist = @getPixelDiag()
              dpp = pixelDist / dist
              
              # Make sure the radius is at least 10px
              while @heatmapRadius * dpp < 10
                @heatmapRadius *= 10
              
            # Deal with zoom area
            if @savedCenter?
              @gmap.setCenter new google.maps.LatLng(@savedCenter.lat, @savedCenter.lng)
            else
              @gmap.fitBounds(latlngbounds)
            
            @drawControls()
            
            finalInit = =>
              @zoomLevel = @gmap.getZoom()
              google.maps.event.addListener @gmap, "zoom_changed", =>
                newZoom = @gmap.getZoom()
                if @heatmapSelection isnt @HEATMAP_NONE
                  # Guess new radius
                  @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * Math.pow(2, newZoom - @zoomLevel))
                  @delayedUpdate()
                @zoomLevel = newZoom
                
              google.maps.event.addListener @gmap, "bounds_changed", =>
                cen = @gmap.getCenter()
                @savedCenter =
                  lat: cen.lat()
                  lng: cen.lng()
                  
              google.maps.event.addListener @gmap, "dragend", =>
                # Update if the projection has changed enough to disturb the heatmap
                if @heatmapSelection isnt @HEATMAP_NONE
                  if @getHeatmapScale() isnt @heatmapPixelRadius
                    @delayedUpdate()

              # Don't need this since satellite is not default
#               mzs = new google.maps.MaxZoomService()
#               mzs.getMaxZoomAtLatLng @gmap.getBounds().getNorthEast(), (res) =>
#                 if @gmap.getZoom() > res.zoom
#                   @gmap.setZoom(res.zoom)
                
              @update()
            
            checkProj = =>
              if @projOverlay.getProjection() is undefined
                google.maps.event.addListenerOnce @gmap, "idle", checkProj
              else
                finalInit()
            
            # Need to wait for the projection to become available for updates
            checkProj()
        
        update: ->
          # Disable old heatmap (if there)
          if @heatmap?
            @heatmap.setMap null
            delete @heatmap
          
          # Build heatmap points from pre-computed data
          if @heatmapSelection isnt @HEATMAP_NONE
            
            heats = []
            for index, heatArray of @heatPoints when (Number index) is @heatmapSelection
              for groupArray, groupIndex in heatArray when groupIndex in globals.groupSelection
                heats = heats.concat groupArray

            @heatmapPixelRadius = @getHeatmapScale()
            # Draw heatmap
            @heatmap = new google.maps.visualization.HeatmapLayer
              data: heats
              radius: @heatmapPixelRadius
              dissipating:true
            @heatmap.setMap @gmap

          # Set marker visibility
          for markGroup, index in @markers
            for mark in markGroup
              mark.setVisible ((index in globals.groupSelection) and @visibleMarkers is 1)
                  
            if @timeLines?
              @timeLines[index].setVisible ((index in globals.groupSelection) and @visibleLines is 1)
          
          @clusterer.repaint()
          
          super()
            
        end: ->
            ($ '#' + @canvas).hide()
            @heatmap = undefined
            
        drawControls: ->
            super()
            @drawGroupControls(true)
            @drawToolControls()
            @drawSaveControls()

        drawToolControls: ->
            controls =  '<div id="toolControl" class="vis_controls">'

            controls += "<h3 class='clean_shrink'><a href='#'>Tools:</a></h3>"
            controls += "<div class='outer_control_div'>"
            
            controls += "<h4 class='clean_shrink'>Heat Maps</h4>"

            # Add heatmap selector
            controls += '<div class="inner_control_div"> Map By: '
            controls += '<select id="heatmapSelector" class="control_select">'

            sel = if @heatmapSelection is @HEATMAP_NONE then 'selected' else ''
            controls += "<option value=\"#{@HEATMAP_NONE}\" #{sel}>None</option>"
            sel = if @heatmapSelection is @HEATMAP_MARKERS then 'selected' else ''
            controls += "<option value=\"#{@HEATMAP_MARKERS}\" #{sel}>Marker Density</option>"
            
            for fieldIndex in data.normalFields
                sel = if @heatmapSelection is fieldIndex then 'selected' else ''
                controls += "<option value=\"#{Number fieldIndex}\" #{sel}>#{data.fields[fieldIndex].fieldName}</option>"

            controls += "</select></div>"

            #Heatmap slider
            controls += "<br>"
            controls += "<div class='inner_control_div'> Heatmap Radius: "
            controls += "<input id='radiusText' value='#{@heatmapRadius}'></input>m</div>"
            controls += "<div class='inner_control_div'> <div id='heatmapErrorText'> </div></div>"
            controls += "<div id='heatmapSlider' style='width:95%'></div>"

            # Other
            controls += "<br>"
            controls += "<h4 class='clean_shrink'>Other</h4>"

            #marker checkbox
            controls += '<div class="inner_control_div">'
            controls += "<input id='markerBox' type='checkbox' name='marker_selector' #{if @visibleMarkers is 1 then 'checked' else ''}/> Display Markers "
            controls += "</div>"
            
            #marker line checkbox
            if @timeLines?
              controls += '<div class="inner_control_div">'
              controls += "<input id='lineBox' type='checkbox' name='line_selector' #{if @visibleLines is 1 then 'checked' else ''}/> Connect Markers "
              controls += "</div>"
            
            #cluster checkbox
            controls += '<div class="inner_control_div">'
            controls += "<input id='clusterBox' type='checkbox' name='cluster_selector' #{if @visibleClusters is 1 then 'checked' else ''}/> Cluster Markers "
            controls += "</div>"
            
            
            controls += "</div></div>"

            # Write HTML
            ($ '#controldiv').append controls

            ($ '#markerBox').click (e) =>
              @visibleMarkers = if e.target.checked then 1 else 0
              @delayedUpdate()
                
            ($ '#lineBox').click (e) =>
              @visibleLines = if e.target.checked then 1 else 0
              @delayedUpdate()
                
            ($ '#clusterBox').click (e) =>
              @visibleClusters = if e.target.checked then 1 else 0
              @clusterer.setMaxZoom (if @visibleClusters then 17 else -1)
              @delayedUpdate()

            # Make heatmap select handler
            ($ '#heatmapSelector').change (e) =>
              element = e.target or e.srcElement
              @heatmapSelection = (Number element.value)
              
              @delayedUpdate()
            
            #Set up heatmap entry
            ($ '#radiusText').keydown (e) =>
              if e.which == 13
                newRadius = Number ($ '#radiusText').val()
                if isNaN newRadius
                  ($ '#radiusText').errorFlash()
                  return
                #Guess new pixel radius
                @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * newRadius / @heatmapRadius)
                @heatmapRadius = newRadius
                ($ '#heatmapSlider').slider "value", (Math.log @heatmapRadius) / (Math.log 10)
                @delayedUpdate()
            
            #Set up heatmap slider
            ($ '#heatmapSlider').slider
              range: 'min'
              value: (Math.log @heatmapRadius) / (Math.log 10)
              min: 0
              max: 6
              values: 0
              slide: (event, ui) =>
                newRadius = Math.pow(10, Number ui.value)
                #Guess new pixel radius
                @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * newRadius / @heatmapRadius)
                @heatmapRadius = newRadius
                ($ '#radiusText').val("#{@heatmapRadius}")
                @delayedUpdate()
            
            #Set up accordion
            globals.toolsOpen ?= 0

            ($ '#toolControl').accordion
              collapsible:true
              active:globals.toolsOpen

            ($ '#toolControl > h3').click ->
              globals.toolsOpen = (globals.toolsOpen + 1) % 2

        resize: (newWidth, newHeight, duration) ->
          func = =>
              google.maps.event.trigger @gmap, 'resize'
          setTimeout func, duration
            
        getPixelDiag: () ->
          ww = ($ "##{@canvas}").width()
          hh = ($ "##{@canvas}").height()
          Math.sqrt(ww*ww + hh*hh)
          
        getDiag: (latlngbounds = @gmap.getBounds()) ->
          google.maps.geometry.spherical.computeDistanceBetween latlngbounds.getNorthEast(), latlngbounds.getSouthWest()
          
        getHeatmapScale: () ->
          viewBounds = @gmap.getBounds()
          # Extends bounds by radius of heatmap
          # There are 111,329 meters per degree of longitude at the equator
          sw = viewBounds.getSouthWest()
          ss = sw.lat() - @heatmapRadius / 111329
          ww = sw.lng() - @heatmapRadius / (Math.cos(sw.lat() * Math.PI / 180) * 111329)
          sw = new google.maps.LatLng(ss, ww)
          
          ne = viewBounds.getNorthEast()
          nn = ne.lat() + @heatmapRadius / 111329
          ee = ne.lng() + @heatmapRadius / (Math.cos(ne.lat() * Math.PI / 180) * 111329)
          ne = new google.maps.LatLng(nn, ee)
          
          viewBounds = new google.maps.LatLngBounds(sw, ne)
          heatBounds = new google.maps.LatLngBounds()
          
          for markGroup, index in @markers when index in globals.groupSelection
            for mark in markGroup 
              if viewBounds.contains mark.getPosition()
                heatBounds.extend mark.getPosition()
          
          if not heatBounds.isEmpty()
            dist = google.maps.geometry.spherical.computeDistanceBetween heatBounds.getNorthEast(), heatBounds.getSouthWest()
            
            a = @projOverlay.projectPixels(heatBounds.getNorthEast())
            b = @projOverlay.projectPixels(heatBounds.getSouthWest())
            
            pixelDist = Math.sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y))
            
            pixelDensity = dist / pixelDist
            newRad = Math.ceil(@heatmapRadius / pixelDensity)
            maxRad = Math.ceil(@getPixelDiag() / 4)
            
            # Single point check
            if pixelDist is 0
              newRad = Math.ceil(@heatmapRadius * (@getPixelDiag() / @getDiag()))
            
            if newRad <= maxRad
              ($ '#heatmapErrorText').html ''
              return newRad
            else
              act = Math.ceil(maxRad * (@getDiag() / @getPixelDiag()))
              ($ '#heatmapErrorText').html "The radius had to be decreased to #{act}m for performance reasons. It will restore to your selection as the map is zoomed out."
              return maxRad
          else
            return @heatmapPixelRadius
            
    if "Map" in data.relVis
      globals.map = new Map "map_canvas"
    else
      globals.map = new DisabledVis "map_canvas"
            