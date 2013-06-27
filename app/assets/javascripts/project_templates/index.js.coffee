# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "project_templates" and namespace.action is "index"

    $("#project_templates_search").submit ->
        $.ajax
          url: this.action
          data: $(this).serialize()
          success: (data, textStatus)->
            
            $('#project_templates').isotope('remove', $('.item'))
            
            for object in data
              do (object) ->
                newItem =   "<div class='item'>"
    
                if(object.mediaSrc)
                  newItem += "<img src='#{object.mediaSrc}'></img>"
                  
                newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.url}'>#{object.name}</a>"
                
                if(object.featured)
                  newItem += "<span style='color:#57C142'> (featured)</span>"
            
                newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />"
                newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"
                
                ###
                if(object.filters)
                  newitem += "<b>#{object.filters}</b>"
                ###
                
                newItem +=  "</div>"
                
                newItem = $(newItem)
                
                $('#project_templates').append(newItem).isotope('insert', newItem)
            
            $(window).resize()
            
          dataType: "json"
        return false

    ($ '.project_templates_filter_checkbox').click ->
      ($ '#project_templates_search').submit()
      
    ($ '.project_templates_sort_select').change ->
      ($ '#project_templates_search').submit()
      
    $(".project_templates_sort_select").change ->
      $("#project_templates_search").submit()

    ### Get isotope up and running ###

    numCols = 1

    while $('#project_templates').width()/numCols>200
      numCols++

    $('#project_templates').imagesLoaded ->
    
      $('.item').width(($('#project_templates').width()/numCols)-35)
      $('#project_templates').isotope
        itemSelector : '.item'
        layoutMode : 'masonry'
        masonry:
          columnWidth: $('#project_templates').width()/numCols

    $("#project_templates_search").submit()

    window.reLayout = ->

      numCols = 1

      while $('#project_templates').width()/numCols>200
        numCols++

      $('#project_templates').imagesLoaded ->

        $('.item').width(($('#project_templates').width()/numCols)-35)

        $('#project_templates').isotope
          itemSelector : '.item'
          layoutMode : 'masonry'
          masonry:
            columnWidth: $('#project_templates').width()/numCols
      true

    $(window).resize reLayout