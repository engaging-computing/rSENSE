setupNavConfirmation = () ->
  # Initialize a variable that determines whether or not to ask
  # for confirmation to leave the page, and keep track of the
  # current description content
  confirm_nav = false
  if $('.summernote').code()
    desc = $('.summernote').code().trim()
  else
    desc = ''

  # Disable the navigation pop-up if the user is saving or canceling
  if $('#content-save-btn')?
    $('#content-save-btn').click ->
      confirm_nav = false
      true
  if $('#content-cancel-btn')?
    $('#content-cancel-btn').click ->
      confirm_nav = false
      true

  # Enable the navigation pop-up if the user is editing the description
  if $('#content-edit-btn')?
    $('#content-edit-btn').click ->
      confirm_nav = true
  if $('#add-content-image')?
    $('#add-content-image').click ->
      confirm_nav = true

  # Pop up a warning if the description has changed
  $(window).on 'beforeunload', ->
    if $('.summernote').code()
      desc_new = $('.summernote').code().trim()
    else
      desc_new = ''
    if (confirm_nav && (desc_new != desc))
      return "You have attempted to leave this page. If you have made any " +
        "changes to the project description without clicking the Save " +
        "button, your changes will be lost."

$ ->
  if $('.summernote').length
    setupNavConfirmation()
