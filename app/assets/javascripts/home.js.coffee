# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  if namespace.controller is "home"
    $('.set_tutorial').change ->
      data={}
      data["selected"] = $(this).val()
      data["location"] = $(this).attr("id")
      if $(this).val() == "SELECT ONE"
        false
      else
        $.ajax
          url: '/tutorials/switch/'
          dataType: 'json'
          data:
            data
          false  
    $(".projectsCarousel").jCarouselLite({
        btnNext: ".next",
        btnPrev: ".prev",
        responsive: true,
        speed: 400,
        visible: 4
    })
    