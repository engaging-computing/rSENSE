$ ->
  window.helpers = {}

  $.fn.highlight = (aniLen) ->
    @.css('background-color', '#FFFF99')
    @.addClass('flash')
    flash = () => @.css('background-color', '')
    end   = () => @.removeClass('flash')
    setTimeout(flash, aniLen)
    setTimeout(end, aniLen + 500)

  $.fn.hide_row = (callback = null) ->
    prop =
      height: "0px"
      opacity: 0

    options =
      duration: 400
      always: () ->
        $(@).hide()
        if callback isnt null
          callback()

    @.animate(prop, options)

  helpers.confirm_delete = (objName) ->
    confirm("Are you sure you want to delete #{objName}?")

  $.fn.delete_row = (callback = null) ->
    $(@).find('div, input').each ->
      prop =
        height: "0px"
        opacity: 0

      options =
        duration: 400
        always: () ->
          $(@).hide()
          if callback isnt null
            callback()

      $(@).animate prop, options

  $.fn.recolor_rows = (recolored = false) ->
    if not recolored
      $(@).find("tr").each (idx) ->
        if idx % 2 is 0
          $(@).addClass 'feed-even'
          $(@).removeClass 'feed-odd'
        else
          $(@).removeClass 'feed-even'
          $(@).addClass 'feed-odd'
