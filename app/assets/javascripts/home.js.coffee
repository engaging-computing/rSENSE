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
        ($ '.isense-desc').height("40vh")
        ($ '.featurette-image').height("40vh")
        ($ '.isense-desc').find('.col-lg-12').each (i,j) ->
          #  ($ j).height("40vh")
          ($ '#column-one').css('height', '60vh')
          ($ '.news-prev-wrapper').css('height', '60vh')

        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          ($ j).height("20vh")
          ($ j).css('overflow-y', 'auto')
      else if screenSize('lg')
        console.log 'NP-Large'
        ($ '.isense-desc').height("90vh")
        ($ '#main-image-featurette').css('height', '90vh')
        ($ '.ternary-content').height('50vh')
        #($ '.isense-desc').find('.col-lg-12').each (i,j) ->
        #  ($ j).height("35vh")
        ($ '.secondary-content').find('.homepage-text').each (i,j) ->
          console.log ($ j)
          ($ j).height("25vh")
          ($ j).css('overflow-y', 'auto')
        #($ '.isense-desc').css('height', "#{($ '#main-image-featurette').height()}px")
      else 
        console.log "NP-Extra-Small"
        ($ '#column-one').css('height', '50vh')
        ($ '#main-image-featurette').height("90vh")
        ($ '.ternary-content').height('50vh')
        ($ '.news-prev-wrapper').css('height', '50vh')

    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'
    ($ 'li.dropdown.navbtn').click () ->
      ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
      ($ 'li.dropdown.navbtn').removeAttr 'disabled'
    
    resizeUI()

    ($ window).on 'resize', () ->    
      resizeUI()
      
    ###
    Scroll animation effects
    ###
    
    magicScroll = () -> 
      #console.log (($ window).scrollTop() + ($ window).height()) - ($ document).height()
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

    ($ document).on 'scrollstop', latency: 1500, () ->
      visible = magicScroll()
