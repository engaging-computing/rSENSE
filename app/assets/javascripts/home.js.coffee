# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is 'home' and namespace.action is 'index'
    ###
    # Determines the current Bootstrap screen size being used to resize UI elements
    screenSize = (size) ->
      return $(".device-#{size}").is(':visible')
    ###
    ###
    #Resize UI components based upon Bootstrap and screen size
    ###
    resizeUI = () ->
      #$('.navbar-fixed-top').css('min-width')
      #$('.carousel').find('.item').each (i,j) ->
      #  if $(j).find('.carousel-img').offset().top > $('.carousel-inner').offset().top
      #    $(j).find('.carousel-caption').css('margin-top', $(j).find('.carousel-img').offset().top - $('.carousel-inner').offset().top)
      #if $('.desktop-footer').length is 1
        #$('.news-prev-wrapper').find('img').each (i,j) ->
        #  ($ j).css('margin-top', "#{(400 - $(j).height()) / 2)}px")
      $('#mobile-menu').css('width', $(window).width())
      $('#mobile-splash').css('height', $(window).height() - 75)
      #$('.fa-sort-desc').css('margin-left', -32)
      ###if screenSize('md') or screenSize('sm')
        $('.what-is-isense').height($('.isense-desc').height())
        $('.teachers-love-isense').height($('.isense-desc').height())
        $('.teachers-love-isense').find('.homepage-text').height(
          $('.teachers-love-isense').height() - $('.teachers-love-isense').find('.homepage-header').height())
        $('.what-is-isense').find('.homepage-text').height(
          $('.what-is-isense').height() - $('.what-is-isense').find('.homepage-header').height() - 45)
      else if screenSize('lg')
        $('.ternary-content').height(Math.max(($(window).height() * .8), $('#column-one').height()))
        $('.what-is-isense').height($('.isense-desc').height() * .3)
        $('.teachers-love-isense').height($('.isense-desc').height() - $('.what-is-isense').height())
        $('.teachers-love-isense').find('.homepage-text').height(
          $('.teachers-love-isense').height() - $('.teachers-love-isense').find('.homepage-header').height() - 200)
        $('.what-is-isense').find('.homepage-text').height(
          $('.what-is-isense').height() - $('.what-is-isense').find('.homepage-header').height())
      else
        $('.teachers-love-isense').height($('.isense-desc').height() * .65)
        $('.teachers-love-isense').find('.homepage-text').height(
          $('.teachers-love-isense').height() - $('.teachers-love-isense').find('.homepage-header').height() - 120)
        $('.what-is-isense').find('.homepage-text').height(
          $('.what-is-isense').height() - $('.what-is-isense').find('.homepage-header').height() - 80)
      if $('#column-one').height() < 900
        $('#column-two').height( $('#column-one').height())
        $('.ternary-content').height( $('#column-one').height())
      ###
    resizeUI()

    $(window).on 'resize', () ->
      resizeUI()

    ###
    Scroll animation effects
    ###
    ###
    magicScroll = () ->
      flag = false
      show = true
      location = 0
      if($(window).scrollTop() < Math.abs($(window).scrollTop() - $('#scroll-1').offset().top) and
      $(window).scrollTop() < Math.abs($(window).scrollTop() - $('#scroll-2').offset().top))
        location = 0
        bottom = false
      else if Math.abs $(window).scrollTop() - $('#scroll-1').offset().top <
      Math.abs $(window).scrollTop() - $('#scroll-2').offset().top
        location = $('#scroll-1').offset().top
        bottom = false
      else
        location = $('#scroll-2').offset().top
        flag = true
        if screenSize('lg')
          show = false
      if not bottom
        if flag
          bottom = true
      if screenSize('xs')
        if Math.abs($(window).scrollTop() - $('#scroll-4').offset().top) <
        Math.min($(window).scrollTop(), Math.abs($(window).scrollTop() -
        $('#scroll-1').offset().top), Math.abs($(window).scrollTop() - $('#scroll-2').offset().top))
          location = $('#scroll-4').offset().top
          bottom = false
      unless Math.abs($(window).scrollTop() - location) > ($(window).height() * .25)
        if not($(window).scrollTop() + $(window).height() == $(document).height())
          if $(window).scrollTop() < $('#scroll-2').offset().top
            $('html, body').animate
              scrollTop: location, 500
      show

    $(document).on 'scrollstop', latency: 1500, magicScroll###
    $('.fa-times').on 'click', (e) ->
      e.preventDefault()
      $('#app-banner').hide()
    ###$('.android-button').on 'hover', (e) ->
      console.log 'wat'
      $('.android-button').css('background-color', 'rgba(39,135,245,0.5)')
    ###
    $('.navbar-static-top').css('min-width', 994)
    $('.item-image-link').removeClass('hidden-xs')
    if $('#mobile-splash').length is 0
      $('.desktop-footer').css('min-width', 994)

    # $carousel = $('#myCarousel')
    # $carousel.carousel()
    # $carousel.on('slid.bs.carousel', () ->
    #   console.log 'running'
    #   if $('.item.active').find('.carousel-img').offset().top > $('.carousel-inner').offset().top
    #     $('.item.active').find('.carousel-caption').css('margin-top', $('.item.active').find('.carousel-img').offset().top - $('.carousel-inner').offset().top))
    #   #$('.item.active').find('header-wrapper').show())
    # $carousel.on('slid.bs.carousel', () ->
    #   console.log 'running'
    #   if $('.item.active').find('.carousel-img').offset().top > $('.carousel-inner').offset().top
    #     $('.item.active').find('.carousel-caption').css('margin-top', $('.item.active').find('.carousel-img').offset().top - $('.carousel-inner').offset().top))
    #   #$('.item.active').find('header-wrapper').show())

  ###
  # Other stuff
  ###  
  $('.mainContent').on 'click', 'div.clickableItem', (event) ->
    window.location = $(event.currentTarget).children('a').attr 'href'
  $('li.dropdown.navbtn').click () ->
    $('li.dropdown.navbtn').find('a:first').css 'color', 'white'
    $('li.dropdown.navbtn').removeAttr 'disabled'
  if $('.fa.fa-user').length > 0
    $('.lr').hide()
    $('.globe').css('margin-top', 0)

