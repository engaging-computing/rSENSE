# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is 'home' and namespace.action is 'index'

    # Determines the current Bootstrap screen size being used to resize UI elements
    screenSize = (size) ->
      return ($ ".device-#{size}").is(':visible')

    ###
    #Resize UI components based upon Bootstrap and screen size
    ###
    resizeUI = () ->
      if screenSize('md') or screenSize('sm')
        ($ '.isense-desc').css('min-height', '170px')
        ($ '.isense-desc').height("45vh")
        ($ '.row.secondary-content').height('100vh')
        ($ '.featurette-image').height("40vh")
        ($ '#main-image-featurette').css('min-height', '300px')
        #($ '#main-image-featurette').height('45vh')
        ($ '.ternary-content').height('90vh')
        ($ '#column-one').css('height', '90vh')
        ($ '.news-prev-wrapper').css('height', '60vh')
        ($ '.news-prev-wrapper').css('overflow-y', 'scroll')
        ($ '.ternary-content').css('overflow-y', 'hidden')
        ($ '.what-is-isense').height(($ '.isense-desc').height())
        ($ '.teachers-love-isense').height(($ '.isense-desc').height())
        #($ '.what-is-isense').height(($ '.isense-desc').height() * .45)
        #($ '.teachers-love-isense').height(($ '.isense-desc').height() * .45)
        ($ '.teachers-love-isense').find('.homepage-text').height(($ '.teachers-love-isense').height() - ($ '.teachers-love-isense').find('.homepage-header').height())
        ($ '.what-is-isense').find('.homepage-text').height(($ '.what-is-isense').height() - ($ '.what-is-isense').find('.homepage-header').height()- 60)
        ($ '#column-one').height('auto')
        ($ '.ternary-content').height('auto')
        ($ '#main-image-featurette').css('height', '60vh')
      else if screenSize('lg')
        ($ '.isense-desc').css('min-height', '500px')
        ($ '.isense-desc').height("95vh")
        ($ '#main-image-featurette').css('min-height', '500px')
        ($ '#main-image-featurette').css('height', '95vh')
        ($ '.ternary-content').height(Math.max((($ window).height() * .8), ($ '#column-one').height()))
        ($ '.ternary-content').css('overflow-y', 'visible')
        ($ '.news-prev-wrapper').height('75vh')
        ($ '#column-one').height('80vh')
        ($ '#column-two').height('80vh')
        ($ '.what-is-isense').height(($ '.isense-desc').height() * .3)
        ($ '.teachers-love-isense').css('margin-top', '60')
        ($ '.teachers-love-isense').height(($ '.isense-desc').height() - ($ '.what-is-isense').height())
        ($ '.teachers-love-isense').find('.homepage-text').height(($ '.teachers-love-isense').height() - ($ '.teachers-love-isense').find('.homepage-header').height() - 100)
        ($ '.what-is-isense').find('.homepage-text').height(($ '.what-is-isense').height() - ($ '.what-is-isense').find('.homepage-header').height())
        ($ '.row.secondary-content').find('.col-lg-8').css('clear', '')
      else 
        ($ '.isense-desc').css('min-height', '500px')
        ($ '.isense-desc').css('height', '100vh')
        ($ '#column-one').css('height', '95vh')
        ($ '.row.secondary-content').css('height', 'auto')
        ($ '#main-image-featurette').css('min-height', '500px')
        ($ '#main-image-featurette').height("95vh")
        ($ '.row.secondary-content').find('.col-lg-8').css('clear', 'both')
        ($ '#main-image-featurette').css('clear', 'both')
        ($ '.ternary-content').height('95vh')
        ($ '.news-prev-wrapper').css('height', '45vh')
        ($ '.news-prev-wrapper').css('overflow-y', 'scroll')
        ($ '.what-is-isense').height(($ '.isense-desc').height() * .3)
        ($ '.teachers-love-isense').height(($ '.isense-desc').height() * .65)
        ($ '.teachers-love-isense').find('.homepage-text').height(($ '.teachers-love-isense').height() - ($ '.teachers-love-isense').find('.homepage-header').height() - 120)
        ($ '.what-is-isense').find('.homepage-text').height(($ '.what-is-isense').height() - ($ '.what-is-isense').find('.homepage-header').height() - 80)
        ($ '#column-one').height('auto')
        ($ '.ternary-content').height('auto')

      if ($ '#column-one').height() < 900
        ($ '#column-two').height( ($ '#column-one').height())
        ($ '.ternary-content').height( ($ '#column-one').height())

    resizeUI()

    ($ window).on 'resize', () ->    
      resizeUI()

    ###
    Scroll animation effects
    ###    
    magicScroll = () -> 
      console.log Math.abs((($ window).scrollTop() + ($ window).height()) - ($ document).height())
      console.log ($ window).height() * .1
      flag = false
      show = true
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
        if not(($ window).scrollTop() + ($ window).height() == ($ document).height())
          if ($ window).scrollTop() < ($ '#scroll-2').offset().top
            ($ 'html, body').animate
              scrollTop: location, 500
      show

    ($ document).on 'scrollstop', latency: 1500, () ->
      magicScroll()

  ###
  #Other stuff
  ###
    
  ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = ($ event.currentTarget).children('a').attr 'href'
  ($ 'li.dropdown.navbtn').click () ->
    ($ 'li.dropdown.navbtn').find('a:first').css 'color', 'white'
    ($ 'li.dropdown.navbtn').removeAttr 'disabled'

