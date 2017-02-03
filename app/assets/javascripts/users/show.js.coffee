$ ->
  if namespace.controller is "users" and namespace.action in ["show"]
    # Place all the behaviors and hooks related to the users show page here.
    $(document).ajaxSuccess (event, request, settings) ->
      query = $(event.target.activeElement)
      if (query.data('method') is 'delete')
        query.closest('tr').after('<tr></tr>').hide()

    $(document).ajaxError (event, xhr, settings, error) ->
      quickFlash('Failed to edit Display Name', 'error')

    navList = []

    $('#user_filter li').each (index) ->
      navList.push $(@).text()

    navList.push "All"

    $('#edit-user-name').click ->
      $('.alert').remove()

    $('#user_filter li').click ->
      $("#user_filter .active").removeClass "active"
      $(@).addClass "active"

      filterSelection = $(@).text()

      # compares the filter you clicked on to the list of filters
      # to see if its "your" page or a filter
      if(navList.some (word) -> ~filterSelection.indexOf(word))
        $("#contributions_content").show()

        $("#page").val("0")

        filterAjaxParams = $('#contribution_search').serialize()
        filterAjaxParams += "&filters=#{filterSelection}"

        globals.arrowsClicked = false

        $.ajax
          url: "/users/#{$('#contribution_search')
            .attr('data-user-id')}/contributions"
          data: filterAjaxParams
          dataType: "html"
          success: (filtered_html) ->
            $("#contributions").html filtered_html
            if (parseInt($("#mparams").attr("totalPages")) > 0)
              pageNum = parseInt($("#page").val(), 10) + 1
              $("#pageLabel").html "Page " + pageNum +
                " of " + $("#mparams").attr("totalPages")
            else
              $("#pageLabel").html "No Results"
            if (parseInt($("#page").val(), 10) == 0)
              $(".pagebck").hide()
            else
              $(".pagebck").show()
            if($("#mparams").attr("lastPage") == "true" ||
            parseInt($("#mparams").attr("totalPages")) == 0)
              $(".pagefwd").hide()
            else
              $(".pagefwd").show()

    window.globals ?= {}
    globals.arrowsClicked = false

    $(".contribution_sort_select").change ->
      $("#contribution_search").submit()

    $("#contribution_search").submit ->
      ajaxParams = $('#contribution_search').serialize()
      ajaxParams += "&filters=#{$('#user_filter .active').text()}"
      ajaxParams += "&sort=#{$('#contribution_sort').val()}"

      globals.arrowsClicked = false

      $.ajax
        url: "/users/#{$('#contribution_search')
          .attr('data-user-id')}/contributions"
        data: ajaxParams
        dataType: "html"
        success: (dat) ->
          $("#contributions").html dat
          if (parseInt($("#mparams").attr("totalPages")) > 0)
            pageNum = parseInt($("#page").val(), 10) + 1
            $("#pageLabel").html "Page " + pageNum +
              " of " + $("#mparams").attr("totalPages")
          else
            $("#pageLabel").html "No Results"
          if (parseInt($("#page").val(), 10) == 0)
            $(".pagebck").hide()
          else
            $(".pagebck").show()
          if($("#mparams").attr("lastPage") == "true" ||
          parseInt($("#mparams").attr("totalPages")) == 0)
            $(".pagefwd").hide()
          else
            $(".pagefwd").show()

      return false

    $('#contribution_search_btn').click ->
      $('#contribution_search').submit()

    $('#contributions').on 'click', '.col-header', ->
      $('#contribution_sort').val($(@).attr('data-nsort'))
      $('#contribution_search').submit()

    $("#contribution_search").submit()

    $(".pagefwd").click ->
      globals.arrowsClicked = true
      pageNum = parseInt($("#page").val(), 10)
      $("#page").val("" + (pageNum + 1))
      $("#contribution_search").submit()

    $(".pagebck").click ->
      globals.arrowsClicked = true
      pageNum = parseInt($("#page").val(), 10)
      $("#page").val("" + (pageNum - 1))
      $("#contribution_search").submit()

    ###
    Links for Contributions
    ###
    $('.mainContent').on 'click', 'a.contribution_hide', (e) ->
      e.preventDefault()

      data = {}
      data[$(@).attr 'type'] =
        hidden: true

      $.ajax
        url: $(@).attr('href')
        type: 'PUT'
        dataType: "json"
        data: data
        success: =>
          $(@).removeClass 'contribution_hide'
          $(@).addClass 'contribution_unhide'
          $(@).html('Unhide')

        error: (msg) ->
          response = $.parseJSON(msg['responseText']).errors
          quickFlash(response, 'error')

    $('.mainContent').on 'click', 'a.contribution_unhide', (e) ->
      e.preventDefault()

      data = {}
      data[$(@).attr 'type'] =
        hidden: false

      $.ajax
        url: $(@).attr('href')
        type: 'PUT'
        dataType: "json"
        data: data
        success: =>
          $(@).addClass 'contribution_hide'
          $(@).removeClass 'contribution_unhide'
          $(@).html('Hide')

        error: (msg) ->
          response = $.parseJSON(msg['responseText']).errors
          quickFlash(response, 'error')

    $('.gravatar_img').tooltip
      title: "Go to www.gravatar.com to change your avatar"
