# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"
    
    # Setup toggle buttons
    $('.btn').button()

    # Setup auto-submit
    $('.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
    
    $('.projects_sort_select').change ->
      ($ '#projects_search').submit()
      
    $('.projects_order_select').change ->
      ($ '#projects_search').submit()
    
    $('.binary-filters > .btn > input').click (e) ->
      cb = $(@)
      allowedClass = ['template-check', 'curated-check', 'featured-check', 'has-data-check']
      checkType = allowedClass.filter (x) ->
        cb.hasClass x
      if checkType.length == 1
        checkType = "input.#{checkType[0]}"
        $(checkType).prop('checked', cb.prop 'checked')

    # ($ '.binary-filters .btn').on 'click', (e) ->
    #   e.preventDefault()
    #   cb = ($ ($ e.target).children()[0])
    #   cb.prop("checked", not cb.prop("checked"))
    #   ($ '#projects_search').submit()
