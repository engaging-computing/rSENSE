$ ->
  if namespace.controller is "tutorials" and namespace.action is "show"
    ($ 'a.media_object_delete').click (e) ->
      e.preventDefault()
      
      if helpers.confirm_delete ($ @).attr('name')
        $.ajax
          url: ($ @).attr("href")
          type: 'DELETE'
          dataType: "json"
          success: =>
            row = ($ @).parents('div.mediaobject')
            row.hide_row () =>
              ($ 'div#media_object_list div.mediaobject').filter(':visible').each (idx) ->
                if idx % 2 is 0
                  ($ @).addClass 'feed-even'
                  ($ @).removeClass 'feed-odd'
                else
                  ($ @).removeClass 'feed-even'
                  ($ @).addClass 'feed-odd'
              row.remove()