# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"
    
    # Setup toggle buttons
    $('.btn').button()
    $('.binary-filters .btn').each () ->
      tmp = ($ this).children()[0] 
      if ($ tmp).prop("checked")
        ($ this).button('toggle')
    
    # Make blocks clickable
    ($ '.mainContent').on 'mousedown', 'div.clickableItem', (event) ->
      if event.which is 1
        window.location = ($ event.currentTarget).children('a').attr 'href'
      else if event.which is 2
        # Simulate middle click
        lk = ($ event.currentTarget).children('a')
        evt = document.createEvent('MouseEvents')
        evt.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, event.ctrlKey, false, event.shiftKey, false, 1, lk[0])
        lk[0].dispatchEvent(evt)
        event.preventDefault()

    # Setup auto-submit
    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()
      
    ($ '.projects_order_select').change ->
      ($ '#projects_search').submit()
    
    ($ '.binary-filters .btn').on 'click', (e) ->
      e.preventDefault()
      cb = ($ ($ e.target).children()[0])
      cb.prop("checked", not cb.prop("checked"))
      ($ '#projects_search').submit()

    # Setup isotope
    helpers.isotope_layout('#projects')
    
    $(window).smartresize () ->
      helpers.isotope_layout('#projects')
    
    # Setup add project button
    ($ '#addProjectButton').click ->
      $.ajax
        url: "/projects/create"
        data: {}
        dataType: "json"
        success: (data, textStatus) ->
          helpers.name_popup data, "Project", "project"