# Place all the behaviors and hooks related to the users index page here.
$ ->
  if namespace.controller is "users" and namespace.action is "index"
    $("#users_search").submit ->
        $.ajax
          url: this.action
          data: $(this).serialize()
          success: (data, textStatus)->

            $('#users').isotope('remove', $('.item'))

            for object in data
              do (object) ->
                newItem =   "<div class='item' align='center'>"
                  
                newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.url}'>#{object.username}</a>"

                newItem += "</h4>"
                
                if (object.gravatar) != null
                  newItem += "<img src='#{object.gravatar}'> </img><br />"

                newItem +=  "<h8><b>Name: </b><a href='#{object.url}'>#{object.name}</a></h8><br />"

                newItem +=  "<h8><b>Member Since: </b>#{object.createdAt}</h8><br />"

                newItem +=  "</div>"

                newItem = $(newItem)
              
                $('#users').append(newItem).isotope('insert', newItem)
            
            $(window).resize()
            
          dataType: "json"
        return false
    
    $(".users_sort_select").change ->
      $("#users_search").submit()

      
    ### Get isotope up and running ###
    numCols = 1

    while $('#users').width()/numCols>200
      numCols++

    $('#users').imagesLoaded ->
      $('.item').width(($('#users').width()/numCols)-35)
      $('#users').isotope
        itemSelector : '.item'
        layoutMode : 'masonry'
        masonry:
          columnWidth: $('#users').width()/numCols
          
    $("#users_search").submit()

    window.reLayout = ->

      numCols = 1

      while $('#users').width()/numCols>200
        numCols++
      
      $('#users').imagesLoaded ->

        $('.item').width(($('#users').width()/numCols)-35)

        $('#users').isotope
          itemSelector : '.item'
          layoutMode : 'masonry'
          masonry:
            columnWidth: $('#users').width()/numCols
      true

    $(window).resize reLayout