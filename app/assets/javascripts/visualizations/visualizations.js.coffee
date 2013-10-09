$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis","show"]
    ($ '#fullscreen-viz').click ->
      window.globals.fullscreen = true;
      ($ '#title_bar').remove()
      ($ '.footer').remove()
      ($ '#dataset_info').remove()
      ($ '#title_row').remove()
      ($ '.mc-wide').removeClass("mainContent")
      ($ '.mc-wide').removeClass("container")
      ($ '.mc-wide').parents('div').replaceWith(($ '.mc-wide'))
      ($ window).trigger('resize')
      ($ this).remove()