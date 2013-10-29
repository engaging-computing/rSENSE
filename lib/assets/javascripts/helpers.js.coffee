$ ->

  window.helpers ?= {}

  helpers.truncate = (str, length) ->
    if str.length > length
      str = str.substr(0, length - 3) + '...'
    else
      str
  
  helpers.get_field_name = (type) ->
    switch type
      when 1 then "Timestamp"
      when 2 then "Number"
      when 3 then "Text"
      when 4 then "Latitude"
      when 5 then "Longitude"

  helpers.get_field_type = (name) ->
    switch name
      when "Timestamp" then 1
      when "Number"    then 2
      when "Text"      then 3
      when "Latitude"  then 4
      when "Longitude" then 5

  helpers.get_default_unit = (type) ->
    switch type
      when 1 then ""
      when 2 then ""
      when 3 then ""
      when 4 then "deg"
      when 5 then "deg"

  $.fn.errorFlash = () ->
    this.effect "highlight", {color: "#F00"}, 2000
    
  $.fn.hide_row = (callback = null) ->
  
    prop = 
      height: "0px"
      opacity: 0
      
    options =
      duration: 400
      always: () ->
        ($ this).hide()
        if callback isnt null
          callback()
  
    this.animate prop, options
    
  helpers.confirm_delete = (objName) ->
    confirm("Are you sure you want to delete #{objName}?")
    
  helpers.isotope_layout = (selector, colWidth = 200, colSep = 16) ->
  
    numCols = 1

    while $(selector).width()/numCols>colWidth
      numCols++

    $(selector).imagesLoaded ->

      $('.item').width(($(selector).width()/numCols)-colSep)

      $(selector).isotope
        itemSelector : '.item'
        layoutMode : 'masonry'
        masonry:
          columnWidth: $(selector).width()/numCols
    true
    
  $.fn.delete_row = (callback = null)->
    $(@).find('div, input').each ->
      prop = 
        height: "0px"
        opacity: 0
          
      options =
        duration: 400
        always: () ->
          ($ this).hide()
          if callback isnt null
            callback()
    
      ($ this).animate prop, options

  
  $.fn.recolor_rows = (recolored = false)-> 
    if not recolored
      ($ @).find("tr").each (idx) -> 
        if idx % 2 is 0
          ($ @).addClass 'feed-even'
          ($ @).removeClass 'feed-odd'
        else
          ($ @).removeClass 'feed-even'
          ($ @).addClass 'feed-odd'    