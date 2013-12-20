# Place all the behaviors and hooks related to the matching controller here.

$ ->
  if namespace.controller is "tutorials" and namespace.action is "index"

    # Setup toggle buttons
    $('.btn').button()
    $('.binary-filters .btn').each () ->
      tmp = ($ this).children()[0] 
      if ($ tmp).prop("checked")
        ($ this).button('toggle')

    # Setup auto-submit
    ($ '.tutorials_filter_checkbox').click ->
      ($ '#tutorials_search').submit()
    
    ($ '.tutorials_sort_select').change ->
      ($ '#tutorials_search').submit()
      
    ($ '.tutorials_order_select').change ->
      ($ '#tutorials_search').submit()
    
    ($ '.binary-filters .btn').on 'click', (e) ->
      e.preventDefault()
      cb = ($ ($ e.target).children()[0])
      cb.prop("checked", not cb.prop("checked"))
      ($ '#tutorials_search').submit()

    # Setup isotope
    helpers.isotope_layout('#tutorials')
    
    $(window).smartresize () ->
      helpers.isotope_layout('#tutorials')
    
    # Setup add tutorial button
    ($ '#addTutorialButton').click ->
      $.ajax
        url: "/tutorial/create"
        data: {}
        dataType: "json"
        success: (data, textStatus) ->
          helpers.name_popup data, "Tutorial", "tutorial"