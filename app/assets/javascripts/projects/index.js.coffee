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

    # For each project box: Hide tags if there are too many to fit in the box, and
    # add a button to toggle the hidden tags
    $('.project-card-tags.tagged').each (i) ->
      list = $($(this).find(".tag-list"))
      parentBox = $(this)
      totalWidth = $(list).innerWidth()
      accumWidth = 0 # total width of tag list
      rowWidth = 0 # width for each row
      numRows = 1
      hiddenTags = false
      hiddenList = [] # Due to closure, hiddenList and other variables are unique to each project box

      list.children(".tag-badge").each (i) ->
        accumWidth += $(this).outerWidth()
        rowWidth += $(this).outerWidth()
        if accumWidth >= totalWidth - 35
          hiddenTags = true
          $(this).hide()
          hiddenList.push($(this))
        if rowWidth >= totalWidth
          numRows += 1 # count number of rows for scrolling
          rowWidth = $(this).outerWidth()

      if hiddenTags
        # create buttons to show and hide tags
        expando = $('<span class="tag-toggle-button tag-expando-button"><i class="fa fa-ellipsis-h"></i></span>')
        collapso = $('<span class="tag-toggle-button tag-collapse-button"><i class="fa fa-close"></i></span>')
        list.find(".clear-tags").before(expando)
        parentBox.parent().append(collapso) # collapse needs to be attached to parent box in case list needs to scroll

        expando.click (e) ->
          $.each(hiddenList, (i, ele) ->
            ele.show())
          parentBox.siblings("a").find(".mdl-card__title").css("height": "inherit") # make image shrink
          parentBox.addClass("expanded") # make the tags box bigger
          if numRows > 4
            parentBox.css("overflow-y": "scroll") # scroll if there are multiple rows
          
          expando.hide()
          collapso.show()

        collapso.click (e) ->
          $.each(hiddenList, (i, ele) ->
            ele.hide())
          parentBox.siblings("a").find(".mdl-card__title").css("height": "130px") # restore image height
          parentBox.removeClass("expanded")
          if numRows > 4
            parentBox.css("overflow-y": "") # turn off scrolling

          expando.show()
          collapso.hide()
