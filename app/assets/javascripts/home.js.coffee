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

    resizeUI = () ->
      console.log 'resizeUI loading' 
      if screenSize('md') or screenSize('sm')
        console.log 'NP Medium or NP Small'
        ($ '.isense-desc').css('min-height', '170px')
        ($ '.isense-desc').height("45vh")
        ($ '.featurette-image').height("40vh")
        ($ '#main-image-featurette').css('min-height', '200px')
        ($ '#main-image-featurette').height('45vh')
        #($ '.isense-desc').find('.col-lg-12').each (i,j) ->
          #  ($ j).height("40vh")
        ($ '.ternary-content').height('90vh')
        ($ '#column-one').css('height', '80vh')
        ($ '.news-prev-wrapper').css('height', '45vh')
        ($ '.news-prev-wrapper').css('overflow-y', 'scroll')
        ($ '.ternary-content').css('overflow-y', 'hidden')
        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          ($ j).height("20vh")
          ($ j).css('overflow-y', 'auto')
      else if screenSize('lg')
        console.log 'NP-Large'
        ($ '.isense-desc').css('min-height', '500px')
        ($ '.isense-desc').height("90vh")
        ($ '#main-image-featurette').css('min-height', '500px')
        ($ '#main-image-featurette').css('height', '95vh')
        ($ '.ternary-content').height(Math.max((($ window).height() * .8), ($ '#column-one').height()))
        #($ '.news-prev-wrapper').height('70vh')
        ($ '.ternary-content').css('overflow-y', 'visible')
        #($ '.isense-desc').find('.col-lg-12').each (i,j) ->
        #  ($ j).height("35vh")
        ($ '.news-prev-wrapper').height('75vh')
        ($ '#column-one').height('80vh')
        ($ '#column-three').height('80vh')
        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          console.log ($ j)
          ($ j).height(Math.max(($ j).height(), (($ window).height() * .25)))
          ($ j).css('overflow-y', 'auto')
        #($ '.isense-desc').css('height', "#{($ '#main-image-featurette').height()}px")
      else 
        console.log "NP-Extra-Small"
        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          console.log ($ j)
          unless i is 0
            ($ j).height(Math.min((($ window).height() * .5), ($ j).height()))
          ($ j).css('overflow-y', 'auto')
        ($ '.isense-desc').css('min-height', '500px')
        ($ '.isense-desc').css('height', '95vh')
        ($ '#column-one').css('height', '95vh')
        ($ '#main-image-featurette').css('min-height', '500px')
        ($ '#main-image-featurette').height("90vh")
        ($ '.ternary-content').height('95vh')
        #($ '.news-prev-wrapper').css('height', '50vh')
        ($ '.news-prev-wrapper').css('height', '40vh')
        ($ '.news-prev-wrapper').css('overflow-y', 'scroll')
        #($ '.ternary-content').css('overflow-y', 'hidden')

      if ($ '#column-one').height() < 900
        #($ '#column-one').css('overflow-y', 'scroll')
        ($ '#column-three').height( ($ '#column-one').height())
        #($ '#column-three').css('overflow-y', 'scroll')
        ($ '.ternary-content').height( ($ '#column-one').height())
        ($ '#app-description').height( ($ '#column-three').height() - ($ '#column-three').find('.homepage-header').height() - 20)
        ($ '#app-description').css('overflow-y', 'auto')

    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'
    ($ 'li.dropdown.navbtn').click () ->
      ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
      ($ 'li.dropdown.navbtn').removeAttr 'disabled'
    
    resizeUI()

    ($ window).on 'resize', () ->    
      resizeUI()
    
    #($ '.homepage-text').on 'scroll', (e) ->
      #e.stopPropagation()
    #($ '#column-three').on 'scroll', (e) ->
    #  e.stopPropagation()

    ###
    Scroll animation effects
    ###    
    magicScroll = () -> 
      console.log Math.abs((($ window).scrollTop() + ($ window).height()) - ($ document).height())
      console.log ($ window).height() * .1
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
      unless Math.abs(($ window).scrollTop() - location) > (($ window).height() * .25)
        ($ 'html, body').animate
          scrollTop: location, 500
      show

    ($ document).on 'scrollstop', latency: 1500, () ->
      magicScroll()
