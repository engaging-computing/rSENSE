# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"
    
    # Setup toggle buttons
    $('.btn').button()
    $('.binary-filters .btn').each () ->
      tmp = ($ this).children()[0]

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
