# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "visualizations" and namespace.action is "index"

    # Setup toggle buttons
    $('.btn').button()
    $('.binary-filters .btn').each () ->
      tmp = ($ this).children()[0]
      if ($ tmp).prop("checked")
        ($ this).button('toggle')

    # Setup auto-submit
    ($ '.visualizations_filter_checkbox').click ->
      ($ '#visualizations_search').submit()
    
    ($ '.visualizations_sort_select').change ->
      ($ '#visualizations_search').submit()
      
    ($ '.visualizations_order_select').change ->
      ($ '#visualizations_search').submit()
    
    ($ '.binary-filters .btn').on 'click', (e) ->
      e.preventDefault()
      cb = ($ ($ e.target).children()[0])
      cb.prop("checked", not cb.prop("checked"))
      ($ '#visualizations_search').submit()