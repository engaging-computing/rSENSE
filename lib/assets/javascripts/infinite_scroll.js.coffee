$ ->

  intId = 0

  nextPage = (container, form, pager, loader, addItem) ->
    if (($ container).height() - ($ window).scrollTop() < ($ window).height() + constants.INFINITE_SCROLL_LOOKAHEAD)

      ($ pager).val(parseInt(($ pager).val()) + 1)

      $.ajax
        url: ($ form).action
        data: ($ form).serialize()
        dataType: "json"
        success: (data, status) ->

          if (data.length != constants.INFINITE_SCROLL_ITEMS_PER)
            ($ loader).hide()
            clearInterval intId

          for object in data
            addItem object

          helpers.isotope_layout(container)

  window.helpers.infinite_scroll = (gotNum, container, form, pager, loader, addItem) ->

    populate = () ->
      nextPage(container, form, pager, loader, addItem)

    helpers.isotope_layout(container)

    if gotNum == constants.INFINITE_SCROLL_ITEMS_PER
      clearInterval intId
      intId = setInterval populate, constants.INFINITE_SCROLL_DELAY
      ($ loader).show()
    else
      clearInterval intId
      ($ loader).hide()