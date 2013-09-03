$ ->
  $(".ddmenu").on
    "mouseenter": -> 
      $(this).prev().css('background-color', '#649ce5')
    "mouseleave": -> 
      $(this).prev().css('background-color', '')