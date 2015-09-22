# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  $('li.dropdown.navbtn').click () ->
    $('li.dropdown.navbtn').find('a:first').css 'color', 'white'
    $('li.dropdown.navbtn').removeAttr 'disabled'
  if window.env == 'test'
    $('input[type=file]').show()
    $('.hidden-form').show()
