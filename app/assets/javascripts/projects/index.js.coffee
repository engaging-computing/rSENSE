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

    $('.tag-list').each (i) ->
      console.log "------"
      totalWidth = $(this).innerWidth() - 35
      accumWidth = 0
      hiddenTags = false
      list = this
      console.log(totalWidth)
      $(this).children().each (i) ->
        accumWidth += $(this).outerWidth()
        console.log $(this).outerWidth()
        if accumWidth >= totalWidth
          hiddenTags = true;
          $(this).hide();

      if hiddenTags
        expando = $('<span class="tag-badge" style="float: right;"><i class="fa fa-ellipsis-h"></i></span>')
        $(this).append(expando)
        expando.click (e) ->
          $(list).children().show()
          $(list).height("+=100")
          expando.hide()
