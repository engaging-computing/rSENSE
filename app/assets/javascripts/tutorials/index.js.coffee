# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "tutorials" and namespace.action is "index"
      $("#tutorials_search").submit ->
          $.ajax
            url: this.action
            data: $(this).serialize()
            success: (data, textStatus)->
              
              $('#tutorials').isotope('remove', $('.item'))
              
              addProjectButton = $("<div id='addProjectButton' style='text-align:center;cursor: pointer;' class='item'><img style='width:66%;' class='hoverimage' src='/assets/green_plus_icon.svg'><br /><h4 style='color:#0a0;'>Create Tutorial</h4></img></div>")
              
              $('#tutorials').append(addProjectButton).isotope('insert', addProjectButton)
              
              $('#addProjectButton').click ->
                token = $("meta[name='csrf-token']").attr('content')
                form = ($ "<form action='/tutorials/create' method='post'> <input type='hidden' name='authenticity_token' value='#{token}'> </form>")
                ($ "body").append(form)
                ($ form).submit()
              
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
                  
                  $('#tutorials').append(newItem).isotope('insert', newItem)
              
              $(window).resize()
              
            dataType: "json"
          return false
        
      ($ '.tutorials_sort_select').change ->
        ($ '#tutorials_search').submit()
        

        
      grab_ses = (t) ->
        ses = ($ t).attr 'id'
        ses = ses.split '_'
        ses[3]
        
        
      $(".tutorials_sort_select").change ->
        $("#tutorials_search").submit()
        
      ### Get isotope up and running ###

      numCols = 1

      while $('#tutorials').width()/numCols>200
        numCols++

      $('#tutorials').imagesLoaded ->
        $('.item').width(($('#tutorials').width()/numCols)-35)
        $('#tutorials').isotope
          itemSelector : '.item'
          layoutMode : 'masonry'
          masonry:
            columnWidth: $('#tutorials').width()/numCols
            
      $("#tutorials_search").submit()

      window.reLayout = ->

        numCols = 1

        while $('#tutorials').width()/numCols>200
          numCols++
        
        $('#tutorials').imagesLoaded ->

          $('.item').width(($('#tutorials').width()/numCols)-35)

          $('#tutorials').isotope
            itemSelector : '.item'
            layoutMode : 'masonry'
            masonry:
              columnWidth: $('#tutorials').width()/numCols
        true

      $(window).resize reLayout