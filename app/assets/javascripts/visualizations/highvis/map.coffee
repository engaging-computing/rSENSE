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

    class window.Map extends BaseVis
      constructor: (@canvas) ->
        super(@canvas)

        @HEATMAP_NONE = -2
        @HEATMAP_MARKERS = -1

        @configs.visibleMarkers = 1
        @configs.visibleLines = 0
        @configs.visibleClusters = if data.dataPoints.length > 100 then 1 else 0
        @configs.heatmapSelection = @HEATMAP_NONE
        @configs.mapTypeId ?= google.maps.MapTypeId.ROADMAP

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
        ################ PLUGIN INIT ###############
        # Gmaps
        latlngbounds = new google.maps.LatLngBounds()

        mapOptions =
          center: new google.maps.LatLng(0,0)
          zoom: 0
          mapTypeId: @configs.mapTypeId
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
        @oms.addListener 'unspiderfy', () ->
          info.close()

        # Clusterer
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
          maxZoom: if @configs.visibleClusters then 17 else -1
          gridSize: 35
          ignoreHidden: true
          styles: clusterStyles
        ################################################

        for dataPoint in globals.CLIPPING.getData(data.dataPoints)
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

            groupIndex = data.groups.indexOf dataPoint[globals.configs.groupById].toLowerCase()
            color = globals.configs.colors[groupIndex % globals.configs.colors.length]

            latlng = new google.maps.LatLng(lat, lon)

            # Put aside line info if necessary
            if @timeLines? and dataPoint[data.timeFields[0]] isnt null and not(isNaN dataPoint[data.timeFields[0]])
              @timeLines[groupIndex].push
                time: dataPoint[data.timeFields[0]]
                latlng: latlng

            # Build info window content
            label  = "<div style='font-size:9pt;overflow-x:none;'>"
            label += "<div style='width:100%;text-align:center;color:#{color};'> " +
              "#{dataPoint[globals.configs.groupById]}</div><br>"

            if data.metadata[groupIndex].photos.length == 1
              photo = data.metadata[groupIndex].photos[0]
              label += "<div class='item'>
                          <img class='item-image item-photo-image' src=#{photo.src} >
                        </div>
                        </br>"

            else if data.metadata[groupIndex].photos.length > 0
              label += "<div id='mapCarousel' class='carousel slide' data-ride='carousel' data-interval='false'>
                        <div class='carousel-inner' role='listbox'>"

              firstPhoto = data.metadata[groupIndex].photos[0]
              label += "<div class='item active'>
                          <img class='item-image item-photo-image' src=#{firstPhoto.src} >
                        </div>"

              for i in [1...data.metadata[groupIndex].photos.length]
                label +=  "<div class='item'>
                            <img class='item-image item-photo-image' src = #{data.metadata[groupIndex].photos[i].src} >
                          </div>"

              label +=  "</div>
                          <a class='left carousel-control' href='#mapCarousel' role='button'
                          	data-slide='prev'><span class='glyphicon glyphicon-chevron-left'></span></a>
                          <a class='right carousel-control' href='#mapCarousel' role='button'
                          	data-slide='next'><span class='glyphicon glyphicon-chevron-right'></span></a>
                        </div> </br>"

            label += "<table>"

            for field, fieldIndex in data.fields when dataPoint[fieldIndex] isnt null
              dat = if (Number field.typeID) is data.types.TIME
                (globals.dateFormatter dataPoint[fieldIndex])
              else
                dataPoint[fieldIndex]

              label += "<tr><td>#{field.fieldName}</td>"
              label += "<td><strong>#{dat}</strong></td></tr>"

            label += "</table></div>"

            if groupIndex in data.groupSelection
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
              visible: ((groupIndex in data.groupSelection) and @configs.visibleMarkers is 1)

            @oms.addMarker newMarker

            @markers[groupIndex].push newMarker

            for index in data.normalFields when dataPoint[index] isnt null
              @heatPoints[index][groupIndex].push
                weight: dataPoint[index]
                val: dataPoint[index]
                location: latlng

            @heatPoints[@HEATMAP_MARKERS][groupIndex].push latlng

        # Add markers into the clusterer
        @clusterer.addMarkers [].concat.apply([], @markers)

        # Produce time lines if available
        if @timeLines?
          for lineArr, index in @timeLines
            @timeLines[index].sort (a, b) -> (a.time - b.time)
            @timeLines[index] = @timeLines[index].map (a) -> a.latlng
            @timeLines[index] = new google.maps.Polyline
              path: @timeLines[index]
              geodesic: true
              strokeColor: globals.configs.colors[index]
              strokeOpacity: 1.0
              strokeWeight: 2
              visible: ((index in data.groupSelection) and @configs.visibleLines is 1)

            @timeLines[index].setMap(@gmap)

        # Deal with zoom
        if @configs.zoomLevel?
          @gmap.setZoom @configs.zoomLevel

        # Figure default heatmap
        if not @configs.heatmapRadius?
          @configs.heatmapRadius = 1
          dist = @getDiag(latlngbounds)
          pixelDist = @getPixelDiag()
          dpp = pixelDist / dist

          # Make sure the radius is at least 10px
          while @configs.heatmapRadius * dpp < 10
            @configs.heatmapRadius *= 10

        # Deal with zoom area
        if @configs.savedCenter?
          @gmap.setCenter new google.maps.LatLng(@configs.savedCenter.lat, @configs.savedCenter.lng)
        else
          @gmap.fitBounds(latlngbounds)

        @drawControls()

        finalInit = =>
          @configs.zoomLevel = @gmap.getZoom()
          google.maps.event.addListener @gmap, "zoom_changed", =>
            newZoom = @gmap.getZoom()
            if @configs.heatmapSelection isnt @HEATMAP_NONE
              # Guess new radius
              @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * Math.pow(2, newZoom - @configs.zoomLevel))
              @delayedUpdate()
            @configs.zoomLevel = newZoom

          google.maps.event.addListener @gmap, "bounds_changed", =>
            cen = @gmap.getCenter()
            @configs.savedCenter =
              lat: cen.lat()
              lng: cen.lng()

          google.maps.event.addListener @gmap, "dragend", =>
            # Update if the projection has changed enough to disturb the heatmap
            if @configs.heatmapSelection isnt @HEATMAP_NONE
              if @getHeatmapScale() isnt @heatmapPixelRadius
                @delayedUpdate()

          # Calls update to draw heatmap on start
          if @configs.heatmapSelection isnt @HEATMAP_NONE
            @delayedUpdate()

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
        if @configs.heatmapSelection isnt @HEATMAP_NONE

          @heatmapPixelRadius = @getHeatmapScale()

          heats = []
          for index, heatArray of @heatPoints when (Number index) is @configs.heatmapSelection
            for groupArray, groupIndex in heatArray when groupIndex in data.groupSelection
              heats = heats.concat groupArray

          if @configs.heatmapSelection >= 0
            coords = []
            for heat in heats
              coords.push @projOverlay.projectPixels heat.location

            for heat, hIndex in heats
              ori = @projOverlay.projectPixels heat.location
              # Distance to origin function
              dist = (a) -> Math.sqrt((a.x - ori.x) * (a.x - ori.x) + (a.y - ori.y) * (a.y - ori.y))
              # Get all points within one radius of origin
              neighbors = (coords.map(dist)).filter (a) => return a < (@heatmapPixelRadius)
              # Reverse the distance, and raise to power (for weighting)
              neighbors = neighbors.map (a) => Math.pow((@heatmapPixelRadius) - a, 3)
              # Scale by reciprical
              neighbors = neighbors.map (a) => a / Math.pow((@heatmapPixelRadius), 3)
              # Finally, add together to get weight
              add = (a,b) -> a + b
              heats[hIndex].weight = heat.val / neighbors.reduce(add, 0)

          # Draw heatmap
          @heatmap = new google.maps.visualization.HeatmapLayer
            data: heats
            radius: @heatmapPixelRadius
            dissipating:true
          @heatmap.setMap @gmap

        # Set marker visibility
        for markGroup, index in @markers
          for mark in markGroup
            mark.setVisible ((index in data.groupSelection) and @configs.visibleMarkers is 1)

          if @timeLines?
            @timeLines[index].setVisible ((index in data.groupSelection) and @configs.visibleLines is 1)

        @clusterer.repaint()

        super()

      end: ->
        @heatmap = undefined
        if @gmap?
          @configs.mapType = @gmap.getMapTypeId()

        super()

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
        controls += '<select id="heatmapSelector" class="form-control">'

        sel = if @configs.heatmapSelection is @HEATMAP_NONE then 'selected' else ''
        controls += "<option value=\"#{@HEATMAP_NONE}\" #{sel}>None</option>"

        sel = if @configs.heatmapSelection is @HEATMAP_MARKERS then 'selected' else ''
        controls += "<option value=\"#{@HEATMAP_MARKERS}\" #{sel}>Marker Density</option>"

        for fieldIndex in data.normalFields
          sel = if @configs.heatmapSelection is fieldIndex then 'selected' else ''
          controls += "<option value=\"#{Number fieldIndex}\" #{sel}>#{data.fields[fieldIndex].fieldName}</option>"

        controls += "</select></div>"

        # Heatmap slider
        controls += "<br>"
        controls += "<div class='inner_control_div'> Heatmap Radius: "
        controls += "<input id='radius-text' value='#{@configs.heatmapRadius}'></input>m</div>"
        controls += "<div class='inner_control_div'> <div id='heatmap-error-text'> </div></div>"
        controls += "<div id='heatmapSlider' style='width:95%'></div>"

        # Other
        controls += "<br>"
        controls += "<h4 class='clean_shrink'>Other</h4>"

        # Marker checkbox
        controls += '<div class="inner_control_div">'
        controls += "<input id='markerBox' type='checkbox' name='marker_selector' "
        controls += "#{if @configs.visibleMarkers is 1 then 'checked' else ''}/> Display Markers "
        controls += "</div>"

        # Marker line checkbox
        if @timeLines?
          controls += '<div class="inner_control_div">'
          controls += "<input id='lineBox' type='checkbox' name='line_selector' "
          controls += "#{if @configs.visibleLines is 1 then 'checked' else ''}/> Connect Markers "
          controls += "</div>"

        # Cluster checkbox
        controls += '<div class="inner_control_div">'
        controls += "<input id='clusterBox' type='checkbox' name='cluster_selector' "
        controls += "#{if @configs.visibleClusters is 1 then 'checked' else ''}/> Cluster Markers "
        controls += "</div>"


        controls += "</div></div>"

        # Write HTML
        ($ '#controldiv').append controls

        ($ '#markerBox').click (e) =>
          @configs.visibleMarkers = if e.target.checked then 1 else 0
          @delayedUpdate()

        ($ '#lineBox').click (e) =>
          @configs.visibleLines = if e.target.checked then 1 else 0
          @delayedUpdate()

        ($ '#clusterBox').click (e) =>
          @configs.visibleClusters = if e.target.checked then 1 else 0
          @clusterer.setMaxZoom (if @configs.visibleClusters then 17 else -1)
          @delayedUpdate()

        # Make heatmap select handler
        ($ '#heatmapSelector').change (e) =>
          element = e.target or e.srcElement
          @configs.heatmapSelection = (Number element.value)

          @delayedUpdate()

        # Set up heatmap entry
        ($ '#radius-text').keydown (e) =>
          if e.which == 13
            newRadius = Number ($ '#radius-text').val()
            if isNaN newRadius
              ($ '#radius-text').errorFlash()
              return
            # Guess new pixel radius
            @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * newRadius / @configs.heatmapRadius)
            @configs.heatmapRadius = newRadius
            ($ '#heatmapSlider').slider "value", (Math.log @configs.heatmapRadius) / (Math.log 10)
            @delayedUpdate()

        # Set up heatmap slider
        ($ '#heatmapSlider').slider
          range: 'min'
          value: (Math.log @configs.heatmapRadius) / (Math.log 10)
          min: 0
          max: 6
          values: 0
          slide: (event, ui) =>
            newRadius = Math.pow(10, Number ui.value)
            # Guess new pixel radius
            @heatmapPixelRadius = Math.ceil(@heatmapPixelRadius * newRadius / @configs.heatmapRadius)
            @configs.heatmapRadius = newRadius
            ($ '#radius-text').val("#{@configs.heatmapRadius}")
            @delayedUpdate()

        # Set up accordion
        globals.configs.toolsOpen ?= 0

        ($ '#toolControl').accordion
          collapsible:true
          active:globals.configs.toolsOpen

        ($ '#toolControl > h3').click ->
          globals.configs.toolsOpen = (globals.configs.toolsOpen + 1) % 2

      resize: (newWidth, newHeight, duration) ->
        func = =>
          google.maps.event.trigger @gmap, 'resize'
        setTimeout func, duration

      getPixelDiag: () ->
        ww = ($ "##{@canvas}").width()
        hh = ($ "##{@canvas}").height()
        Math.sqrt(ww * ww + hh * hh)

      getDiag: (latlngbounds = @gmap.getBounds()) ->
        google.maps.geometry.spherical.computeDistanceBetween(
          latlngbounds.getNorthEast(), latlngbounds.getSouthWest())

      getHeatmapScale: () ->
        viewBounds = @gmap.getBounds()
        # Extends bounds by radius of heatmap
        # There are 111,329 meters per degree of longitude at the equator
        sw = viewBounds.getSouthWest()
        ss = sw.lat() - @configs.heatmapRadius / 111329
        ww = sw.lng() - @configs.heatmapRadius / (Math.cos(sw.lat() * Math.PI / 180) * 111329)
        sw = new google.maps.LatLng(ss, ww)

        ne = viewBounds.getNorthEast()
        nn = ne.lat() + @configs.heatmapRadius / 111329
        ee = ne.lng() + @configs.heatmapRadius / (Math.cos(ne.lat() * Math.PI / 180) * 111329)
        ne = new google.maps.LatLng(nn, ee)

        viewBounds = new google.maps.LatLngBounds(sw, ne)
        heatBounds = new google.maps.LatLngBounds()

        for markGroup, index in @markers when index in data.groupSelection
          for mark in markGroup
            if viewBounds.contains mark.getPosition()
              heatBounds.extend mark.getPosition()

        if not heatBounds.isEmpty()
          dist = google.maps.geometry.spherical.computeDistanceBetween(
            heatBounds.getNorthEast(), heatBounds.getSouthWest())

          a = @projOverlay.projectPixels(heatBounds.getNorthEast())
          b = @projOverlay.projectPixels(heatBounds.getSouthWest())

          pixelDist = Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))

          pixelDensity = dist / pixelDist
          newRad = Math.ceil(@configs.heatmapRadius / pixelDensity)
          maxRad = Math.ceil(@getPixelDiag() / 4)

          # Single point check
          if pixelDist is 0
            newRad = Math.ceil(@configs.heatmapRadius * (@getPixelDiag() / @getDiag()))

          if newRad <= maxRad
            ($ '#heatmap-error-text').html ''
            return newRad
          else
            act = Math.ceil(maxRad * (@getDiag() / @getPixelDiag()))
            ($ '#heatmap-error-text').html(
              "The radius had to be decreased to #{act}m for performance reasons. " +
              "It will restore to your selection as the map is zoomed out."
            )
            return maxRad
        else
          return @heatmapPixelRadius

      clip: (arr) ->
        viewBounds = @gmap.getBounds()
        if viewBounds?
          filterFunc = (row) ->
            lat = lng = null

            # Scan for lat and long
            for field, fieldIndex in data.fields
              if (Number field.typeID) in data.types.LOCATION
                if (Number field.typeID) is data.units.LOCATION.LATITUDE
                  lat = row[fieldIndex]
                else if (Number field.typeID) is data.units.LOCATION.LONGITUDE
                  lng = row[fieldIndex]

            # If points are valid, check if they are visible
            if (lat is null) or (lng is null)
              return false
            else return viewBounds.contains(new google.maps.LatLng(lat, lng))

          arr.filter filterFunc

        else arr

    if "Map" in data.relVis
      class CanvasProjectionOverlay extends google.maps.OverlayView
        constructor: ->
        onAdd: ->
        draw: ->
        onRemove: ->
        projectPixels: (latlng) ->
          @getProjection().fromLatLngToContainerPixel(latlng)

      globals.map = new Map "map_canvas"
    else
      globals.map = new DisabledVis "map_canvas"
