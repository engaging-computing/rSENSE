# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"

    $("#projects_search").submit ->
        $.ajax
          url: this.action
          data: $(this).serialize()
          success: (data, textStatus)->
            
            $('#projects').isotope('remove', $('.item'))
            
            addProjectButton = $("<div id='addProjectButton' style='text-align:center;cursor: pointer;' class='item'><img style='width:66%;' class='hoverimage' src='/assets/green_plus_icon.svg'><br /><h4 style='color:#0a0;'>Create Project</h4></img></div>")
            
            $('#projects').append(addProjectButton).isotope('insert', addProjectButton)
            
            $('#addProjectButton').click ->
              token = $("meta[name='csrf-token']").attr('content')
              form = ($ "<form action='/projects/create' method='post'> <input type='hidden' name='authenticity_token' value='#{token}'> </form>")
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
                
                $('#projects').append(newItem).isotope('insert', newItem)
            
            $(window).resize()
            
          dataType: "json"
        return false
        
    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
      
    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()
      

      
    grab_ses = (t) ->
      ses = ($ t).attr 'id'
      ses = ses.split '_'
      ses[3]
      
      
    $(".projects_sort_select").change ->
      $("#projects_search").submit()
      
    ### Get isotope up and running ###

    numCols = 1

    while $('#projects').width()/numCols>200
      numCols++

    $('#projects').imagesLoaded ->
      $('.item').width(($('#projects').width()/numCols)-35)
      $('#projects').isotope
        itemSelector : '.item'
        layoutMode : 'masonry'
        masonry:
          columnWidth: $('#projects').width()/numCols
          
    $("#projects_search").submit()

    window.reLayout = ->

      numCols = 1

      while $('#projects').width()/numCols>200
        numCols++
      
      $('#projects').imagesLoaded ->

        $('.item').width(($('#projects').width()/numCols)-35)

        $('#projects').isotope
          itemSelector : '.item'
          layoutMode : 'masonry'
          masonry:
            columnWidth: $('#projects').width()/numCols
      true

    $(window).resize reLayout