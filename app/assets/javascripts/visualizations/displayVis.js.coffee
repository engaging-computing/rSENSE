$ ->
  if namespace.controller is "visualizations" and namespace.action is "displayVis"
    $.fn.carousel.defaults = 
      interval: false,
      pause: 'hover'