setupNavConfirmation = () ->
  # Initialize a variable that determines whether or not to ask
  # for confirmation to leave the page, and keep track of the
  # current description content
  confirm_nav = false
  desc = ''
  if $('.summernote').code()
    desc = $('.summernote').code().trim()

  # Disable the navigation pop-up if the user is saving or canceling
  $('#content-save-btn').click ->
    confirm_nav = false
    return true
  $('#content-cancel-btn').click ->
    confirm_nav = false
    return true

  # Enable the navigation pop-up if the user is editing the description
  $('#content-edit-btn').click ->
    confirm_nav = true
  $('#add-content-image').click ->
    confirm_nav = true

  # Pop up a warning if the description has changed
  $(window).on 'beforeunload', ->
    desc_new = ''
    if $('.summernote').code()
      desc_new = $('.summernote').code().trim()

    if (confirm_nav && (desc_new != desc))
      return "You have attempted to leave this page. If you have made any " +
        "changes to the project description without clicking the Save " +
        "button, your changes will be lost."

$ ->
  if $('.summernote').length
    setupNavConfirmation()
