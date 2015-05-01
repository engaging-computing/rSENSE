##
# flash.js.coffee.erb
#
# This file is for dynamic addition of 'flash' messages from js.
$ ->
  flashTypes =
    success: 'alert-success'
    error: 'alert-danger'
    warning: 'alert-warning'

  window.quickFlash = (msg, type) ->
    # Remove any old flash messages
    $('.alert').remove()

    # Determine the color of this flash message
    typeClass = flashTypes[type]

    # This is the heart of the flash message
    flash =
      """
      <div class='alert fade in #{typeClass}'>
        <button class='close' data-dismiss='alert'>×</button>
        #{msg}
      </div>
      """

    # Scroll so you can see the flash message
    scrollTo(0, 0)

    # Draw the flash message
    $('.container.mainContent').prepend(flash)
