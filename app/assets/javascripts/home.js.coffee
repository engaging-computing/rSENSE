# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is 'home' and namespace.action is 'index'

    resizeUI = () ->
      if screenSize('md') or screenSize('sm')
        console.log 'RUNNING'
        ($ '.isense-desc').height("40vh")
        ($ '.featurette-image').height("40vh")
        ($ '.isense-desc').find('.col-lg-12').each (i,j) ->
          console.log ($ j)
          ($ j).height("40vh")
          ($ '#column-one').css('height', '50vh')
          ($ '.news-prev-wrapper').css('height', '70vh')

        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          ($ j).height("25vh")
          ($ j).css('overflow-y', 'auto')
      else if screenSize('lg')
        console.log 'NP-Large'
        ($ '.isense-desc').height("95vh")
        ($ '#main-image-featurette').css('height', ($ '.what-is-isense').height() + ($ '.teachers-love-isense').height())
        ($ '.ternary-content').height('60vh')
        ($ '.isense-desc').css('height', ($ '#main-image-featurette').height())
      else 
        console.log "NP-Extra-Small"
        ($ '#column-one').css('height', '50vh')
        ($ '#main-image-featurette').height("90vh")
        ($ '.ternary-content').height('60vh')
        ($ '.news-prev-wrapper').css('height', '50vh')

    
      ($ '#main-image-featurette').popover(title: "wat?", placement: 'bottom', content: "HELLLLLLLLLLLLOOOOOOOOOOOooo")
      lastView = 0
      ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
        window.location = ($ event.currentTarget).children('a').attr 'href'
      ($ 'li.dropdown.navbtn').click () ->
        ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
        ($ 'li.dropdown.navbtn').removeAttr 'disabled'
      $( '.item-image-link').removeClass('hidden-xs')

    screenSize = (size) ->
      return ($ ".device-#{size}").is(':visible')
    #($ '.ternary-content').css('height', "#{($ window).height() - ($ '.footer').height() - 150 - ($ '#csv-footer').height()}px" - ($ '#column-one').find('.homepage-header').height())
    console.log "xs = #{screenSize 'xs'}"
    console.log "sm = #{screenSize 'sm'}"
    console.log "md = #{screenSize 'md'}"
    console.log "lg = #{screenSize 'lg'}"
    resizeUI()
    
    ($ window).on 'resize', () ->
    
      resizeUI()
      #  ($ '.news-prev-wrapper').css('height', "#{Math.max(200, ($ '.ternary-content').height() * .9)}px")

      #($ '.news-prev-wrapper').on 'mousewheel DOMMouseScroll', (event) ->
      #event.stopPropagation()

    
    ###
    Scroll animation effects
    ###
    
    magicScroll = () -> 
      console.log (($ window).scrollTop() + ($ window).height()) - ($ document).height()
      flag = false
      show = true
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
        if screenSize('lg')
          show = false 
      if not bottom
        if flag
          bottom = true
      if screenSize('xs')
        if Math.abs(($ window).scrollTop() - ($ '#scroll-4').offset().top) < Math.min(($ window).scrollTop(), Math.abs(($ window).scrollTop() - ($ '#scroll-1').offset().top), Math.abs(($ window).scrollTop() - ($ '#scroll-2').offset().top)) 
          location = ($ '#scroll-4').offset().top
          bottom = false
      unless Math.abs(($ window).scrollTop() - location) > (($ window).height() * .2)
        ($ 'html, body').animate
          scrollTop: location, 500
      show
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
    ($ document).on('scroll', () ->
      
      ($ '.secondary-main-content').removeClass('hidden-lg')
    )
    ($ document).on 'scrollstop', latency: 1500, () ->
      visible = magicScroll()
      if visible
        ($ '.secondary-main-content').show() 
      else
        ($ '.secondary-main-content').addClass('hidden-lg')
    #($ document).on 'mousewheel DOMMouseScroll', (event) ->
    #  #window.clearInterval(timer)
    #  timer = window.setInterval(throttled(), 2500)