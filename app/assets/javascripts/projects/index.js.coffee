# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"

    ($ '#addProjectButton').click ->
      $.ajax
        url: "/projects/create"
        data: {}
        dataType: "json"
        success: (data, textStatus) ->
          helpers.name_popup data, "Project", "project"
  
    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()

    ($ '#template_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '#curated_checkbox').click ->
      ($ '#projects_search').submit()
      
    reflow = () ->
      helpers.isotope_layout('#projects')
    
    ($ window).resize () ->  
      setTimeout(reflow,750)

    helpers.isotope_layout('#projects')
