# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is 'home' and namespace.action is 'index'

    screenSize = (size) ->
      return ($ ".device-#{size}").is(':visible')
    #($ '.ternary-content').css('height', "#{($ window).height() - ($ '.footer').height() - 150 - ($ '#csv-footer').height()}px" - ($ '#column-one').find('.homepage-header').height())
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
    if screenSize 'md' is true  or screenSize 'sm' is true 
      console.log 'RUNNING'
      ($ '.isense-desc').height("10px")
      ($ '.isense-desc').find('div').each (i,j) ->
        console.log ($ j)
        ($ j).css('overflow', 'auto') 
    else
      ($ '.isense-desc').height('80vh')
    if screenSize 'sm' or screenSize 'xs'
      ($ '.carousel-caption').width '80%'
    else
      ($ '.carousel-caption').width '40%'
    ($ '#main-image-featurette').popover(title: "wat?", placement: 'bottom', content: "HELLLLLLLLLLLLOOOOOOOOOOOooo")
    lastView = 0
    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'
    ($ 'li.dropdown.navbtn').click () ->
      ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
      ($ 'li.dropdown.navbtn').removeAttr 'disabled'
    
    #($ '.item-image-link').addClass('hidden-sm')
    #($ '.item-image-link').addClass('hidden-xs')
    $( '.item-image-link').removeClass('hidden-xs')
    ($ window).on 'resize', () ->
      console.log "xs = #{screenSize 'xs'}"
      console.log "sm = #{screenSize 'sm'}"
      console.log "md = #{screenSize 'md'}"
      console.log "lg = #{screenSize 'lg'}"
      #($ '.ternary-content').css('height', "#{Math.min(($ window).height() - ($ '.footer').height() - 110 - ($ '#csv-footer').height(), ($ '#column-one').height())}px")
      #- (1.0 * ($ '.ternary-content').offset().top - ($ '.ternary-upper').offset().top)}px")
      #if ($ window).height() <= 500
      #  console.log 'too small!'
      #  ($ '.three-col').hide()
      #else
      #  ($ '.three-col').show()
      ($ '.news-prev-wrapper').css('height', "#{Math.max(200, ($ '.ternary-content').height() * .8)}px")
      if ($ window).width() <= 530
        ($ '.item-image-link').addClass('hidden-xs')
      else
        ($ '.item-image-link').removeClass('hidden-xs')
      # if screenSize 'sm' or screenSize 'xs'
      #   ($ '.carousel-caption').width '80%'
      # else
      #   ($ '.carousel-caption').width '40%'
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
    
    ###
    Scroll animation effects
    ###
    
    magicScroll = () -> 
      flag = false
      #console.log ($ window).scrollTop()
      location = 0
      if ($ window).scrollTop() < Math.abs(($ window).scrollTop() - ($ '#scroll-1').offset().top) and ($ window).scrollTop() < Math.abs(($ window).scrollTop() - ($ '#scroll-2').offset().top)
        location = 0
        bottom = false
      else if Math.abs ($ window).scrollTop() - ($ '#scroll-1').offset().top < Math.abs ($ window).scrollTop() - ($ '#scroll-2').offset().top
        location = ($ '#scroll-1').offset().top
        bottom = false
      else
        location = ($ '#scroll-2').offset().top
        flag = true 
      if not bottom
        if flag
          bottom = true
        ($ 'html, body').animate
          scrollTop: location, 500
        #bottom = true
      ###
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
          }, 250)

        lastView = (lastView - 1) % 3
        if lastView < 0
          lastView = 2
      ###
    throttled = _.throttle(magicScroll, 1000, leading: false)
    timer = 0
    
    ($ document).on 'scrollstop', latency: 1500, () ->
      magicScroll()
      
    #($ document).on 'mousewheel DOMMouseScroll', (event) ->
    #  #window.clearInterval(timer)
    #  timer = window.setInterval(throttled(), 2500)