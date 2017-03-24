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

    $('.project-card-tags.tagged').each (i) ->
      list = $(this).find(".tag-list")
      parentBox = $(this)
      totalWidth = $(list).innerWidth() - 35
      accumWidth = 0
      hiddenTags = false
      hiddenList = [] # Due to closure, this and other variables are unique to each project box
      $(list).children().each (i) ->
        accumWidth += $(this).outerWidth()
        if accumWidth >= totalWidth
          hiddenTags = true;
          $(this).hide();
          hiddenList.push($(this))

      if hiddenTags
        expando = $('<span class="tag-badge" style="float: right;"><i class="fa fa-ellipsis-h"></i></span>')
        $(this).append(expando)
        expando.click (e) ->
          $.each(hiddenList, (i, ele) ->
            ele.show())
          parentBox.addClass("expanded") # TODO: Put the project-card-tags class in application.scss; add collapse button; figure out why the box doesn't want to resize correctly scroll?
          expando.hide()
