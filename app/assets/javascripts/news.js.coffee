# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  if namespace.controller is "news" and namespace.action is "show"
    ($ '#hide_news_checkbox').click ->
      $.ajax
        url: ''
        type: 'PUT'
        dataType: 'json'
        data:
          news:
            hidden: ($ @).prop("checked")
        error: (msg) ->
          console.log msg