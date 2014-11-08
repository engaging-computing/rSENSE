# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  screenSize = (size) ->
    return ($ ".device-#{size}").is(':visible')
  ($ '.ternary-content').css('height', "#{($ window).height() - ($ '.footer').height() - 110 - ($ '#csv-footer').height()}px")
  console.log "xs = #{screenSize 'xs'}"
  console.log "sm = #{screenSize 'sm'}"
  console.log "md = #{screenSize 'md'}"
  console.log "lg = #{screenSize 'lg'}"
    
  ($ '#main-image-featurette').popover(title: "wat?", placement: 'bottom', content: "HELLLLLLLLLLLLOOOOOOOOOOOooo")
  lastView = 0
  ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  ($ 'li.dropdown.navbtn').click () ->
    ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
    ($ 'li.dropdown.navbtn').removeAttr 'disabled'
  
  ($ '.item-image-link').addClass('hidden-sm')
  ($ '.item-image-link').addClass('hidden-md')

  ($ window).on 'resize', () ->
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
    ($ '.ternary-content').css('height', "#{($ window).height() - ($ '.footer').height() - 110 - ($ '#csv-footer').height()}px")
    #- (1.0 * ($ '.ternary-content').offset().top - ($ '.ternary-upper').offset().top)}px")
  ($ '.news-prev-wrapper').on 'mousewheel DOMMouseScroll', (event) ->
    event.stopPropagation()
  
  ###
  Popover for Welcome to iSENSE featurette
  ###
  ($ '#main-image-featurette').on 'mouseenter', () ->
    console.log '2chainz!'
    ($ '#main-image-featurette').popover('toggle')
  ($ '#main-image-featurette').on 'mouseleave', () ->
    ($ '#main-image-featurette').popover('toggle')
  
  #($ '#main-image-featurette').css('height', "#{($ '.isense-desc').height()}px")
  #console.log "#{($ '.isense-desc').height()}px"
  ###
  Scroll animation effects
  ###
  
  magicScroll = (event) -> 
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
  throttled = _.throttle(magicScroll, 1000, trailing: false)
  ($ document).on 'mousewheel DOMMouseScroll', (event) ->
    throttled(event)