# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  ($ 'li.dropdown.navbtn').click () ->
    ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
    ($ 'li.dropdown.navbtn').removeAttr 'disabled'
  ($ '#news-feed').on( 'mouseenter', () ->
    ($ '#news-feed').css('overflow-y', 'scroll')
  )
  
  ($ '#news-feed').on( 'mouseleave', () ->
    ($ '#news-feed').css('overflow-y', 'hidden')
  )
  ($ window).on('resize', ->
    if ($ window).outerWidth() <= 992
      ($ '.invisible').removeClass('invisible').addClass('visible-divide')
    else ($ '.visible-divide').removeClass('visible-divide').addClass('invisible')
    ($ '.collaborate-img').width(($ '#play-store-button').width() + ($ '#app-store-button').width())
  )