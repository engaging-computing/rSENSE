# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(".liked_status").click ->
    icon = $(@).children('i')
    if icon.attr('class').indexOf('icon-star-empty') != -1
      icon.replaceWith('<i class="icon-star"></i>')
    else
      icon.replaceWith('<i class="icon-star-empty"></i>')
    $.ajax
      url: "/experiments/"+$(this).attr("exp_id")+"/updateLikedStatus"
      dataType: "json"
      success: (resp) =>
        $(@).siblings(".like_display").html resp['update']

  $("#experiments .pagination a").live("click", ->
      $.getScript(this.href)
      return false)

  testtt = (data,textStatus) ->
    console.log data
    console.log "PARP"

  $("#experiments_search").submit ->
      $.ajax
        url: this.action
        data: $(this).serialize()
        success: (data, textStatus)->
          
          $('#experiments').isotope('remove', $('.item'))
          
          for object in data
            do (object) ->
              newItem =   "<div class='item'>"
              
              if(object.mediaPath)
                newItem += "<img src='#{object.mediaPath}'></img>"
                
              newItem +=  "<h4>#{object.title}"
              
              if(object.featured)
                newItem += "<span style='color:#57C142'> (featured)</span>"
            
              newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerPath}'>#{object.ownerName}</a><br />"
              newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"
              
              ###
              if(object.filters)
                newitem += "<b>#{object.filters}</b>"
              ###
              
              newItem +=  "</div>"
              
              newItem = $(newItem)
              
              $('#experiments').append(newItem).isotope('insert', newItem)
          
          $(window).resize()
          
        dataType: "json"  
        error: (data) ->
          console.log data
      return false
      
  $(".experiments_filter_checkbox").click ->
    $("#experiments_search").submit()
    
  $(".experiments_sort_select").change ->
    $("#experiments_search").submit()
    
  ### Get isotope up and running ###

  numCols = 1

  while $('#experiments').width()/numCols>200
    numCols++

  $('#experiments').imagesLoaded ->
    $('.item').width(($('#experiments').width()/numCols)-35)
    $('#experiments').isotope
      itemSelector : '.item'
      layoutMode : 'masonry'
      masonry:
        columnWidth: $('#experiments').width()/numCols

window.reLayout = ->

  numCols = 1

  while $('#experiments').width()/numCols>300
    numCols++
  
  $('#experiments').imagesLoaded ->

    $('.item').width(($('#experiments').width()/numCols)-35)

    $('#experiments').isotope
      itemSelector : '.item'
      layoutMode : 'masonry'
      masonry:
        columnWidth: $('#experiments').width()/numCols

    

    ###
    $('#experiments').isotope( 'option', { masonry: { columnWidth: ($('#experiments').width() / numCols) } } )
    
    $('#experiments').isotope('reLayout')
    ###
  
  true

$(window).resize reLayout