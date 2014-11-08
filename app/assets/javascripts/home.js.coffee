# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  ($ window).scrollTop(0)
  lastView = 0
  ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  ($ 'li.dropdown.navbtn').click () ->
    ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
    ($ 'li.dropdown.navbtn').removeAttr 'disabled'
  
  ($ window).on 'resize', () ->
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
    if screenSize 'xs' or screenSize 'sm'
      ($ '.news-prev-wrapper').css('height', "#{.2 * ($ window).height()}px")
    else
      ($ '.news-prev-wrapper').css('height', "#{.4 * ($ window).height()}px")
    #($ '#column-one').find('.article_page_content.truncate').each (i,j) ->
    #  ($ j).css('height',"150px")

  screenSize = (size) ->
    return ($ ".device-#{size}").is(':visible')
  ($ '.news-prev-wrapper').on 'mousewheel DOMMouseScroll', (event) ->
    event.stopPropagation()
  ###
  Scroll animation effects
  ###
  ($ document).on 'mousewheel DOMMouseScroll', (event) ->
    event.stopPropagation()
    event.preventDefault()
    direction = 
      if event.originalEvent.wheelDelta / 120 > 0
        1
      else -1
    if direction < 0
      console.log 'scrolled down'
      ($ 'html, body').animate({
        scrollTop: 
          ret =  
          if (lastView + 1) % 3 isnt 0
            ($ "#scroll-#{(lastView + 1) % 3}").offset().top
          else 0
    }, 1000)
      
      lastView = (lastView + 1) % 3
    else
      console.log 'scrolled up'
      ($ 'html, body').animate({
        scrollTop: 
          ret =  
          if (lastView - 1) % 3 is -1
            ($ "#scroll-2").offset().top
          else if (lastView - 1) % 3 is 0
            0  
          else 
            ($ "#scroll-#{(lastView - 1) % 3}").offset().top
        }, 1000)

      lastView = (lastView - 1) % 3
      if lastView < 0
        lastView = 2