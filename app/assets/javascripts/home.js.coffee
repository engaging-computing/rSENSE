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
  )

  ($ document).ready( () ->
    window.resizePage()
  )

  ($ window).on('resize', () ->
    window.resizePage()
  )
  ###
  Draw UI Components for appropriate screen size
  ###
  window.resizePage = () ->
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
    width = (($ window).width() * ((($ window).height() - ($ '.navbar').height()) / ($ window).width())).toFixed(2)
    ($ '#myCarousel').height(width)
    ($ '#carousel-container').height(width)
    ($ '.carousel').height(width)
    ($ '.carousel').find('.item').each (i,j) ->
      ($ j).height(width)
    ($ '.carousel-inner').height(width)
    ($ '.carousel-img').height(width)
    if(screenSize('lg') or screenSize('md'))
      console.log 'hello'
      ($ '.isense-desc').height(width)
      ($ '#main-image-featurette').height(width)
    else
      ($ '.isense-desc').height( ($ '#myCarousel').height() / 2 )
      ($ '#main-image-featurette').height(($ '#myCarousel').height() - ($ '.isense-desc').height())
    ($ '.secondary-content').height(($ '#myCarousel').height())
    ($ '#stats-div').height( (($ '#myCarousel').height() - ($ '#app-description').height()))
    #($ '.ternary-content').height((width - ($ '#csv-footer').height()))
    ($ '.ternary-content').find('.col-md-4').height((width - ($ '#csv-footer').height()))
    ($ '.three-col').height((width - ($ '#csv-footer').height()))
    ($ '#news-feed').height((width - ($ '#csv-footer').height()) - 120)
  
  screenSize = (size) ->
    return ($ ".device-#{size}").is(':visible')
  