$ ->
  if namespace.controller is "data_sets" and namespace.action is "manualEntry"

    settings =
      buttons: ['close', 'add', 'save']
      bootstrapify: true
      upload:
        ajaxify: true
        url: window.postURL
        method: 'POST'
      debug: true

    ($ '#manualTable').editTable(settings)

    initialize = ->
      latlng = new google.maps.LatLng(41.659,-4.714)
      options =
        zoom: 16
        center: latlng
      window.map = new google.maps.Map(document.getElementById("map_canvas"), options)
    
      window.geocoder = new google.maps.Geocoder()
      
      marker_options = 
        map: window.map
        draggable: true
      
      window.marker = new google.maps.Marker marker_options
      
      google.maps.event.addListener window.marker, 'dragend', ->
        window.geocoder.geocode {'latLng': window.marker.getPosition()},(results, status) ->
          if (status == google.maps.GeocoderStatus.OK)
            if (results[0]) 
              $('#address').val(results[0].formatted_address)
              $('#latitude').val(window.marker.getPosition().lat())
              $('#longitude').val(window.marker.getPosition().lng())
    
    initialize()
    
    ($ "#address").autocomplete
      #This bit uses the geocoder to fetch address values
      source: (request, response) ->
        window.geocoder.geocode {'address': request.term }, (results, status) ->
          response $.map results, (item) ->
            x =
              label:  item.formatted_address
              value: item.formatted_address
              latitude: item.geometry.location.lat()
              longitude: item.geometry.location.lng() 
      #This bit is executed upon selection of an address
      select: (event, ui) -> 
        ($ "#latitude").val(ui.item.latitude)
        ($ "#longitude").val(ui.item.longitude)
        location = new google.maps.LatLng(ui.item.latitude, ui.item.longitude)
        window.marker.setPosition(location)
        window.map.setCenter(location)
        



