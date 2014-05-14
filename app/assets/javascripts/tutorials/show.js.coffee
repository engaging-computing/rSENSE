
IS.onReady "tutorials/show", ->
  IS.fillTmpl('#pub-status', 'pub-status-none', {})

  ($ '#publish_tutorial').click ->
    IS.fillTmpl('#pub-status', 'pub-status-wait', {})

    $.ajax
      url: ''
      type: 'PUT'
      dataType: 'json'
      data:
        tutorial:
          hidden: !($ @).prop("checked")
      success: () ->
        IS.fillTmpl('#pub-status', 'pub-status-saved', {})
        setTimeout(
          -> IS.fillTmpl('#pub-status', 'pub-status-none', {}),
          2000)
      error: (msg) ->
        IS.fillTmpl('#pub-status', 'pub-status-error', {message: msg})
