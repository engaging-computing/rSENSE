# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is 'home' and namespace.action is 'index'
    ###
    #Resize mobile UI components based on current screen size
    ###
    resizeUI = () ->
      $('#mobile-menu').css('width', $(window).width())
      $('#mobile-splash').css('height', $(window).height() - 75)

    resizeUI()

    $(window).on 'resize', () ->
      resizeUI()

    $('.fa-times').on 'click', (e) ->
      e.preventDefault()
      $('#app-banner').hide()

    # A few page-specific styles.
    $('.navbar-static-top').css('min-width', 994)
    $('.item-image-link').removeClass('hidden-xs')
    if $('#mobile-splash').length is 0
      $('.desktop-footer').css('min-width', 994)

  ###
  # Other stuff
  ###
  $('.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = $(event.currentTarget).children('a').attr 'href'
  $('li.dropdown.navbtn').click () ->
    $('li.dropdown.navbtn').find('a:first').css 'color', 'white'
    $('li.dropdown.navbtn').removeAttr 'disabled'
  if $('.fa.fa-user').length > 0
    $('.lr').hide()
    $('.globe').css('margin-top', 0)