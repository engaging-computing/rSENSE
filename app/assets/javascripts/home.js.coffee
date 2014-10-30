# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  ($ 'li.dropdown.navbtn').click () ->
    ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
    ($ 'li.dropdown.navbtn').removeAttr 'disabled'
  ###
  Homepage News Feed
  ###
  ($ '.news-prev-wrapper').on 'mouseenter', () ->
    ($ '.news-prev-wrapper').css('overflow-y', 'scroll')
  
  ($ '.news-prev-wrapper').on 'mouseleave', () ->
    ($ '.news-prev-wrapper').scroll(0)
    ($ '.news-prev-wrapper').css('overflow-y', 'hidden')
    
  ($ window).on('resize', () ->
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
  )
  screenSize = (size) ->
    return ($ ".device-#{size}").is(':visible')
  