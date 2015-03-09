# Place all the behaviors and hooks related to the users show page here.
setupCallbacks = () ->
  $("a.contrib-delete-link").on "ajax:success", (ee, data, status, xhr) ->
    $(ee.target).closest('tr').hide()

  $("a.contrib-delete-link").on "ajax:error", (ee, data, status, xhr) ->
    # TODO Handle Error

IS.onReady "users/show", ->
  # Start recent 3
  nav_list = []

  $('#user_filter li').each (index) ->
    nav_list.push $(@).text()

  nav_list.push "All"

  $('#user_filter li').click ->

    $("#user_filter .active").removeClass "active"
    $(@).addClass "active"

    filter_selection = $(@).text()

    # compares the filter you clicked on to the list of filters
    # to see if its "your" page or a filter
    if( nav_list.some (word) -> ~filter_selection.indexOf(word) )
      $("#contributions_content").show()

      $("#page").val("0")

      filter_ajax_params = $('#contribution_search').serialize()
      filter_ajax_params += "&filters=#{filter_selection}"

      globals.arrowsClicked = false

      $.ajax
        url: "/users/#{$('#contribution_search')
          .attr('data-user-id')}/contributions"
        data: filter_ajax_params
        dataType: "html"
        success: (filtered_html) ->
          $("#contributions").html filtered_html
          if (parseInt($("#mparams").attr("totalPages")) > 0)
            $("#pageLabel").html "Page " + (parseInt( $("#page").val(), 10 ) +
              1) + " of " + $("#mparams").attr("totalPages")
          else
            $("#pageLabel").html "No Results"
          if (parseInt( $("#page").val(), 10 ) == 0)
            $(".pagebck").hide()
          else
            $(".pagebck").show()
          if($("#mparams").attr("lastPage") == "true" ||
          parseInt($("#mparams").attr("totalPages")) == 0)
            $(".pagefwd").hide()
          else
            $(".pagefwd").show()

          setupCallbacks()

  window.globals ?= {}
  globals.arrowsClicked = false

  $(".contribution_sort_select").change ->
    $("#contribution_search").submit()

  $("#contribution_search").submit ->
    ajax_params = $('#contribution_search').serialize()
    ajax_params += "&filters=#{$('#user_filter .active').text()}"

    globals.arrowsClicked = false

    $.ajax
      url: "/users/#{$('#contribution_search')
        .attr('data-user-id')}/contributions"
      data: ajax_params
      dataType: "html"
      success: (dat) ->
        $("#contributions").html dat
        if (parseInt($("#mparams").attr("totalPages")) > 0)
          $("#pageLabel").html "Page " +
            (parseInt( $("#page").val(), 10 ) + 1) +
            " of " + $("#mparams").attr("totalPages")
        else
          $("#pageLabel").html "No Results"
        if (parseInt( $("#page").val(), 10 ) == 0)
          $(".pagebck").hide()
        else
          $(".pagebck").show()
        if($("#mparams").attr("lastPage") == "true" ||
        parseInt($("#mparams").attr("totalPages")) == 0)
          $(".pagefwd").hide()
        else
          $(".pagefwd").show()

    return false

  $("#contribution_search_btn").click ->
    $("#contribution_search").submit()

  $("#contribution_search").submit()

  $(".pagefwd").click ->
    globals.arrowsClicked = true
    pageNum = parseInt( $("#page").val(), 10 )
    $("#page").val("" + (pageNum + 1))
    $("#contribution_search").submit()

  $(".pagebck").click ->
    globals.arrowsClicked = true
    pageNum = parseInt($("#page").val(), 10 )
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
        quickFlash('Hidden', 'success')

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
        quickFlash('unhidden', 'success')

      error: (msg) ->
        response = $.parseJSON(msg['responseText']).errors
        quickFlash(response, 'error')

  $('.mainContent').on 'click', 'a.contrib-delete-link', (e) ->
    e.preventDefault()

    if helpers.confirm_delete $(@).parents('div.contribution').find('h4 a').html()
      $.ajax
        url: $(@).attr('href')
        type: 'DELETE'
        dataType: "json"
        success: =>
          $(@).parents('div.contribution').hide_row () ->
            $('div#contributions div.contribution').filter(':visible').each (idx) ->
              if idx % 2 is 0
                $(@).addClass 'feed-even'
                $(@).removeClass 'feed-odd'
              else
                $(@).removeClass 'feed-even'
                $(@).addClass 'feed-odd'

        error: (msg) ->
          response = $.parseJSON(msg['responseText']).errors
          quickFlash(response, 'error')

  $('.gravatar_img').tooltip
    title: "Go to www.gravatar.com to change your avatar"
