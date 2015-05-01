setupMenuEditCallbacks = () ->
  $('#title-and-menu-edit').hide()

  if $('#title-and-menu-edit-summary')?
    $('#title-and-menu-edit-summary').hide()

  $('.menu_rename').click (e) ->
    e.preventDefault()

    $('#title-and-menu-title').hide()
    $('#title-and-menu-edit').show()
    $('.edit_visualization').show()
    $('.edit_data_set').show()

    $('#media_object_title').focus()
    $('#media_object_title').select()

  $('.summary_edit').click (e) ->
    e.preventDefault()

    $('#title-and-menu-show-summary').hide()
    $('#title-and-menu-edit-summary').show()

    $('#media_object_summary').focus()

$ ->
  if $('.edit_menu')?
    setupMenuEditCallbacks()
