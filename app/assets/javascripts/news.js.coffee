# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

IS.onReady 'news/show', ->
  IS.fillTmpl('#pub-status', 'pub-status-none', {})

  ($ '#hide_news_checkbox').click ->
    IS.fillTmpl('#pub-status', 'pub-status-wait', {})

    $.ajax
      url: ''
      type: 'PUT'
      dataType: 'json'
      data:
        news:
          hidden: !($ @).prop("checked")
      success: () ->
        IS.fillTmpl('#pub-status', 'pub-status-saved', {})
        setTimeout(
          -> IS.fillTmpl('#pub-status', 'pub-status-none', {}),
          2000)
      error: (msg) ->
        IS.fillTmpl('#pub-status', 'pub-status-error', {message: msg})
