# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "visualizations" and namespace.action is "index"
 
    $("#visualizations_search").submit ->
        $.ajax
          url: this.action
          data: $(this).serialize()
          success: (data, textStatus)->
            
            $('#visualizations').isotope('remove', $('.item'))
      
            for object in data
              do (object) ->
                newItem =   "<div class='item'>"

                if(object.mediaSrc)
                  newItem += "<img src='#{object.mediaSrc}'></img>"
                  
                newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.url}'>#{object.name}</a>"
                
                if(object.featured)
                  newItem += "<span style='color:#57C142'> (featured)</span>"
              
                newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />"
                newItem +=  "<b>Project: </b><a href='#{object.projectUrl}'>#{object.projectName}</a><br />"
                newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"
                
                ###
                if(object.filters)
                  newitem += "<b>#{object.filters}</b>"
                ###
                
                newItem +=  "</div>"
                
                newItem = $(newItem)
                
                $('#visualizations').append(newItem).isotope('insert', newItem)
            
            $(window).resize()
            
          dataType: "json"
        return false
        
    ($ '.visualizations_filter_checkbox').click ->
      ($ '#visualizations_search').submit()
      
    ($ '.visualizations_sort_select').change ->
      ($ '#visualizations_search').submit()
      
    $(".visualizations_sort_select").change ->
      $("#visualizations_search").submit()
      
    ### Get isotope up and running ###

    numCols = 1

    while $('#visualizations').width()/numCols>200
      numCols++

    $('#visualizations').imagesLoaded ->
      $('.item').width(($('#visualizations').width()/numCols)-35)
      $('#visualizations').isotope
        itemSelector : '.item'
        layoutMode : 'masonry'
        masonry:
          columnWidth: $('#visualizations').width()/numCols
          
    $("#visualizations_search").submit()

    window.reLayout = ->

      numCols = 1

      while $('#visualizations').width()/numCols>200
        numCols++
      
      $('#visualizations').imagesLoaded ->

        $('.item').width(($('#visualizations').width()/numCols)-35)

        $('#visualizations').isotope
          itemSelector : '.item'
          layoutMode : 'masonry'
          masonry:
            columnWidth: $('#visualizations').width()/numCols
      true

    $(window).resize reLayout  
        