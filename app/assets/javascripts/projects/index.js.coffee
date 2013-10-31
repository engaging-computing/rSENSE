# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"

    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()

    ($ '#template_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '#curated_checkbox').click ->
      ($ '#projects_search').submit()
      
    ($ window).resize () ->
      helpers.isotope_layout('#projects')

    helpers.isotope_layout('#projects')
